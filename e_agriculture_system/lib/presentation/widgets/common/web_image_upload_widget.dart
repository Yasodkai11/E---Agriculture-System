import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/imagebb_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../providers/auth_provider.dart';

class WebImageUploadWidget extends StatefulWidget {
  final String? currentImageUrl;
  final String? collectionName;
  final String? documentId;
  final String? fieldName;
  final Function(String)? onImageUploaded;
  final Function(String)? onImageDeleted;
  final double? width;
  final double? height;
  final bool showDeleteButton;
  final bool showUploadButton;
  final String? uploadButtonText;
  final IconData? uploadIcon;

  const WebImageUploadWidget({
    super.key,
    this.currentImageUrl,
    this.collectionName,
    this.documentId,
    this.fieldName,
    this.onImageUploaded,
    this.onImageDeleted,
    this.width,
    this.height,
    this.showDeleteButton = true,
    this.showUploadButton = true,
    this.uploadButtonText,
    this.uploadIcon,
  });

  @override
  State<WebImageUploadWidget> createState() => _WebImageUploadWidgetState();
}

class _WebImageUploadWidgetState extends State<WebImageUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageBBService _imageBBService = ImageBBService();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isUploading = false;
  String? _uploadedImageUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.currentImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 200,
      height: widget.height ?? 200,
      child: Column(
        children: [
          // Image Display
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _uploadedImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _uploadedImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 48),
                                  SizedBox(height: 8),
                                  Text('Failed to load image'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.grey, size: 48),
                            SizedBox(height: 8),
                            Text('No image selected'),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Upload Button
          if (widget.showUploadButton) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _showImagePickerDialog,
                icon: _isUploading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.uploadIcon ?? Icons.upload),
                label: Text(
                  _isUploading 
                      ? 'Uploading...' 
                      : (widget.uploadButtonText ?? 'Upload Image'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          
          // Delete Button
          if (widget.showDeleteButton && _uploadedImageUrl != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _deleteImage,
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          
          // Error Message
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadImage(image);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _uploadImage(XFile imageFile) async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      print('📤 Uploading to ImageBB...');
      
      // Upload to ImageBB
      final response = await _imageBBService.uploadImage(
        imageFile: imageFile,
        name: '${widget.collectionName ?? 'image'}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (response.success) {
        final imageUrl = response.data.displayUrl;
        print('✅ ImageBB upload successful: $imageUrl');
        
        setState(() {
          _uploadedImageUrl = imageUrl;
          _isUploading = false;
        });

        // Save to Firestore if collection and document are provided
        if (widget.collectionName != null && widget.documentId != null) {
          await _saveImageUrlToFirestore(imageUrl);
        }

        // Call callback if provided
        if (widget.onImageUploaded != null) {
          widget.onImageUploaded!(imageUrl);
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('ImageBB upload failed: ${response.status}');
      }
    } catch (e) {
      print('❌ Upload failed: $e');
      setState(() {
        _errorMessage = 'Upload failed: $e';
        _isUploading = false;
      });
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update the document with the image URL
      await _firebaseService.updateDocument(
        collection: widget.collectionName!,
        documentId: widget.documentId!,
        data: {
          widget.fieldName ?? 'imageUrl': imageUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      print('✅ Image URL saved to Firestore');
    } catch (e) {
      print('❌ Error saving image URL to Firestore: $e');
      // Don't show error to user as image was uploaded successfully
    }
  }

  Future<void> _deleteImage() async {
    try {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
      });

      // Remove from Firestore if collection and document are provided
      if (widget.collectionName != null && widget.documentId != null) {
        await _removeImageUrlFromFirestore();
      }

      setState(() {
        _uploadedImageUrl = null;
        _isUploading = false;
      });

      // Call callback if provided
      if (widget.onImageDeleted != null) {
        widget.onImageDeleted!(_uploadedImageUrl ?? '');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Delete failed: $e';
        _isUploading = false;
      });
    }
  }

  Future<void> _removeImageUrlFromFirestore() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove the image URL from the document
      await _firebaseService.updateDocument(
        collection: widget.collectionName!,
        documentId: widget.documentId!,
        data: {
          widget.fieldName ?? 'imageUrl': FieldValue.delete(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      print('✅ Image URL removed from Firestore');
    } catch (e) {
      print('❌ Error removing image URL from Firestore: $e');
    }
  }
}

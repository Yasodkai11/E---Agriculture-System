import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/imagebb_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../providers/auth_provider.dart';

class ImageUploadWidget extends StatefulWidget {
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

  const ImageUploadWidget({
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
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
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
    return Column(
      children: [
        // Image Display
        _buildImageDisplay(),
        
        // Upload Button
        if (widget.showUploadButton) ...[
          const SizedBox(height: 16),
          _buildUploadButton(),
        ],
        
        // Error Message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(),
        ],
        
        // Loading Indicator
        if (_isUploading) ...[
          const SizedBox(height: 8),
          _buildLoadingIndicator(),
        ],
      ],
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      width: widget.width ?? 200,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _uploadedImageUrl != null
            ? Image.network(
                _uploadedImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _showImagePickerDialog,
          icon: Icon(widget.uploadIcon ?? Icons.upload),
          label: Text(widget.uploadButtonText ?? 'Upload Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (widget.showDeleteButton && _uploadedImageUrl != null) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _deleteImage,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(
          'Uploading...',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
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
      // Upload to ImageBB
      final response = await _imageBBService.uploadImage(
        imageFile: imageFile,
        name: '${widget.collectionName ?? 'image'}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (response.success) {
        final imageUrl = response.data.displayUrl;
        
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
        throw Exception('Failed to upload image to ImageBB');
      }
    } catch (e) {
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
    } catch (e) {
      debugPrint('Error saving image URL to Firestore: $e');
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
        widget.onImageDeleted!('');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully!'),
            backgroundColor: Colors.green,
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
      // Update the document to remove the image URL
      await _firebaseService.updateDocument(
        collection: widget.collectionName!,
        documentId: widget.documentId!,
        data: {
          widget.fieldName ?? 'imageUrl': FieldValue.delete(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error removing image URL from Firestore: $e');
      rethrow;
    }
  }
}

/// Simple Image Display Widget
class ImageDisplayWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageDisplayWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder ?? _buildDefaultPlaceholder();
    }

    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        imageUrl!,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

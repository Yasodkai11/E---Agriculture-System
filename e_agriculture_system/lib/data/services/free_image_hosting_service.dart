import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

enum FreeHostingProvider {
  imgur,
  postimages,
  imagebb,
}

class FreeImageHostingService {
  static final FreeImageHostingService _instance = FreeImageHostingService._internal();
  factory FreeImageHostingService() => _instance;
  FreeImageHostingService._internal();

  // ========== IMGUR CONFIGURATION ==========
  static const String _imgurClientId = '546c25a59c58ad7'; // Anonymous client ID
  static const String _imgurUploadUrl = 'https://api.imgur.com/3/image';

  // ========== POSTIMAGES CONFIGURATION ==========
  static const String _postimagesUploadUrl = 'https://postimages.org/api/upload';

  // ========== IMAGEBB CONFIGURATION ==========
  // Note: ImageBB requires a valid API key. For now, we'll skip it and use Imgur as primary
  static const String _imagebbApiKey = ''; // Empty - will be skipped
  static const String _imagebbUploadUrl = 'https://api.imgbb.com/1/upload';

  /// Upload image to free hosting service
  Future<String> uploadImage(File imageFile, FreeHostingProvider provider) async {
    try {
      switch (provider) {
        case FreeHostingProvider.imgur:
          return await _uploadToImgur(imageFile);
        case FreeHostingProvider.postimages:
          return await _uploadToPostimages(imageFile);
        case FreeHostingProvider.imagebb:
          return await _uploadToImageBB(imageFile);
      }
    } catch (e) {
      throw Exception('Failed to upload image to ${provider.name}: $e');
    }
  }

  /// Upload image to Imgur
  Future<String> _uploadToImgur(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_imgurUploadUrl),
        headers: {
          'Authorization': 'Client-ID $_imgurClientId',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
          'type': 'base64',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['link'];
        } else {
          throw Exception('Imgur upload failed: ${data['data']['error']}');
        }
      } else {
        throw Exception('Imgur upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Imgur upload error: $e');
    }
  }

  /// Upload image to Postimages
  Future<String> _uploadToPostimages(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_postimagesUploadUrl));
      request.files.add(await http.MultipartFile.fromPath('upload', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          return data['url'];
        } else {
          throw Exception('Postimages upload failed: ${data['error']}');
        }
      } else {
        throw Exception('Postimages upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Postimages upload error: $e');
    }
  }

  /// Upload image to ImageBB
  Future<String> _uploadToImageBB(File imageFile) async {
    // Skip ImageBB if no API key is provided
    if (_imagebbApiKey.isEmpty) {
      throw Exception('ImageBB API key not configured. Please use Imgur or Postimages instead.');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_imagebbUploadUrl),
        body: {
          'key': _imagebbApiKey,
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['url'];
        } else {
          throw Exception('ImageBB upload failed: ${data['error']['message']}');
        }
      } else {
        throw Exception('ImageBB upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ImageBB upload error: $e');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadImages(List<File> images, FreeHostingProvider provider) async {
    List<String> imageUrls = [];
    
    for (final image in images) {
      try {
        final url = await uploadImage(image, provider);
        imageUrls.add(url);
      } catch (e) {
        // Log error but continue with other images
        print('Failed to upload image: $e');
      }
    }
    
    return imageUrls;
  }

  /// Get optimized image URL (for Imgur, can add size parameters)
  String getOptimizedImageUrl(String imageUrl, String useCase) {
    if (imageUrl.contains('imgur.com')) {
      // Imgur supports size parameters
      switch (useCase.toLowerCase()) {
        case 'thumbnail':
          return imageUrl.replaceAll('.jpg', 's.jpg'); // Small thumbnail
        case 'medium':
          return imageUrl.replaceAll('.jpg', 'm.jpg'); // Medium size
        case 'large':
          return imageUrl.replaceAll('.jpg', 'l.jpg'); // Large size
        default:
          return imageUrl;
      }
    }
    return imageUrl;
  }

  /// Check if image URL is from a supported hosting service
  bool isSupportedImageUrl(String imageUrl) {
    return imageUrl.contains('imgur.com') || 
           imageUrl.contains('postimg.cc') || 
           imageUrl.contains('ibb.co');
  }

  /// Get hosting service info
  Map<String, String> getHostingInfo(FreeHostingProvider provider) {
    switch (provider) {
      case FreeHostingProvider.imgur:
        return {
          'name': 'Imgur',
          'description': 'Free image hosting with API support',
          'pros': 'Reliable, fast, supports optimization',
          'cons': 'Requires client ID, rate limited',
          'website': 'https://imgur.com',
        };
      case FreeHostingProvider.postimages:
        return {
          'name': 'Postimages',
          'description': 'Simple image hosting service',
          'pros': 'No API key required, simple',
          'cons': 'Less reliable, no optimization',
          'website': 'https://postimages.org',
        };
      case FreeHostingProvider.imagebb:
        return {
          'name': 'ImageBB',
          'description': 'Free image hosting with API',
          'pros': 'API support, good for apps',
          'cons': 'Requires API key, limited free tier',
          'website': 'https://imgbb.com',
        };
    }
  }

  /// Get recommended provider based on use case
  FreeHostingProvider getRecommendedProvider(String useCase) {
    switch (useCase.toLowerCase()) {
      case 'production':
      case 'reliable':
        return FreeHostingProvider.imgur;
      case 'simple':
      case 'testing':
        return FreeHostingProvider.postimages;
      case 'api':
      case 'automated':
        return FreeHostingProvider.imagebb;
      default:
        return FreeHostingProvider.imgur;
    }
  }

  /// Validate image file before upload
  bool validateImageFile(File imageFile) {
    final extension = path.extension(imageFile.path).toLowerCase();
    const supportedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return supportedExtensions.contains(extension);
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return bytes.length / (1024 * 1024);
  }

  /// Check if file size is within limits
  Future<bool> isFileSizeValid(File imageFile, {double maxSizeMB = 10.0}) async {
    final sizeMB = await getFileSizeMB(imageFile);
    return sizeMB <= maxSizeMB;
  }
}

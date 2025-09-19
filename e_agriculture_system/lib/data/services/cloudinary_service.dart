import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // Cloudinary configuration - Replace with your own credentials
  // Get these from: https://cloudinary.com/console
  static const String _cloudName = 'your_cloud_name'; // Replace with your cloud name
  static const String _apiKey = 'your_api_key'; // Replace with your API key
  static const String _apiSecret = 'your_api_secret'; // Replace with your API secret
  static const String _uploadPreset = 'ml_default'; // Replace with your upload preset

  /// Upload image to Cloudinary
  Future<String> uploadImage(File imageFile, String folder, String userId, {int? index}) async {
    try {
      // Create upload URL
      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add upload preset
      request.fields['upload_preset'] = _uploadPreset;
      
      // Add folder path
      request.fields['folder'] = 'e_agriculture/$folder/$userId';
      
      // Add public ID (unique identifier)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = '${folder}_${userId}_$timestamp${index != null ? '_$index' : ''}';
      request.fields['public_id'] = publicId;
      
      // Add image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);
      
      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      
      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        throw Exception('Upload failed: ${jsonData['error']?.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadImages(List<File> images, String folder, String userId) async {
    List<String> imageUrls = [];
    
    for (int i = 0; i < images.length; i++) {
      final imageUrl = await uploadImage(images[i], folder, userId, index: i);
      imageUrls.add(imageUrl);
    }
    
    return imageUrls;
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = _generateSignature(publicId, timestamp);
      
      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'signature': signature,
          'api_key': _apiKey,
        },
      );
      
      final jsonData = json.decode(response.body);
      return jsonData['result'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  /// Generate signature for authenticated requests
  String _generateSignature(String publicId, int timestamp) {
    // This is a simplified signature generation
    // In production, you should implement proper signature generation
    final params = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    return _hashString(params);
  }

  /// Simple hash function (use a proper crypto library in production)
  String _hashString(String input) {
    // This is a placeholder - use proper SHA-1 or SHA-256 hashing
    return input.hashCode.toString();
  }

  /// Transform image URL (resize, crop, etc.)
  String transformImageUrl(String originalUrl, {
    int? width,
    int? height,
    String? crop,
    int? quality,
  }) {
    if (originalUrl.isEmpty) return originalUrl;
    
    final uri = Uri.parse(originalUrl);
    final pathSegments = List<String>.from(uri.pathSegments);
    
    // Insert transformation parameters
    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (crop != null) transformations.add('c_$crop');
    if (quality != null) transformations.add('q_$quality');
    
    if (transformations.isNotEmpty) {
      pathSegments.insert(1, transformations.join(','));
    }
    
    return uri.replace(pathSegments: pathSegments).toString();
  }

  /// Get optimized image URL for different use cases
  String getOptimizedImageUrl(String originalUrl, String useCase) {
    switch (useCase) {
      case 'thumbnail':
        return transformImageUrl(originalUrl, width: 150, height: 150, crop: 'fill', quality: 80);
      case 'medium':
        return transformImageUrl(originalUrl, width: 400, height: 400, crop: 'limit', quality: 85);
      case 'large':
        return transformImageUrl(originalUrl, width: 800, height: 800, crop: 'limit', quality: 90);
      default:
        return originalUrl;
    }
  }
}

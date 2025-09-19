import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageBBService {
  static final ImageBBService _instance = ImageBBService._internal();
  factory ImageBBService() => _instance;
  ImageBBService._internal();

  // ImageBB API configuration
  static const String _apiKey = 'a7a0d55387fbb71950bce93f554d3872';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';
  
  // Get your API key from: https://api.imgbb.com/
  
  /// Upload image to ImageBB
  Future<ImageBBResponse> uploadImage({
    required XFile imageFile,
    String? name,
    int? expiration,
  }) async {
    try {
      // Read image file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final base64Image = base64Encode(bytes);
      
      // Prepare request body
      final requestBody = {
        'key': _apiKey,
        'image': base64Image,
        if (name != null) 'name': name,
        if (expiration != null) 'expiration': expiration.toString(),
      };

      // Make HTTP request
      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          return ImageBBResponse.fromJson(responseData);
        } else {
          throw Exception('ImageBB API Error: ${responseData['error']['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image to ImageBB: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload image from File object (Mobile/Desktop only - not web compatible)
  Future<ImageBBResponse> uploadImageFromFile({
    required dynamic imageFile, // Using dynamic to avoid dart:io import
    String? name,
    int? expiration,
  }) async {
    try {
      // For web compatibility, we need to handle this differently
      if (kIsWeb) {
        // On web, we can't use File.readAsBytes() directly
        // This method should not be called on web
        throw Exception('uploadImageFromFile is not supported on web. Use uploadImage with XFile instead.');
      }
      
      // This method is only for mobile/desktop platforms
      // Convert to XFile and use the main upload method
      final xFile = XFile(imageFile.path);
      return await uploadImage(
        imageFile: xFile,
        name: name,
        expiration: expiration,
      );
    } catch (e) {
      debugPrint('Error uploading image to ImageBB: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images
  Future<List<ImageBBResponse>> uploadMultipleImages({
    required List<XFile> imageFiles,
    String? namePrefix,
    int? expiration,
  }) async {
    final List<ImageBBResponse> responses = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final name = namePrefix != null ? '${namePrefix}_$i' : null;
        final response = await uploadImage(
          imageFile: imageFiles[i],
          name: name,
          expiration: expiration,
        );
        responses.add(response);
      } catch (e) {
        debugPrint('Error uploading image $i: $e');
        // Continue with other images even if one fails
      }
    }
    
    return responses;
  }

  /// Delete image from ImageBB (if supported)
  Future<bool> deleteImage(String deleteUrl) async {
    try {
      final response = await http.get(Uri.parse(deleteUrl));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get image info
  Future<ImageBBInfo?> getImageInfo(String imageUrl) async {
    try {
      // Extract image ID from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isNotEmpty) {
        final imageId = pathSegments.last.split('.').first;
        
        // Make request to get image info
        final response = await http.get(
          Uri.parse('https://api.imgbb.com/1/image/$imageId?key=$_apiKey'),
        );
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            return ImageBBInfo.fromJson(responseData['data']);
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting image info: $e');
      return null;
    }
  }
}

/// ImageBB API Response Model
class ImageBBResponse {
  final bool success;
  final int status;
  final ImageBBData data;

  ImageBBResponse({
    required this.success,
    required this.status,
    required this.data,
  });

  factory ImageBBResponse.fromJson(Map<String, dynamic> json) {
    return ImageBBResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      data: ImageBBData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'data': data.toJson(),
    };
  }
}

/// ImageBB Data Model
class ImageBBData {
  final String id;
  final String title;
  final String urlViewer;
  final String url;
  final String displayUrl;
  final String deleteUrl;
  final int size;
  final int time;
  final int expiration;
  final ImageBBImage image;
  final ImageBBThumb thumb;
  final ImageBBMedium medium;

  ImageBBData({
    required this.id,
    required this.title,
    required this.urlViewer,
    required this.url,
    required this.displayUrl,
    required this.deleteUrl,
    required this.size,
    required this.time,
    required this.expiration,
    required this.image,
    required this.thumb,
    required this.medium,
  });

  factory ImageBBData.fromJson(Map<String, dynamic> json) {
    return ImageBBData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      urlViewer: json['url_viewer'] ?? '',
      url: json['url'] ?? '',
      displayUrl: json['display_url'] ?? '',
      deleteUrl: json['delete_url'] ?? '',
      size: json['size'] ?? 0,
      time: json['time'] ?? 0,
      expiration: json['expiration'] ?? 0,
      image: ImageBBImage.fromJson(json['image'] ?? {}),
      thumb: ImageBBThumb.fromJson(json['thumb'] ?? {}),
      medium: ImageBBMedium.fromJson(json['medium'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url_viewer': urlViewer,
      'url': url,
      'display_url': displayUrl,
      'delete_url': deleteUrl,
      'size': size,
      'time': time,
      'expiration': expiration,
      'image': image.toJson(),
      'thumb': thumb.toJson(),
      'medium': medium.toJson(),
    };
  }
}

/// ImageBB Image Model
class ImageBBImage {
  final String filename;
  final String name;
  final String mime;
  final String extension;
  final String url;

  ImageBBImage({
    required this.filename,
    required this.name,
    required this.mime,
    required this.extension,
    required this.url,
  });

  factory ImageBBImage.fromJson(Map<String, dynamic> json) {
    return ImageBBImage(
      filename: json['filename'] ?? '',
      name: json['name'] ?? '',
      mime: json['mime'] ?? '',
      extension: json['extension'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'name': name,
      'mime': mime,
      'extension': extension,
      'url': url,
    };
  }
}

/// ImageBB Thumbnail Model
class ImageBBThumb {
  final String filename;
  final String name;
  final String mime;
  final String extension;
  final String url;

  ImageBBThumb({
    required this.filename,
    required this.name,
    required this.mime,
    required this.extension,
    required this.url,
  });

  factory ImageBBThumb.fromJson(Map<String, dynamic> json) {
    return ImageBBThumb(
      filename: json['filename'] ?? '',
      name: json['name'] ?? '',
      mime: json['mime'] ?? '',
      extension: json['extension'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'name': name,
      'mime': mime,
      'extension': extension,
      'url': url,
    };
  }
}

/// ImageBB Medium Model
class ImageBBMedium {
  final String filename;
  final String name;
  final String mime;
  final String extension;
  final String url;

  ImageBBMedium({
    required this.filename,
    required this.name,
    required this.mime,
    required this.extension,
    required this.url,
  });

  factory ImageBBMedium.fromJson(Map<String, dynamic> json) {
    return ImageBBMedium(
      filename: json['filename'] ?? '',
      name: json['name'] ?? '',
      mime: json['mime'] ?? '',
      extension: json['extension'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'name': name,
      'mime': mime,
      'extension': extension,
      'url': url,
    };
  }
}

/// ImageBB Info Model
class ImageBBInfo {
  final String id;
  final String title;
  final String urlViewer;
  final String url;
  final String displayUrl;
  final int size;
  final int time;
  final int expiration;

  ImageBBInfo({
    required this.id,
    required this.title,
    required this.urlViewer,
    required this.url,
    required this.displayUrl,
    required this.size,
    required this.time,
    required this.expiration,
  });

  factory ImageBBInfo.fromJson(Map<String, dynamic> json) {
    return ImageBBInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      urlViewer: json['url_viewer'] ?? '',
      url: json['url'] ?? '',
      displayUrl: json['display_url'] ?? '',
      size: json['size'] ?? 0,
      time: json['time'] ?? 0,
      expiration: json['expiration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url_viewer': urlViewer,
      'url': url,
      'display_url': displayUrl,
      'size': size,
      'time': time,
      'expiration': expiration,
    };
  }
}

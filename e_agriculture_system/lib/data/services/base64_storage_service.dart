import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class Base64StorageService {
  static final Base64StorageService _instance = Base64StorageService._internal();
  factory Base64StorageService() => _instance;
  Base64StorageService._internal();

  /// Convert image file to base64 string
  Future<String> imageToBase64(File imageFile, {int quality = 80}) async {
    try {
      if (kIsWeb) {
        // For web, read bytes directly without compression
        final bytes = await imageFile.readAsBytes();
        return base64Encode(bytes);
      } else {
        // For mobile, compress image first to reduce size
        final compressedFile = await _compressImage(imageFile, quality: quality);
        final bytes = await compressedFile.readAsBytes();
        return base64Encode(bytes);
      }
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  /// Convert base64 string back to image file
  Future<File> base64ToImageFile(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      
      if (kIsWeb) {
        // For web, create a temporary file in memory
        // Note: This is a simplified approach for web
        final tempFile = File('temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(bytes);
        return tempFile;
      } else {
        // For mobile, use temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(bytes);
        return tempFile;
      }
    } catch (e) {
      throw Exception('Failed to convert base64 to image file: $e');
    }
  }

  /// Upload multiple images as base64
  Future<List<String>> uploadImagesAsBase64(List<File> images, {int quality = 80}) async {
    List<String> base64Strings = [];
    
    for (final image in images) {
      final base64String = await imageToBase64(image, quality: quality);
      base64Strings.add(base64String);
    }
    
    return base64Strings;
  }

  /// Compress image to reduce file size (mobile only)
  Future<File> _compressImage(File imageFile, {int quality = 80}) async {
    try {
      // Only compress on mobile platforms
      if (kIsWeb) {
        // For web, return the original file without compression
        return imageFile;
      }
      
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) throw Exception('Failed to decode image');
      
      // Resize image if it's too large (max 800px width/height)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(image, width: 800, height: 800);
      }
      
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // Save compressed image to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      return tempFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Get temporary directory
  Future<Directory> _getTemporaryDirectory() async {
    if (kIsWeb) {
      throw Exception('getTemporaryDirectory is not supported on web platform');
    }
    return await getTemporaryDirectory();
  }

  /// Get image size in KB
  Future<double> getBase64ImageSize(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      return bytes.length / 1024; // Convert to KB
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if base64 string is valid image
  bool isValidBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      
      if (kIsWeb) {
        // For web, just check if it's valid base64
        return bytes.isNotEmpty;
      } else {
        // For mobile, check if it's a valid image
        final image = img.decodeImage(bytes);
        return image != null;
      }
    } catch (e) {
      return false;
    }
  }

  /// Create thumbnail from base64 image
  Future<String> createThumbnail(String base64String, {int size = 150}) async {
    try {
      if (kIsWeb) {
        // For web, return the original base64 string as thumbnail
        // (no compression/resizing on web)
        return base64String;
      }
      
      final bytes = base64Decode(base64String);
      final image = img.decodeImage(bytes);
      
      if (image == null) throw Exception('Failed to decode image');
      
      final thumbnail = img.copyResize(image, width: size, height: size);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);
      
      return base64Encode(thumbnailBytes);
    } catch (e) {
      throw Exception('Failed to create thumbnail: $e');
    }
  }
}

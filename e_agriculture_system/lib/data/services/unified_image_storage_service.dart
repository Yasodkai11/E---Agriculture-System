import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'free_image_hosting_service.dart';
import 'cloudinary_service.dart';
import 'base64_storage_service.dart';
import 'imagebb_service.dart';

enum StorageType {
  freeHosting,
  cloudinary,
  base64,
  firebase, // Keep Firebase as an option for when you upgrade
}

class UnifiedImageStorageService {
  static final UnifiedImageStorageService _instance = UnifiedImageStorageService._internal();
  factory UnifiedImageStorageService() => _instance;
  UnifiedImageStorageService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FreeImageHostingService _freeHostingService = FreeImageHostingService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final Base64StorageService _base64Service = Base64StorageService();
  final ImageBBService _imageBBService = ImageBBService();

  // Default storage type - use free hosting for all platforms
  StorageType _storageType = StorageType.freeHosting;

  /// Set the storage type to use
  void setStorageType(StorageType type) {
    _storageType = type;
  }

  /// Get current storage type
  StorageType get storageType => _storageType;

  /// Upload single image
  Future<String> uploadImage(File imageFile, String category, {int? index}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // For web, use ImageBB directly as it's web-compatible
    if (kIsWeb) {
      try {
        // Convert File to XFile for web compatibility
        final xFile = XFile(imageFile.path);
        final response = await _imageBBService.uploadImage(
          imageFile: xFile,
          name: '${category}_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        if (response.success) {
          return response.data.displayUrl;
        } else {
          throw Exception('ImageBB upload failed: ${response.status}');
        }
      } catch (e) {
        throw Exception('ImageBB upload error: $e');
      }
    }

    // For mobile/desktop, use the original logic
    switch (_storageType) {
      case StorageType.freeHosting:
        // Try Imgur first, then fallback to Postimages
        try {
          return await _freeHostingService.uploadImage(imageFile, FreeHostingProvider.imgur);
        } catch (e) {
          print('Imgur upload failed, trying Postimages: $e');
          try {
            return await _freeHostingService.uploadImage(imageFile, FreeHostingProvider.postimages);
          } catch (e2) {
            throw Exception('Both Imgur and Postimages failed. Imgur error: $e, Postimages error: $e2');
          }
        }
      
      case StorageType.cloudinary:
        return await _cloudinaryService.uploadImage(imageFile, category, userId, index: index);
      
      case StorageType.base64:
        return await _base64Service.imageToBase64(imageFile);
      
      case StorageType.firebase:
        // Keep Firebase implementation for future use
        throw Exception('Firebase Storage is not available in free tier');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadImages(List<File> images, String category) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // For web, use ImageBB directly
    if (kIsWeb) {
      try {
        final xFiles = images.map((file) => XFile(file.path)).toList();
        final responses = await _imageBBService.uploadMultipleImages(
          imageFiles: xFiles,
          namePrefix: category,
        );
        
        return responses.map((response) => response.data.displayUrl).toList();
      } catch (e) {
        throw Exception('ImageBB multiple upload error: $e');
      }
    }

    switch (_storageType) {
      case StorageType.freeHosting:
        // Try Imgur first, then fallback to Postimages
        try {
          return await _freeHostingService.uploadImages(images, FreeHostingProvider.imgur);
        } catch (e) {
          print('Imgur upload failed, trying Postimages: $e');
          try {
            return await _freeHostingService.uploadImages(images, FreeHostingProvider.postimages);
          } catch (e2) {
            throw Exception('Both Imgur and Postimages failed. Imgur error: $e, Postimages error: $e2');
          }
        }
      
      case StorageType.cloudinary:
        return await _cloudinaryService.uploadImages(images, category, userId);
      
      case StorageType.base64:
        return await _base64Service.uploadImagesAsBase64(images);
      
      case StorageType.firebase:
        throw Exception('Firebase Storage is not available in free tier');
    }
  }

  /// Get image file from storage
  Future<File?> getImageFile(String imagePath) async {
    switch (_storageType) {
      case StorageType.freeHosting:
        // Free hosting services return URLs, not local files
        // Return null as we work with URLs directly
        return null;
      
      case StorageType.cloudinary:
        // For Cloudinary, you might want to download the image first
        // This is a simplified implementation
        return null;
      
      case StorageType.base64:
        return await _base64Service.base64ToImageFile(imagePath);
      
      case StorageType.firebase:
        throw Exception('Firebase Storage is not available in free tier');
    }
  }

  /// Delete image from storage
  Future<bool> deleteImage(String imagePath) async {
    switch (_storageType) {
      case StorageType.freeHosting:
        // Free hosting services typically don't support deletion via API
        // Images will expire automatically or can be manually deleted
        return true;
      
      case StorageType.cloudinary:
        // Extract public ID from URL and delete
        return await _cloudinaryService.deleteImage(imagePath);
      
      case StorageType.base64:
        // Base64 images are stored in Firestore, so deletion is handled there
        return true;
      
      case StorageType.firebase:
        throw Exception('Firebase Storage is not available in free tier');
    }
  }

  /// Get optimized image URL (mainly for Cloudinary and free hosting)
  String getOptimizedImageUrl(String imageUrl, String useCase) {
    switch (_storageType) {
      case StorageType.freeHosting:
        return _freeHostingService.getOptimizedImageUrl(imageUrl, useCase);
      
      case StorageType.cloudinary:
        return _cloudinaryService.getOptimizedImageUrl(imageUrl, useCase);
      
      case StorageType.base64:
      case StorageType.firebase:
        return imageUrl; // Return as is for other storage types
    }
  }

  /// Get storage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    switch (_storageType) {
      case StorageType.freeHosting:
        return {
          'type': 'free_hosting',
          'message': 'Using free image hosting services (Imgur, Postimages, ImageBB)',
          'provider': 'imgur',
        };
      
      case StorageType.cloudinary:
        return {
          'type': 'cloudinary',
          'message': 'Cloudinary storage - check your Cloudinary dashboard for usage',
        };
      
      case StorageType.base64:
        return {
          'type': 'base64',
          'message': 'Images stored as base64 strings in Firestore',
        };
      
      case StorageType.firebase:
        return {
          'type': 'firebase',
          'message': 'Firebase Storage is not available in free tier',
        };
    }
  }

  /// Get images for a specific user and category
  Future<List<String>> getImagesForUser(String category) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return [];
    }

    switch (_storageType) {
      case StorageType.freeHosting:
      case StorageType.cloudinary:
      case StorageType.base64:
      case StorageType.firebase:
        // These would need to be implemented based on your data structure
        // Images are typically retrieved from Firestore documents
        return [];
    }
  }

  /// Clear all images for current user
  Future<void> clearUserImages() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    switch (_storageType) {
      case StorageType.freeHosting:
      case StorageType.cloudinary:
      case StorageType.base64:
      case StorageType.firebase:
        // These would need to be implemented based on your data structure
        // Images are typically managed through Firestore documents
        break;
    }
  }

  /// Check if image path is valid for current storage type
  bool isValidImagePath(String imagePath) {
    switch (_storageType) {
      case StorageType.freeHosting:
        return _freeHostingService.isSupportedImageUrl(imagePath);
      
      case StorageType.cloudinary:
        return imagePath.contains('cloudinary.com');
      
      case StorageType.base64:
        return imagePath.length > 100; // Base64 strings are typically long
      
      case StorageType.firebase:
        return imagePath.contains('firebase');
    }
  }

  /// Get storage type description
  String getStorageTypeDescription() {
    switch (_storageType) {
      case StorageType.freeHosting:
        return 'Free Image Hosting - Images stored on free hosting services (Imgur, Postimages, ImageBB)';
      case StorageType.cloudinary:
        return 'Cloudinary - Cloud-based image storage';
      case StorageType.base64:
        return 'Base64 - Images stored as encoded strings';
      case StorageType.firebase:
        return 'Firebase Storage - Not available in free tier';
    }
  }
}

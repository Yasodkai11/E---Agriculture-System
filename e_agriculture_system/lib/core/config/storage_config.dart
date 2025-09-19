import '../../data/services/unified_image_storage_service.dart';

class StorageConfig {
  // ========== STORAGE CONFIGURATION ==========
  
  /// Choose your preferred storage type here
  /// Options: StorageType.freeHosting, StorageType.cloudinary, StorageType.base64
  /// Note: freeHosting uses Imgur, Postimages, or ImageBB for free image storage
  static const StorageType DEFAULT_STORAGE_TYPE = StorageType.freeHosting;
  
  // ========== CLOUDINARY CONFIGURATION ==========
  
  /// Cloudinary credentials (replace with your own)
  /// Sign up at: https://cloudinary.com/
  static const String CLOUDINARY_CLOUD_NAME = 'your_cloud_name';
  static const String CLOUDINARY_API_KEY = 'your_api_key';
  static const String CLOUDINARY_API_SECRET = 'your_api_secret';
  static const String CLOUDINARY_UPLOAD_PRESET = 'ml_default';
  
  // ========== IMAGE COMPRESSION SETTINGS ==========
  
  /// Image compression quality (1-100)
  static const int DEFAULT_IMAGE_QUALITY = 80;
  
  /// Maximum image dimensions (width/height)
  static const int MAX_IMAGE_DIMENSION = 1024;
  
  /// Thumbnail size for previews
  static const int THUMBNAIL_SIZE = 150;
  
  // ========== STORAGE CATEGORIES ==========
  
  /// Image categories for organization
  static const Map<String, String> IMAGE_CATEGORIES = {
    'profile': 'Profile Images',
    'products': 'Product Images',
    'crops': 'Crop Images',
    'equipment': 'Equipment Images',
    'harvests': 'Harvest Images',
    'financial': 'Financial Record Images',
    'general': 'General Images',
  };
  
  // ========== STORAGE LIMITS ==========
  
  /// Maximum number of images per upload
  static const int MAX_IMAGES_PER_UPLOAD = 10;
  
  /// Maximum file size per image (in MB)
  static const double MAX_IMAGE_SIZE_MB = 5.0;
  
  /// Maximum total storage per user (in MB) - for local storage
  static const double MAX_STORAGE_PER_USER_MB = 100.0;
  
  // ========== SUPPORTED IMAGE FORMATS ==========
  
  static const List<String> SUPPORTED_IMAGE_FORMATS = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  
  // ========== STORAGE TYPE DESCRIPTIONS ==========
  
  static const Map<StorageType, Map<String, String>> STORAGE_INFO = {
    StorageType.freeHosting: {
      'name': 'Free Image Hosting',
      'description': 'Images stored on free hosting services (Imgur, Postimages, ImageBB)',
      'pros': 'Free, reliable, shared across devices, no setup required',
      'cons': 'Limited by service policies, may have rate limits',
      'best_for': 'Production apps, prototypes, testing',
    },
    StorageType.cloudinary: {
      'name': 'Cloudinary',
      'description': 'Cloud-based image storage and optimization',
      'pros': 'Free tier available, image optimization, CDN',
      'cons': 'Requires account setup, limited free tier',
      'best_for': 'Production apps, image optimization needed',
    },
    StorageType.base64: {
      'name': 'Base64 Storage',
      'description': 'Images stored as encoded strings in Firestore',
      'pros': 'Simple, no external dependencies',
      'cons': 'Large document size, slower loading',
      'best_for': 'Small images, simple implementations',
    },
    StorageType.firebase: {
      'name': 'Firebase Storage',
      'description': 'Google Firebase cloud storage',
      'pros': 'Integrated with Firebase, reliable',
      'cons': 'Paid service, requires billing setup',
      'best_for': 'Production apps with Firebase ecosystem',
    },
  };
  
  // ========== HELPER METHODS ==========
  
  /// Get storage type info
  static Map<String, String> getStorageTypeInfo(StorageType type) {
    return STORAGE_INFO[type] ?? {};
  }
  
  /// Check if image format is supported
  static bool isImageFormatSupported(String format) {
    return SUPPORTED_IMAGE_FORMATS.contains(format.toLowerCase());
  }
  
  /// Get recommended storage type based on use case
  static StorageType getRecommendedStorageType(String useCase) {
    switch (useCase.toLowerCase()) {
      case 'development':
      case 'testing':
      case 'prototype':
        return StorageType.freeHosting;
      
      case 'production':
      case 'commercial':
        return StorageType.cloudinary;
      
      case 'simple':
      case 'basic':
        return StorageType.base64;
      
      default:
        return DEFAULT_STORAGE_TYPE;
    }
  }
  
  /// Get storage type by name
  static StorageType getStorageTypeByName(String name) {
    switch (name.toLowerCase()) {
      case 'freehosting':
      case 'free_hosting':
      case 'free-hosting':
        return StorageType.freeHosting;
      case 'cloudinary':
        return StorageType.cloudinary;
      case 'base64':
        return StorageType.base64;
      case 'firebase':
        return StorageType.firebase;
      default:
        return DEFAULT_STORAGE_TYPE;
    }
  }
}

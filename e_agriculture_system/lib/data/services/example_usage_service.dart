import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'unified_image_storage_service.dart';
import '../models/product_model.dart';

/// Example service showing how to replace Firebase Storage with alternative storage
class ExampleUsageService {
  static final ExampleUsageService _instance = ExampleUsageService._internal();
  factory ExampleUsageService() => _instance;
  ExampleUsageService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UnifiedImageStorageService _storage = UnifiedImageStorageService();

  // Collection references
  CollectionReference get _productsCollection => _firestore.collection('products');

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // ========== EXAMPLE: PRODUCT SERVICE WITH ALTERNATIVE STORAGE ==========

  /// Create a new product with images (using alternative storage)
  Future<String> createProductWithImages({
    required String name,
    required String description,
    required double price,
    required String unit,
    required double quantity,
    required String category,
    String? location,
    List<File>? images,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload images using alternative storage (instead of Firebase Storage)
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        // This replaces the Firebase Storage upload
        imageUrls = await _storage.uploadImages(images, 'products');
      }

      // Create product model
      final productModel = ProductModel(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        price: price,
        unit: unit,
        quantity: quantity.toInt(),
        category: category,
        imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
        sellerId: currentUserId!,
        sellerName: currentUser?.displayName ?? 'Unknown',
        sellerLocation: location ?? 'Unknown',
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        specifications: specifications,
        rating: 0.0,
        reviewCount: 0,
      );

      // Save to Firestore
      final docRef = await _productsCollection.add(productModel.toMap());
      
      // Update product with generated ID
      await _productsCollection.doc(docRef.id).update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product images
  Future<void> updateProductImages(String productId, List<File> newImages) async {
    try {
      // Upload new images using alternative storage
      List<String> newImageUrls = await _storage.uploadImages(newImages, 'products');

      // Update product in Firestore
      await _productsCollection.doc(productId).update({
        'imageUrl': newImageUrls.isNotEmpty ? newImageUrls.first : null,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update product images: $e');
    }
  }

  /// Delete product and its images
  Future<void> deleteProduct(String productId) async {
    try {
      // Get product to find image URLs
      final productDoc = await _productsCollection.doc(productId).get();
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        final imageUrl = productData['imageUrl'] as String?;

        // Delete image from storage if exists
        if (imageUrl != null) {
          await _storage.deleteImage(imageUrl);
        }
      }

      // Delete product from Firestore
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ========== EXAMPLE: PROFILE IMAGE UPLOAD ==========

  /// Upload profile image using alternative storage
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      if (currentUserId == null) return null;

      // Upload profile image using alternative storage
      final imagePath = await _storage.uploadImage(imageFile, 'profile');

      // Update user profile in Firestore
      await _firestore.collection('users').doc(currentUserId!).update({
        'profileImageUrl': imagePath,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return imagePath;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // ========== EXAMPLE: CROP IMAGE UPLOAD ==========

  /// Upload crop images using alternative storage
  Future<List<String>> uploadCropImages(List<File> images) async {
    try {
      // Upload crop images using alternative storage
      return await _storage.uploadImages(images, 'crops');
    } catch (e) {
      throw Exception('Failed to upload crop images: $e');
    }
  }

  // ========== EXAMPLE: EQUIPMENT IMAGE UPLOAD ==========

  /// Upload equipment images using alternative storage
  Future<List<String>> uploadEquipmentImages(List<File> images) async {
    try {
      // Upload equipment images using alternative storage
      return await _storage.uploadImages(images, 'equipment');
    } catch (e) {
      throw Exception('Failed to upload equipment images: $e');
    }
  }

  // ========== EXAMPLE: HARVEST IMAGE UPLOAD ==========

  /// Upload harvest images using alternative storage
  Future<List<String>> uploadHarvestImages(List<File> images) async {
    try {
      // Upload harvest images using alternative storage
      return await _storage.uploadImages(images, 'harvests');
    } catch (e) {
      throw Exception('Failed to upload harvest images: $e');
    }
  }

  // ========== EXAMPLE: FINANCIAL RECORD IMAGE UPLOAD ==========

  /// Upload financial record images using alternative storage
  Future<List<String>> uploadFinancialImages(List<File> images) async {
    try {
      // Upload financial record images using alternative storage
      return await _storage.uploadImages(images, 'financial');
    } catch (e) {
      throw Exception('Failed to upload financial record images: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Get storage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    return await _storage.getStorageInfo();
  }

  /// Change storage type
  void changeStorageType(StorageType type) {
    _storage.setStorageType(type);
  }

  /// Get current storage type
  StorageType getCurrentStorageType() {
    return _storage.storageType;
  }

  /// Get storage type description
  String getStorageTypeDescription() {
    return _storage.getStorageTypeDescription();
  }

  /// Check if image path is valid
  bool isValidImagePath(String imagePath) {
    return _storage.isValidImagePath(imagePath);
  }
}

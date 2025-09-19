import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/crop_models.dart';
import 'unified_image_storage_service.dart';

class CropService {
  static final CropService _instance = CropService._internal();
  factory CropService() => _instance;
  CropService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UnifiedImageStorageService _storage = UnifiedImageStorageService();

  // Collection references
  CollectionReference get _cropsCollection => _firestore.collection('crops');

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // ========== CROP CRUD OPERATIONS ==========

  /// Create a new crop
  Future<String> createCrop({
    required String name,
    required String variety,
    required DateTime plantedDate,
    DateTime? expectedHarvestDate,
    required double area,
    String? notes,
    List<File>? images,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload images if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _storage.uploadImages(images, 'crops');
      }

      // Create crop document
      final cropDoc = _cropsCollection.doc();
      final crop = CropModel(
        id: cropDoc.id,
        userId: currentUserId!,
        name: name,
        variety: variety,
        plantedDate: plantedDate,
        expectedHarvestDate: expectedHarvestDate,
        status: 'planted',
        area: area,
        notes: notes,
        imageUrls: imageUrls,
        additionalData: additionalData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await cropDoc.set(crop.toMap());
      return cropDoc.id;
    } catch (e) {
      throw Exception('Failed to create crop: $e');
    }
  }

  /// Get all crops for current user
  Future<List<CropModel>> getAllCrops({String? status}) async {
    try {
      debugPrint('=== CROP SERVICE DEBUG ===');
      debugPrint('Current user: ${currentUser?.uid}');
      debugPrint('Current user ID: $currentUserId');
      debugPrint('User authenticated: ${currentUser != null}');
      
      if (currentUserId == null) {
        debugPrint('ERROR: User not authenticated');
        throw Exception('User not authenticated');
      }

      debugPrint('Building query for user: $currentUserId');
      Query query = _cropsCollection.where('userId', isEqualTo: currentUserId);
      
      if (status != null && status.isNotEmpty) {
        debugPrint('Filtering by status: $status');
        query = query.where('status', isEqualTo: status);
      }

      debugPrint('Executing Firestore query...');
      final querySnapshot = await query.orderBy('createdAt', descending: true).get();
      
      debugPrint('Query executed successfully. Found ${querySnapshot.docs.length} documents');
      
      final crops = querySnapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          debugPrint('Processing crop document: ${doc.id}');
          debugPrint('Crop data: $data');
          return CropModel.fromMap(data);
        } catch (e) {
          debugPrint('Error processing document ${doc.id}: $e');
          rethrow;
        }
      }).toList();
      
      debugPrint('Successfully processed ${crops.length} crops');
      return crops;
    } catch (e) {
      debugPrint('ERROR in getAllCrops: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to get crops: $e');
    }
  }

  /// Get crop by ID
  Future<CropModel?> getCropById(String cropId) async {
    try {
      final doc = await _cropsCollection.doc(cropId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CropModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get crop: $e');
    }
  }

  /// Update crop
  Future<void> updateCrop({
    required String cropId,
    String? name,
    String? variety,
    DateTime? plantedDate,
    DateTime? expectedHarvestDate,
    String? status,
    double? area,
    String? notes,
    List<File>? newImages,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get existing crop
      final existingCrop = await getCropById(cropId);
      if (existingCrop == null) {
        throw Exception('Crop not found');
      }

      // Upload new images if provided
      List<String> imageUrls = List.from(existingCrop.imageUrls);
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          final imageUrl = await _uploadCropImage(currentUserId!, newImages[i], i);
          imageUrls.add(imageUrl);
        }
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (variety != null) updateData['variety'] = variety;
      if (plantedDate != null) updateData['plantedDate'] = plantedDate.toIso8601String();
      if (expectedHarvestDate != null) updateData['expectedHarvestDate'] = expectedHarvestDate.toIso8601String();
      if (status != null) updateData['status'] = status;
      if (area != null) updateData['area'] = area;
      if (notes != null) updateData['notes'] = notes;
      if (imageUrls.isNotEmpty) updateData['imageUrls'] = imageUrls;
      if (additionalData != null) updateData['additionalData'] = additionalData;

      await _cropsCollection.doc(cropId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update crop: $e');
    }
  }

  /// Delete crop
  Future<void> deleteCrop(String cropId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get crop to delete images
      final crop = await getCropById(cropId);
      if (crop != null) {
        // Delete images from storage
        for (String imageUrl in crop.imageUrls) {
          try {
            await _storage.deleteImage(imageUrl);
          } catch (e) {
            debugPrint('Failed to delete image: $e');
          }
        }
      }

      await _cropsCollection.doc(cropId).delete();
    } catch (e) {
      throw Exception('Failed to delete crop: $e');
    }
  }

  /// Update crop status
  Future<void> updateCropStatus(String cropId, String status) async {
    try {
      await _cropsCollection.doc(cropId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update crop status: $e');
    }
  }

  /// Get crops by status
  Future<List<CropModel>> getCropsByStatus(String status) async {
    try {
      return await getAllCrops(status: status);
    } catch (e) {
      throw Exception('Failed to get crops by status: $e');
    }
  }

  /// Search crops
  Future<List<CropModel>> searchCrops(String query) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final allCrops = await getAllCrops();
      return allCrops.where((crop) {
        return crop.name.toLowerCase().contains(query.toLowerCase()) ||
               crop.variety.toLowerCase().contains(query.toLowerCase()) ||
               (crop.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search crops: $e');
    }
  }

  /// Get crop statistics
  Future<Map<String, dynamic>> getCropStatistics() async {
    try {
      final crops = await getAllCrops();
      
      final totalCrops = crops.length;
      final plantedCrops = crops.where((c) => c.status == 'planted').length;
      final growingCrops = crops.where((c) => c.status == 'growing').length;
      final readyCrops = crops.where((c) => c.status == 'ready').length;
      final harvestedCrops = crops.where((c) => c.status == 'harvested').length;
      final totalArea = crops.fold(0.0, (sum, crop) => sum + crop.area);

      return {
        'totalCrops': totalCrops,
        'plantedCrops': plantedCrops,
        'growingCrops': growingCrops,
        'readyCrops': readyCrops,
        'harvestedCrops': harvestedCrops,
        'totalArea': totalArea,
      };
    } catch (e) {
      throw Exception('Failed to get crop statistics: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Upload crop image using unified storage
  Future<String> _uploadCropImage(String userId, File image, int index) async {
    try {
      return await _storage.uploadImage(image, 'crops', index: index);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Get available crop statuses
  List<String> getCropStatuses() {
    return ['planted', 'growing', 'ready', 'harvested'];
  }

  /// Get crop status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planted':
        return '#4CAF50'; // Green
      case 'growing':
        return '#2196F3'; // Blue
      case 'ready':
        return '#FF9800'; // Orange
      case 'harvested':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  Future<void> addCrop(CropModel newCrop) async {
    try {
      debugPrint('=== ADD CROP DEBUG ===');
      debugPrint('Adding crop: ${newCrop.name}');
      debugPrint('User ID: $currentUserId');
      
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the crop has the correct user ID
      final cropToAdd = CropModel(
        id: newCrop.id,
        userId: currentUserId!,
        name: newCrop.name,
        variety: newCrop.variety,
        plantedDate: newCrop.plantedDate,
        expectedHarvestDate: newCrop.expectedHarvestDate,
        status: newCrop.status,
        area: newCrop.area,
        notes: newCrop.notes,
        imageUrls: newCrop.imageUrls,
        additionalData: newCrop.additionalData,
        createdAt: newCrop.createdAt,
        updatedAt: newCrop.updatedAt,
      );

      debugPrint('Saving crop to Firestore...');
      await _cropsCollection.doc(cropToAdd.id).set(cropToAdd.toMap());
      debugPrint('Crop saved successfully with ID: ${cropToAdd.id}');
    } catch (e) {
      debugPrint('ERROR adding crop: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to add crop: $e');
    }
  }

  /// Debug method to create sample crop data for testing
  Future<void> createSampleCrops() async {
    try {
      if (currentUserId == null) {
        debugPrint('Cannot create sample crops: User not authenticated');
        return;
      }

      debugPrint('Creating sample crops for user: $currentUserId');

      // Sample crop 1
      await createCrop(
        name: 'Rice - Basmati',
        variety: 'Basmati 370',
        plantedDate: DateTime.now().subtract(const Duration(days: 30)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 90)),
        area: 2.5,
        notes: 'Sample rice crop for testing',
      );

      // Sample crop 2
      await createCrop(
        name: 'Wheat - Durum',
        variety: 'Durum Wheat',
        plantedDate: DateTime.now().subtract(const Duration(days: 15)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 120)),
        area: 1.8,
        notes: 'Sample wheat crop for testing',
        additionalData: {
          'soilType': 'Loamy',
          'irrigation': 'Drip',
        },
      );

      // Sample crop 3
      await createCrop(
        name: 'Corn - Sweet',
        variety: 'Sweet Corn Hybrid',
        plantedDate: DateTime.now().subtract(const Duration(days: 45)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 60)),
        area: 3.2,
        notes: 'Sample corn crop for testing',
        additionalData: {
          'soilType': 'Sandy Loam',
          'irrigation': 'Sprinkler',
        },
      );

      debugPrint('Sample crops created successfully');
    } catch (e) {
      debugPrint('Error creating sample crops: $e');
    }
  }
}

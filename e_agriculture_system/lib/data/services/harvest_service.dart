import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/harvest_model.dart';
import 'unified_image_storage_service.dart';

class HarvestService {
  static final HarvestService _instance = HarvestService._internal();
  factory HarvestService() => _instance;
  HarvestService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UnifiedImageStorageService _storage = UnifiedImageStorageService();

  // Collection references
  CollectionReference get _harvestsCollection => _firestore.collection('harvests');

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // ========== HARVEST CRUD OPERATIONS ==========

  /// Create a new harvest record
  Future<String> createHarvest({
    required String cropId,
    required String cropName,
    required DateTime harvestDate,
    required double quantity,
    required String unit,
    String quality = 'good',
    double? pricePerUnit,
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
        imageUrls = await _storage.uploadImages(images, 'harvests');
      }

      // Create harvest document
      final harvestDoc = _harvestsCollection.doc();
      final harvest = HarvestModel(
        id: harvestDoc.id,
        userId: currentUserId!,
        cropId: cropId,
        cropName: cropName,
        harvestDate: harvestDate,
        quantity: quantity,
        unit: unit,
        quality: quality,
        pricePerUnit: pricePerUnit,
        notes: notes,
        imageUrls: imageUrls,
        status: 'completed',
        additionalData: additionalData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await harvestDoc.set(harvest.toMap());
      return harvestDoc.id;
    } catch (e) {
      throw Exception('Failed to create harvest: $e');
    }
  }

  /// Get all harvests for current user
  Future<List<HarvestModel>> getAllHarvests({String? status}) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _harvestsCollection.where('userId', isEqualTo: currentUserId);
      
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.orderBy('harvestDate', descending: true).get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HarvestModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get harvests: $e');
    }
  }

  /// Get harvest by ID
  Future<HarvestModel?> getHarvestById(String harvestId) async {
    try {
      final doc = await _harvestsCollection.doc(harvestId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HarvestModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get harvest: $e');
    }
  }

  /// Update harvest
  Future<void> updateHarvest({
    required String harvestId,
    DateTime? harvestDate,
    double? quantity,
    String? unit,
    String? quality,
    double? pricePerUnit,
    String? notes,
    String? status,
    List<File>? newImages,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get existing harvest
      final existingHarvest = await getHarvestById(harvestId);
      if (existingHarvest == null) {
        throw Exception('Harvest not found');
      }

      // Upload new images if provided
      List<String> imageUrls = List.from(existingHarvest.imageUrls);
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          final imageUrl = await _uploadHarvestImage(currentUserId!, newImages[i], i);
          imageUrls.add(imageUrl);
        }
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (harvestDate != null) updateData['harvestDate'] = harvestDate.toIso8601String();
      if (quantity != null) updateData['quantity'] = quantity;
      if (unit != null) updateData['unit'] = unit;
      if (quality != null) updateData['quality'] = quality;
      if (pricePerUnit != null) updateData['pricePerUnit'] = pricePerUnit;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;
      if (imageUrls.isNotEmpty) updateData['imageUrls'] = imageUrls;
      if (additionalData != null) updateData['additionalData'] = additionalData;

      await _harvestsCollection.doc(harvestId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update harvest: $e');
    }
  }

  /// Delete harvest
  Future<void> deleteHarvest(String harvestId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get harvest to delete images
      final harvest = await getHarvestById(harvestId);
      if (harvest != null) {
        // Delete images from storage
        for (String imageUrl in harvest.imageUrls) {
          try {
            await _storage.deleteImage(imageUrl);
          } catch (e) {
            debugPrint('Failed to delete image: $e');
          }
        }
      }

      await _harvestsCollection.doc(harvestId).delete();
    } catch (e) {
      throw Exception('Failed to delete harvest: $e');
    }
  }

  /// Update harvest status
  Future<void> updateHarvestStatus(String harvestId, String status) async {
    try {
      await _harvestsCollection.doc(harvestId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update harvest status: $e');
    }
  }

  /// Get harvests by crop
  Future<List<HarvestModel>> getHarvestsByCrop(String cropId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _harvestsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('cropId', isEqualTo: cropId)
          .orderBy('harvestDate', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HarvestModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get harvests by crop: $e');
    }
  }

  /// Get harvests by date range
  Future<List<HarvestModel>> getHarvestsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _harvestsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('harvestDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('harvestDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('harvestDate', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return HarvestModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get harvests by date range: $e');
    }
  }

  /// Search harvests
  Future<List<HarvestModel>> searchHarvests(String query) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final allHarvests = await getAllHarvests();
      return allHarvests.where((harvest) {
        return harvest.cropName.toLowerCase().contains(query.toLowerCase()) ||
               (harvest.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search harvests: $e');
    }
  }

  /// Get harvest statistics
  Future<Map<String, dynamic>> getHarvestStatistics() async {
    try {
      final harvests = await getAllHarvests();
      
      final totalHarvests = harvests.length;
      final totalQuantity = harvests.fold(0.0, (sum, harvest) => sum + harvest.quantity);
      final totalValue = harvests.fold(0.0, (sum, harvest) {
        if (harvest.pricePerUnit != null) {
          return sum + (harvest.quantity * harvest.pricePerUnit!);
        }
        return sum;
      });

      // Group by quality
      final qualityStats = <String, int>{};
      for (var harvest in harvests) {
        qualityStats[harvest.quality] = (qualityStats[harvest.quality] ?? 0) + 1;
      }

      // Group by status
      final statusStats = <String, int>{};
      for (var harvest in harvests) {
        statusStats[harvest.status] = (statusStats[harvest.status] ?? 0) + 1;
      }

      return {
        'totalHarvests': totalHarvests,
        'totalQuantity': totalQuantity,
        'totalValue': totalValue,
        'qualityStats': qualityStats,
        'statusStats': statusStats,
      };
    } catch (e) {
      throw Exception('Failed to get harvest statistics: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Upload harvest image using unified storage
  Future<String> _uploadHarvestImage(String userId, File image, int index) async {
    try {
      return await _storage.uploadImage(image, 'harvests', index: index);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Get available harvest statuses
  List<String> getHarvestStatuses() {
    return ['planned', 'in-progress', 'completed', 'sold'];
  }

  /// Get available harvest qualities
  List<String> getHarvestQualities() {
    return ['excellent', 'good', 'fair', 'poor'];
  }

  /// Get harvest status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return '#2196F3'; // Blue
      case 'in-progress':
        return '#FF9800'; // Orange
      case 'completed':
        return '#4CAF50'; // Green
      case 'sold':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  /// Get harvest quality color
  static String getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return '#4CAF50'; // Green
      case 'good':
        return '#2196F3'; // Blue
      case 'fair':
        return '#FF9800'; // Orange
      case 'poor':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }
}

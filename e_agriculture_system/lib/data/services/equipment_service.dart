import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/equipment_model.dart';
import 'unified_image_storage_service.dart';

class EquipmentService {
  static final EquipmentService _instance = EquipmentService._internal();
  factory EquipmentService() => _instance;
  EquipmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UnifiedImageStorageService _storage = UnifiedImageStorageService();

  // Collection references
  CollectionReference get _equipmentCollection => _firestore.collection('equipment');

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // ========== EQUIPMENT CRUD OPERATIONS ==========

  /// Create a new equipment
  Future<String> createEquipment({
    required String name,
    required String category,
    required String description,
    String status = 'operational',
    DateTime? purchaseDate,
    double? purchasePrice,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    double? maintenanceCost,
    String? maintenanceNotes,
    List<File>? images,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload images if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _storage.uploadImages(images, 'equipment');
      }

      // Create equipment document
      final equipmentDoc = _equipmentCollection.doc();
      final equipment = EquipmentModel(
        id: equipmentDoc.id,
        userId: currentUserId!,
        name: name,
        category: category,
        description: description,
        status: status,
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        lastMaintenance: lastMaintenance,
        nextMaintenance: nextMaintenance,
        maintenanceCost: maintenanceCost,
        maintenanceNotes: maintenanceNotes,
        imageUrls: imageUrls,
        specifications: specifications,
        additionalData: additionalData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await equipmentDoc.set(equipment.toMap());
      return equipmentDoc.id;
    } catch (e) {
      throw Exception('Failed to create equipment: $e');
    }
  }

  /// Get all equipment for current user
  Future<List<EquipmentModel>> getAllEquipment({String? status, String? category}) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _equipmentCollection.where('userId', isEqualTo: currentUserId);
      
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.orderBy('createdAt', descending: true).get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EquipmentModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment: $e');
    }
  }

  /// Get equipment by ID
  Future<EquipmentModel?> getEquipmentById(String equipmentId) async {
    try {
      final doc = await _equipmentCollection.doc(equipmentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EquipmentModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get equipment: $e');
    }
  }

  /// Update equipment
  Future<void> updateEquipment({
    required String equipmentId,
    String? name,
    String? category,
    String? description,
    String? status,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    double? maintenanceCost,
    String? maintenanceNotes,
    List<File>? newImages,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get existing equipment
      final existingEquipment = await getEquipmentById(equipmentId);
      if (existingEquipment == null) {
        throw Exception('Equipment not found');
      }

      // Upload new images if provided
      List<String> imageUrls = List.from(existingEquipment.imageUrls);
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          final imageUrl = await _uploadEquipmentImage(currentUserId!, newImages[i], i);
          imageUrls.add(imageUrl);
        }
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (description != null) updateData['description'] = description;
      if (status != null) updateData['status'] = status;
      if (purchaseDate != null) updateData['purchaseDate'] = purchaseDate.toIso8601String();
      if (purchasePrice != null) updateData['purchasePrice'] = purchasePrice;
      if (manufacturer != null) updateData['manufacturer'] = manufacturer;
      if (model != null) updateData['model'] = model;
      if (serialNumber != null) updateData['serialNumber'] = serialNumber;
      if (lastMaintenance != null) updateData['lastMaintenance'] = lastMaintenance.toIso8601String();
      if (nextMaintenance != null) updateData['nextMaintenance'] = nextMaintenance.toIso8601String();
      if (maintenanceCost != null) updateData['maintenanceCost'] = maintenanceCost;
      if (maintenanceNotes != null) updateData['maintenanceNotes'] = maintenanceNotes;
      if (imageUrls.isNotEmpty) updateData['imageUrls'] = imageUrls;
      if (specifications != null) updateData['specifications'] = specifications;
      if (additionalData != null) updateData['additionalData'] = additionalData;

      await _equipmentCollection.doc(equipmentId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update equipment: $e');
    }
  }

  /// Delete equipment
  Future<void> deleteEquipment(String equipmentId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get equipment to delete images
      final equipment = await getEquipmentById(equipmentId);
      if (equipment != null) {
        // Delete images from storage
        for (String imageUrl in equipment.imageUrls) {
          try {
            await _storage.deleteImage(imageUrl);
          } catch (e) {
            debugPrint('Failed to delete image: $e');
          }
        }
      }

      await _equipmentCollection.doc(equipmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete equipment: $e');
    }
  }

  /// Update equipment status
  Future<void> updateEquipmentStatus(String equipmentId, String status) async {
    try {
      await _equipmentCollection.doc(equipmentId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update equipment status: $e');
    }
  }

  /// Update maintenance information
  Future<void> updateMaintenance({
    required String equipmentId,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    double? maintenanceCost,
    String? maintenanceNotes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (lastMaintenance != null) updateData['lastMaintenance'] = lastMaintenance.toIso8601String();
      if (nextMaintenance != null) updateData['nextMaintenance'] = nextMaintenance.toIso8601String();
      if (maintenanceCost != null) updateData['maintenanceCost'] = maintenanceCost;
      if (maintenanceNotes != null) updateData['maintenanceNotes'] = maintenanceNotes;

      await _equipmentCollection.doc(equipmentId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update maintenance: $e');
    }
  }

  /// Get equipment by status
  Future<List<EquipmentModel>> getEquipmentByStatus(String status) async {
    try {
      return await getAllEquipment(status: status);
    } catch (e) {
      throw Exception('Failed to get equipment by status: $e');
    }
  }

  /// Get equipment by category
  Future<List<EquipmentModel>> getEquipmentByCategory(String category) async {
    try {
      return await getAllEquipment(category: category);
    } catch (e) {
      throw Exception('Failed to get equipment by category: $e');
    }
  }

  /// Get equipment requiring maintenance
  Future<List<EquipmentModel>> getEquipmentRequiringMaintenance() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final querySnapshot = await _equipmentCollection
          .where('userId', isEqualTo: currentUserId)
          .where('nextMaintenance', isLessThanOrEqualTo: now.toIso8601String())
          .orderBy('nextMaintenance', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EquipmentModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment requiring maintenance: $e');
    }
  }

  /// Search equipment
  Future<List<EquipmentModel>> searchEquipment(String query) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final allEquipment = await getAllEquipment();
      return allEquipment.where((equipment) {
        return equipment.name.toLowerCase().contains(query.toLowerCase()) ||
               equipment.description.toLowerCase().contains(query.toLowerCase()) ||
               (equipment.manufacturer?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (equipment.model?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search equipment: $e');
    }
  }

  /// Get equipment statistics
  Future<Map<String, dynamic>> getEquipmentStatistics() async {
    try {
      final equipment = await getAllEquipment();
      
      final totalEquipment = equipment.length;
      final operationalEquipment = equipment.where((e) => e.status == 'operational').length;
      final maintenanceEquipment = equipment.where((e) => e.status == 'maintenance').length;
      final repairEquipment = equipment.where((e) => e.status == 'repair').length;
      final retiredEquipment = equipment.where((e) => e.status == 'retired').length;

      // Group by category
      final categoryStats = <String, int>{};
      for (var equip in equipment) {
        categoryStats[equip.category] = (categoryStats[equip.category] ?? 0) + 1;
      }

      // Calculate total value
      final totalValue = equipment.fold(0.0, (sum, equip) {
        return sum + (equip.purchasePrice ?? 0.0);
      });

      // Equipment requiring maintenance
      final requiringMaintenance = equipment.where((e) {
        if (e.nextMaintenance == null) return false;
        return e.nextMaintenance!.isBefore(DateTime.now());
      }).length;

      return {
        'totalEquipment': totalEquipment,
        'operationalEquipment': operationalEquipment,
        'maintenanceEquipment': maintenanceEquipment,
        'repairEquipment': repairEquipment,
        'retiredEquipment': retiredEquipment,
        'categoryStats': categoryStats,
        'totalValue': totalValue,
        'requiringMaintenance': requiringMaintenance,
      };
    } catch (e) {
      throw Exception('Failed to get equipment statistics: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Upload equipment image using unified storage
  Future<String> _uploadEquipmentImage(String userId, File image, int index) async {
    try {
      return await _storage.uploadImage(image, 'equipment', index: index);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Get available equipment statuses
  List<String> getEquipmentStatuses() {
    return ['operational', 'maintenance', 'repair', 'retired'];
  }

  /// Get available equipment categories
  List<String> getEquipmentCategories() {
    return ['machinery', 'implements', 'irrigation', 'tools', 'vehicles'];
  }

  /// Get equipment status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
        return '#4CAF50'; // Green
      case 'maintenance':
        return '#FF9800'; // Orange
      case 'repair':
        return '#F44336'; // Red
      case 'retired':
        return '#757575'; // Grey
      default:
        return '#757575'; // Grey
    }
  }

  /// Get equipment category icon
  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'machinery':
        return '🚜';
      case 'implements':
        return '🔧';
      case 'irrigation':
        return '💧';
      case 'tools':
        return '🔨';
      case 'vehicles':
        return '🚗';
      default:
        return '⚙️';
    }
  }
}

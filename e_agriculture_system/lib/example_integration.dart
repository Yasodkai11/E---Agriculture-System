import 'package:flutter/material.dart';
import 'data/services/crop_service.dart';
import 'data/services/equipment_service.dart';
import 'data/services/harvest_service.dart';
import 'data/services/enhanced_user_service.dart';
import 'data/models/crop_models.dart';
import 'data/models/equipment_model.dart';
import 'data/models/harvest_model.dart';
import 'data/models/user_model.dart';

/// Comprehensive example demonstrating all CRUD operations
/// for Harvest, Equipment, Crop, and Profile data
class DataManagementExample {
  final CropService _cropService = CropService();
  final EquipmentService _equipmentService = EquipmentService();
  final HarvestService _harvestService = HarvestService();
  final EnhancedUserService _userService = EnhancedUserService();

  // ========== CROP MANAGEMENT EXAMPLES ==========

  /// Create a new crop
  Future<String> createCropExample() async {
    try {
      final cropId = await _cropService.createCrop(
        name: 'Wheat',
        variety: 'Winter Wheat',
        plantedDate: DateTime.now(),
        expectedHarvestDate: DateTime.now().add(Duration(days: 120)),
        area: 25.5,
        notes: 'Planted in field A, using organic fertilizer',
        additionalData: {
          'soilType': 'Loamy',
          'fertilizerUsed': 'Organic NPK',
          'irrigationType': 'Drip',
        },
      );
      
      print('Crop created successfully with ID: $cropId');
      return cropId;
    } catch (e) {
      print('Failed to create crop: $e');
      rethrow;
    }
  }

  /// Get all crops for current user
  Future<List<CropModel>> getAllCropsExample() async {
    try {
      final crops = await _cropService.getAllCrops();
      print('Found ${crops.length} crops');
      
      for (var crop in crops) {
        print('Crop: ${crop.name} - ${crop.variety} - Status: ${crop.status}');
      }
      
      return crops;
    } catch (e) {
      print('Failed to get crops: $e');
      rethrow;
    }
  }

  /// Get crops by status
  Future<List<CropModel>> getCropsByStatusExample() async {
    try {
      final growingCrops = await _cropService.getCropsByStatus('growing');
      print('Found ${growingCrops.length} growing crops');
      return growingCrops;
    } catch (e) {
      print('Failed to get crops by status: $e');
      rethrow;
    }
  }

  /// Update crop information
  Future<void> updateCropExample(String cropId) async {
    try {
      await _cropService.updateCrop(
        cropId: cropId,
        status: 'growing',
        notes: 'Crop is growing well, added additional irrigation',
        additionalData: {
          'lastIrrigation': DateTime.now().toIso8601String(),
          'pestControlApplied': 'Organic neem oil',
        },
      );
      
      print('Crop updated successfully');
    } catch (e) {
      print('Failed to update crop: $e');
      rethrow;
    }
  }

  /// Delete a crop
  Future<void> deleteCropExample(String cropId) async {
    try {
      await _cropService.deleteCrop(cropId);
      print('Crop deleted successfully');
    } catch (e) {
      print('Failed to delete crop: $e');
      rethrow;
    }
  }

  /// Search crops
  Future<List<CropModel>> searchCropsExample(String query) async {
    try {
      final results = await _cropService.searchCrops(query);
      print('Found ${results.length} crops matching "$query"');
      return results;
    } catch (e) {
      print('Failed to search crops: $e');
      rethrow;
    }
  }

  /// Get crop statistics
  Future<Map<String, dynamic>> getCropStatisticsExample() async {
    try {
      final stats = await _cropService.getCropStatistics();
      print('Crop Statistics: $stats');
      return stats;
    } catch (e) {
      print('Failed to get crop statistics: $e');
      rethrow;
    }
  }

  // ========== EQUIPMENT MANAGEMENT EXAMPLES ==========

  /// Create new equipment
  Future<String> createEquipmentExample() async {
    try {
      final equipmentId = await _equipmentService.createEquipment(
        name: 'Tractor',
        category: 'machinery',
        description: 'John Deere 5075E tractor for field operations',
        status: 'operational',
        purchaseDate: DateTime.now().subtract(Duration(days: 365)),
        purchasePrice: 45000.0,
        manufacturer: 'John Deere',
        model: '5075E',
        serialNumber: 'JD5075E-2023-001',
        lastMaintenance: DateTime.now().subtract(Duration(days: 30)),
        nextMaintenance: DateTime.now().add(Duration(days: 30)),
        maintenanceCost: 500.0,
        maintenanceNotes: 'Regular oil change and filter replacement',
        specifications: {
          'horsepower': 75,
          'fuelType': 'Diesel',
          'transmission': '12F/12R',
        },
      );
      
      print('Equipment created successfully with ID: $equipmentId');
      return equipmentId;
    } catch (e) {
      print('Failed to create equipment: $e');
      rethrow;
    }
  }

  /// Get all equipment
  Future<List<EquipmentModel>> getAllEquipmentExample() async {
    try {
      final equipment = await _equipmentService.getAllEquipment();
      print('Found ${equipment.length} equipment items');
      
      for (var equip in equipment) {
        print('Equipment: ${equip.name} - ${equip.category} - Status: ${equip.status}');
      }
      
      return equipment;
    } catch (e) {
      print('Failed to get equipment: $e');
      rethrow;
    }
  }

  /// Get equipment by category
  Future<List<EquipmentModel>> getEquipmentByCategoryExample() async {
    try {
      final machinery = await _equipmentService.getEquipmentByCategory('machinery');
      print('Found ${machinery.length} machinery items');
      return machinery;
    } catch (e) {
      print('Failed to get equipment by category: $e');
      rethrow;
    }
  }

  /// Update equipment
  Future<void> updateEquipmentExample(String equipmentId) async {
    try {
      await _equipmentService.updateEquipment(
        equipmentId: equipmentId,
        status: 'maintenance',
        lastMaintenance: DateTime.now(),
        nextMaintenance: DateTime.now().add(Duration(days: 60)),
        maintenanceNotes: 'Scheduled maintenance completed, replaced air filter',
      );
      
      print('Equipment updated successfully');
    } catch (e) {
      print('Failed to update equipment: $e');
      rethrow;
    }
  }

  /// Update maintenance information
  Future<void> updateMaintenanceExample(String equipmentId) async {
    try {
      await _equipmentService.updateMaintenance(
        equipmentId: equipmentId,
        lastMaintenance: DateTime.now(),
        nextMaintenance: DateTime.now().add(Duration(days: 90)),
        maintenanceCost: 750.0,
        maintenanceNotes: 'Major service including hydraulic fluid change',
      );
      
      print('Maintenance information updated successfully');
    } catch (e) {
      print('Failed to update maintenance: $e');
      rethrow;
    }
  }

  /// Get equipment requiring maintenance
  Future<List<EquipmentModel>> getEquipmentRequiringMaintenanceExample() async {
    try {
      final maintenanceNeeded = await _equipmentService.getEquipmentRequiringMaintenance();
      print('Found ${maintenanceNeeded.length} equipment items requiring maintenance');
      return maintenanceNeeded;
    } catch (e) {
      print('Failed to get equipment requiring maintenance: $e');
      rethrow;
    }
  }

  /// Delete equipment
  Future<void> deleteEquipmentExample(String equipmentId) async {
    try {
      await _equipmentService.deleteEquipment(equipmentId);
      print('Equipment deleted successfully');
    } catch (e) {
      print('Failed to delete equipment: $e');
      rethrow;
    }
  }

  /// Get equipment statistics
  Future<Map<String, dynamic>> getEquipmentStatisticsExample() async {
    try {
      final stats = await _equipmentService.getEquipmentStatistics();
      print('Equipment Statistics: $stats');
      return stats;
    } catch (e) {
      print('Failed to get equipment statistics: $e');
      rethrow;
    }
  }

  // ========== HARVEST MANAGEMENT EXAMPLES ==========

  /// Create harvest record
  Future<String> createHarvestExample(String cropId) async {
    try {
      final harvestId = await _harvestService.createHarvest(
        cropId: cropId,
        cropName: 'Wheat',
        harvestDate: DateTime.now(),
        quantity: 1500.0,
        unit: 'kg',
        quality: 'excellent',
        pricePerUnit: 2.5,
        notes: 'Excellent harvest with high grain quality',
        additionalData: {
          'harvestMethod': 'Combine harvester',
          'weatherConditions': 'Clear and dry',
          'storageLocation': 'Grain silo A',
        },
      );
      
      print('Harvest record created successfully with ID: $harvestId');
      return harvestId;
    } catch (e) {
      print('Failed to create harvest: $e');
      rethrow;
    }
  }

  /// Get all harvests
  Future<List<HarvestModel>> getAllHarvestsExample() async {
    try {
      final harvests = await _harvestService.getAllHarvests();
      print('Found ${harvests.length} harvest records');
      
      for (var harvest in harvests) {
        print('Harvest: ${harvest.cropName} - ${harvest.quantity} ${harvest.unit} - Quality: ${harvest.quality}');
      }
      
      return harvests;
    } catch (e) {
      print('Failed to get harvests: $e');
      rethrow;
    }
  }

  /// Get harvests by crop
  Future<List<HarvestModel>> getHarvestsByCropExample(String cropId) async {
    try {
      final cropHarvests = await _harvestService.getHarvestsByCrop(cropId);
      print('Found ${cropHarvests.length} harvest records for crop $cropId');
      return cropHarvests;
    } catch (e) {
      print('Failed to get harvests by crop: $e');
      rethrow;
    }
  }

  /// Get harvests by date range
  Future<List<HarvestModel>> getHarvestsByDateRangeExample() async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: 30));
      final endDate = DateTime.now();
      
      final harvests = await _harvestService.getHarvestsByDateRange(startDate, endDate);
      print('Found ${harvests.length} harvest records in the last 30 days');
      return harvests;
    } catch (e) {
      print('Failed to get harvests by date range: $e');
      rethrow;
    }
  }

  /// Update harvest
  Future<void> updateHarvestExample(String harvestId) async {
    try {
      await _harvestService.updateHarvest(
        harvestId: harvestId,
        status: 'sold',
        notes: 'Harvest sold to local mill at premium price',
        additionalData: {
          'soldDate': DateTime.now().toIso8601String(),
          'buyer': 'Local Mill Co.',
          'salePrice': 3750.0,
        },
      );
      
      print('Harvest updated successfully');
    } catch (e) {
      print('Failed to update harvest: $e');
      rethrow;
    }
  }

  /// Delete harvest
  Future<void> deleteHarvestExample(String harvestId) async {
    try {
      await _harvestService.deleteHarvest(harvestId);
      print('Harvest record deleted successfully');
    } catch (e) {
      print('Failed to delete harvest: $e');
      rethrow;
    }
  }

  /// Get harvest statistics
  Future<Map<String, dynamic>> getHarvestStatisticsExample() async {
    try {
      final stats = await _harvestService.getHarvestStatistics();
      print('Harvest Statistics: $stats');
      return stats;
    } catch (e) {
      print('Failed to get harvest statistics: $e');
      rethrow;
    }
  }

  // ========== PROFILE MANAGEMENT EXAMPLES ==========

  /// Create user profile
  Future<UserModel> createUserProfileExample() async {
    try {
      final user = await _userService.createUserWithDetails(
        uid: 'example_user_id',
        fullName: 'John Farmer',
        email: 'john.farmer@example.com',
        phoneNumber: '+1234567890',
        userType: 'farmer',
        location: 'Springfield, IL',
        latitude: 39.7817,
        longitude: -89.6501,
        preferences: {
          'notifications': true,
          'language': 'en',
          'units': 'metric',
          'cropTypes': ['wheat', 'corn', 'soybeans'],
        },
      );
      
      print('User profile created successfully: ${user.fullName}');
      return user;
    } catch (e) {
      print('Failed to create user profile: $e');
      rethrow;
    }
  }

  /// Get current user data
  Future<UserModel?> getCurrentUserExample() async {
    try {
      final user = await _userService.getCurrentUserData();
      if (user != null) {
        print('Current user: ${user.fullName} - ${user.userType}');
      } else {
        print('No current user found');
      }
      return user;
    } catch (e) {
      print('Failed to get current user: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfileExample(String userId) async {
    try {
      final updatedUser = await _userService.updateUserProfile(
        userId: userId,
        location: 'New Springfield, IL',
        preferences: {
          'notifications': true,
          'language': 'en',
          'units': 'imperial',
          'cropTypes': ['wheat', 'corn', 'soybeans', 'cotton'],
          'weatherAlerts': true,
        },
      );
      
      print('User profile updated successfully: ${updatedUser.fullName}');
      return updatedUser;
    } catch (e) {
      print('Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferencesExample(String userId) async {
    try {
      await _userService.updateUserPreferences(userId, {
        'notifications': true,
        'language': 'en',
        'units': 'metric',
        'cropTypes': ['wheat', 'corn'],
        'weatherAlerts': true,
        'marketUpdates': true,
        'expertConsultation': false,
      });
      
      print('User preferences updated successfully');
    } catch (e) {
      print('Failed to update user preferences: $e');
      rethrow;
    }
  }

  /// Search users
  Future<List<UserModel>> searchUsersExample(String query) async {
    try {
      final users = await _userService.searchUsers(query);
      print('Found ${users.length} users matching "$query"');
      return users;
    } catch (e) {
      print('Failed to search users: $e');
      rethrow;
    }
  }

  /// Get users by type
  Future<List<UserModel>> getUsersByTypeExample() async {
    try {
      final experts = await _userService.getUsersByType('expert');
      print('Found ${experts.length} expert users');
      return experts;
    } catch (e) {
      print('Failed to get users by type: $e');
      rethrow;
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatisticsExample(String userId) async {
    try {
      final stats = await _userService.getUserStatistics(userId);
      print('User Statistics: $stats');
      return stats;
    } catch (e) {
      print('Failed to get user statistics: $e');
      rethrow;
    }
  }

  // ========== COMPREHENSIVE DATA MANAGEMENT ==========

  /// Complete workflow example: Create crop, equipment, harvest, and update profile
  Future<void> completeWorkflowExample() async {
    try {
      print('=== Starting Complete Workflow Example ===');
      
      // 1. Create a crop
      final cropId = await createCropExample();
      
      // 2. Create equipment
      final equipmentId = await createEquipmentExample();
      
      // 3. Create harvest record
      final harvestId = await createHarvestExample(cropId);
      
      // 4. Update crop status to harvested
      await updateCropExample(cropId);
      
      // 5. Update equipment maintenance
      await updateMaintenanceExample(equipmentId);
      
      // 6. Update harvest status to sold
      await updateHarvestExample(harvestId);
      
      // 7. Get statistics for all entities
      final cropStats = await getCropStatisticsExample();
      final equipmentStats = await getEquipmentStatisticsExample();
      final harvestStats = await getHarvestStatisticsExample();
      
      print('=== Workflow Completed Successfully ===');
      print('Crop Stats: $cropStats');
      print('Equipment Stats: $equipmentStats');
      print('Harvest Stats: $harvestStats');
      
    } catch (e) {
      print('Workflow failed: $e');
    }
  }

  /// Data cleanup example
  Future<void> cleanupDataExample() async {
    try {
      print('=== Starting Data Cleanup ===');
      
      // Get all data
      final crops = await getAllCropsExample();
      final equipment = await getAllEquipmentExample();
      final harvests = await getAllHarvestsExample();
      
      // Delete test data (you might want to add a flag to identify test data)
      for (var crop in crops) {
        if (crop.notes?.contains('test') == true) {
          await deleteCropExample(crop.id);
        }
      }
      
      for (var equip in equipment) {
        if (equip.description.contains('test')) {
          await deleteEquipmentExample(equip.id);
        }
      }
      
      for (var harvest in harvests) {
        if (harvest.notes?.contains('test') == true) {
          await deleteHarvestExample(harvest.id);
        }
      }
      
      print('=== Data Cleanup Completed ===');
      
    } catch (e) {
      print('Cleanup failed: $e');
    }
  }
}

/// Widget to demonstrate the data management examples
class DataManagementDemoWidget extends StatefulWidget {
  const DataManagementDemoWidget({super.key});

  @override
  _DataManagementDemoWidgetState createState() => _DataManagementDemoWidgetState();
}

class _DataManagementDemoWidgetState extends State<DataManagementDemoWidget> {
  final DataManagementExample _example = DataManagementExample();
  bool _isLoading = false;
  String _status = 'Ready to start examples';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Management Examples'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Backend Data Management Examples',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Status display
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            
            // Example buttons
            ElevatedButton(
              onPressed: _isLoading ? null : () => _runCropExamples(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Run Crop Examples'),
            ),
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : () => _runEquipmentExamples(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Run Equipment Examples'),
            ),
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : () => _runHarvestExamples(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Run Harvest Examples'),
            ),
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : () => _runProfileExamples(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Run Profile Examples'),
            ),
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : () => _runCompleteWorkflow(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Run Complete Workflow'),
            ),
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : () => _runCleanup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Run Data Cleanup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runCropExamples() async {
    setState(() {
      _isLoading = true;
      _status = 'Running crop examples...';
    });

    try {
      await _example.createCropExample();
      await _example.getAllCropsExample();
      await _example.getCropStatisticsExample();
      
      setState(() {
        _status = 'Crop examples completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Crop examples failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runEquipmentExamples() async {
    setState(() {
      _isLoading = true;
      _status = 'Running equipment examples...';
    });

    try {
      await _example.createEquipmentExample();
      await _example.getAllEquipmentExample();
      await _example.getEquipmentStatisticsExample();
      
      setState(() {
        _status = 'Equipment examples completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Equipment examples failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runHarvestExamples() async {
    setState(() {
      _isLoading = true;
      _status = 'Running harvest examples...';
    });

    try {
      // Create a crop first for harvest example
      final cropId = await _example.createCropExample();
      await _example.createHarvestExample(cropId);
      await _example.getAllHarvestsExample();
      await _example.getHarvestStatisticsExample();
      
      setState(() {
        _status = 'Harvest examples completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Harvest examples failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runProfileExamples() async {
    setState(() {
      _isLoading = true;
      _status = 'Running profile examples...';
    });

    try {
      await _example.createUserProfileExample();
      await _example.getCurrentUserExample();
      await _example.getUserStatisticsExample('example_user_id');
      
      setState(() {
        _status = 'Profile examples completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Profile examples failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runCompleteWorkflow() async {
    setState(() {
      _isLoading = true;
      _status = 'Running complete workflow...';
    });

    try {
      await _example.completeWorkflowExample();
      
      setState(() {
        _status = 'Complete workflow completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Complete workflow failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runCleanup() async {
    setState(() {
      _isLoading = true;
      _status = 'Running data cleanup...';
    });

    try {
      await _example.cleanupDataExample();
      
      setState(() {
        _status = 'Data cleanup completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Data cleanup failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

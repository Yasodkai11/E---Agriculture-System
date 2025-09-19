import 'package:flutter/material.dart';
import '../../../data/services/crop_service.dart';
import '../../../data/services/equipment_service.dart';
import '../../../data/services/harvest_service.dart';
import '../../../data/services/enhanced_user_service.dart';

class CrudTestScreen extends StatefulWidget {
  const CrudTestScreen({super.key});

  @override
  _CrudTestScreenState createState() => _CrudTestScreenState();
}

class _CrudTestScreenState extends State<CrudTestScreen> {
  final CropService _cropService = CropService();
  final EquipmentService _equipmentService = EquipmentService();
  final HarvestService _harvestService = HarvestService();
  final EnhancedUserService _userService = EnhancedUserService();

  String _status = 'Ready to test CRUD operations';
  bool _isLoading = false;
  
  // Test data storage
  String? _testCropId;
  String? _testEquipmentId;
  String? _testHarvestId;
  String? _testUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Operations Test'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

            // Crop CRUD Operations
            _buildSectionHeader('Crop Management'),
            _buildCrudButtons(
              onCreate: _createCrop,
              onRead: _readCrops,
              onUpdate: _updateCrop,
              onDelete: _deleteCrop,
              onSearch: _searchCrops,
              onStats: _getCropStats,
            ),
            SizedBox(height: 20),

            // Equipment CRUD Operations
            _buildSectionHeader('Equipment Management'),
            _buildCrudButtons(
              onCreate: _createEquipment,
              onRead: _readEquipment,
              onUpdate: _updateEquipment,
              onDelete: _deleteEquipment,
              onSearch: _searchEquipment,
              onStats: _getEquipmentStats,
            ),
            SizedBox(height: 20),

            // Harvest CRUD Operations
            _buildSectionHeader('Harvest Management'),
            _buildCrudButtons(
              onCreate: _createHarvest,
              onRead: _readHarvests,
              onUpdate: _updateHarvest,
              onDelete: _deleteHarvest,
              onSearch: _searchHarvests,
              onStats: _getHarvestStats,
            ),
            SizedBox(height: 20),

            // Profile CRUD Operations
            _buildSectionHeader('Profile Management'),
            _buildCrudButtons(
              onCreate: _createProfile,
              onRead: _readProfile,
              onUpdate: _updateProfile,
              onDelete: _deleteProfile,
              onSearch: _searchProfiles,
              onStats: _getProfileStats,
            ),
            SizedBox(height: 20),

            // Test Data Info
            _buildTestDataInfo(),
            SizedBox(height: 20),

            // Clear All Test Data
            ElevatedButton(
              onPressed: _isLoading ? null : _clearAllTestData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Clear All Test Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildCrudButtons({
    required VoidCallback onCreate,
    required VoidCallback onRead,
    required VoidCallback onUpdate,
    required VoidCallback onDelete,
    required VoidCallback onSearch,
    required VoidCallback onStats,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text('Create'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onRead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Read'),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Update'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: Text('Search'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : onStats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text('Stats'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestDataInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Data IDs:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Text('Crop ID: ${_testCropId ?? 'Not created'}'),
          Text('Equipment ID: ${_testEquipmentId ?? 'Not created'}'),
          Text('Harvest ID: ${_testHarvestId ?? 'Not created'}'),
          Text('Profile ID: ${_testUserId ?? 'Not created'}'),
        ],
      ),
    );
  }

  // ========== CROP OPERATIONS ==========

  Future<void> _createCrop() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test crop...';
    });

    try {
      final cropId = await _cropService.createCrop(
        name: 'Test Wheat',
        variety: 'Test Variety',
        plantedDate: DateTime.now(),
        expectedHarvestDate: DateTime.now().add(Duration(days: 120)),
        area: 10.0,
        notes: 'Test crop for CRUD operations',
        additionalData: {
          'testData': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _testCropId = cropId;
        _status = 'Crop created successfully! ID: $cropId';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to create crop: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readCrops() async {
    setState(() {
      _isLoading = true;
      _status = 'Reading crops...';
    });

    try {
      final crops = await _cropService.getAllCrops();
      setState(() {
        _status = 'Found ${crops.length} crops. Last crop: ${crops.isNotEmpty ? crops.first.name : 'None'}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to read crops: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCrop() async {
    if (_testCropId == null) {
      setState(() {
        _status = 'Please create a crop first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Updating crop...';
    });

    try {
      await _cropService.updateCrop(
        cropId: _testCropId!,
        status: 'growing',
        notes: 'Updated test crop - now growing well',
        additionalData: {
          'testData': true,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _status = 'Crop updated successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to update crop: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCrop() async {
    if (_testCropId == null) {
      setState(() {
        _status = 'Please create a crop first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Deleting crop...';
    });

    try {
      await _cropService.deleteCrop(_testCropId!);
      setState(() {
        _testCropId = null;
        _status = 'Crop deleted successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to delete crop: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCrops() async {
    setState(() {
      _isLoading = true;
      _status = 'Searching crops...';
    });

    try {
      final results = await _cropService.searchCrops('test');
      setState(() {
        _status = 'Search completed. Found ${results.length} crops matching "test"';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to search crops: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCropStats() async {
    setState(() {
      _isLoading = true;
      _status = 'Getting crop statistics...';
    });

    try {
      final stats = await _cropService.getCropStatistics();
      setState(() {
        _status = 'Crop stats: Total: ${stats['totalCrops']}, Area: ${stats['totalArea']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to get crop statistics: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========== EQUIPMENT OPERATIONS ==========

  Future<void> _createEquipment() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test equipment...';
    });

    try {
      final equipmentId = await _equipmentService.createEquipment(
        name: 'Test Tractor',
        category: 'machinery',
        description: 'Test equipment for CRUD operations',
        status: 'operational',
        purchaseDate: DateTime.now().subtract(Duration(days: 365)),
        purchasePrice: 50000.0,
        manufacturer: 'Test Manufacturer',
        model: 'Test Model',
        serialNumber: 'TEST-001',
        specifications: {
          'testData': true,
          'horsepower': 100,
        },
      );

      setState(() {
        _testEquipmentId = equipmentId;
        _status = 'Equipment created successfully! ID: $equipmentId';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to create equipment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readEquipment() async {
    setState(() {
      _isLoading = true;
      _status = 'Reading equipment...';
    });

    try {
      final equipment = await _equipmentService.getAllEquipment();
      setState(() {
        _status = 'Found ${equipment.length} equipment items. Last: ${equipment.isNotEmpty ? equipment.first.name : 'None'}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to read equipment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateEquipment() async {
    if (_testEquipmentId == null) {
      setState(() {
        _status = 'Please create equipment first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Updating equipment...';
    });

    try {
      await _equipmentService.updateEquipment(
        equipmentId: _testEquipmentId!,
        status: 'maintenance',
        description: 'Updated test equipment - now in maintenance',
        specifications: {
          'testData': true,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _status = 'Equipment updated successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to update equipment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEquipment() async {
    if (_testEquipmentId == null) {
      setState(() {
        _status = 'Please create equipment first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Deleting equipment...';
    });

    try {
      await _equipmentService.deleteEquipment(_testEquipmentId!);
      setState(() {
        _testEquipmentId = null;
        _status = 'Equipment deleted successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to delete equipment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchEquipment() async {
    setState(() {
      _isLoading = true;
      _status = 'Searching equipment...';
    });

    try {
      final results = await _equipmentService.searchEquipment('test');
      setState(() {
        _status = 'Search completed. Found ${results.length} equipment items matching "test"';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to search equipment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getEquipmentStats() async {
    setState(() {
      _isLoading = true;
      _status = 'Getting equipment statistics...';
    });

    try {
      final stats = await _equipmentService.getEquipmentStatistics();
      setState(() {
        _status = 'Equipment stats: Total: ${stats['totalEquipment']}, Value: \$${stats['totalValue']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to get equipment statistics: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========== HARVEST OPERATIONS ==========

  Future<void> _createHarvest() async {
    if (_testCropId == null) {
      setState(() {
        _status = 'Please create a crop first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Creating test harvest...';
    });

    try {
      final harvestId = await _harvestService.createHarvest(
        cropId: _testCropId!,
        cropName: 'Test Wheat',
        harvestDate: DateTime.now(),
        quantity: 500.0,
        unit: 'kg',
        quality: 'excellent',
        notes: 'Test harvest for CRUD operations',
        additionalData: {
          'testData': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _testHarvestId = harvestId;
        _status = 'Harvest created successfully! ID: $harvestId';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to create harvest: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readHarvests() async {
    setState(() {
      _isLoading = true;
      _status = 'Reading harvests...';
    });

    try {
      final harvests = await _harvestService.getAllHarvests();
      setState(() {
        _status = 'Found ${harvests.length} harvest records. Last: ${harvests.isNotEmpty ? harvests.first.cropName : 'None'}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to read harvests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateHarvest() async {
    if (_testHarvestId == null) {
      setState(() {
        _status = 'Please create a harvest first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Updating harvest...';
    });

    try {
      await _harvestService.updateHarvest(
        harvestId: _testHarvestId!,
        status: 'sold',
        notes: 'Updated test harvest - now sold',
        additionalData: {
          'testData': true,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _status = 'Harvest updated successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to update harvest: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHarvest() async {
    if (_testHarvestId == null) {
      setState(() {
        _status = 'Please create a harvest first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Deleting harvest...';
    });

    try {
      await _harvestService.deleteHarvest(_testHarvestId!);
      setState(() {
        _testHarvestId = null;
        _status = 'Harvest deleted successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to delete harvest: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchHarvests() async {
    setState(() {
      _isLoading = true;
      _status = 'Searching harvests...';
    });

    try {
      final results = await _harvestService.searchHarvests('test');
      setState(() {
        _status = 'Search completed. Found ${results.length} harvests matching "test"';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to search harvests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getHarvestStats() async {
    setState(() {
      _isLoading = true;
      _status = 'Getting harvest statistics...';
    });

    try {
      final stats = await _harvestService.getHarvestStatistics();
      setState(() {
        _status = 'Harvest stats: Total: ${stats['totalHarvests']}, Quantity: ${stats['totalQuantity']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to get harvest statistics: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========== PROFILE OPERATIONS ==========

  Future<void> _createProfile() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test profile...';
    });

    try {
      final user = await _userService.createUserWithDetails(
        uid: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: 'Test Farmer',
        email: 'test.farmer@example.com',
        phoneNumber: '+1234567890',
        userType: 'farmer',
        location: 'Test Location',
        preferences: {
          'testData': true,
          'notifications': true,
        },
      );

      setState(() {
        _testUserId = user.id;
        _status = 'Profile created successfully! ID: ${user.id}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to create profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readProfile() async {
    setState(() {
      _isLoading = true;
      _status = 'Reading profile...';
    });

    try {
      final user = await _userService.getCurrentUserData();
      setState(() {
        _status = user != null ? 'Profile loaded: ${user.fullName}' : 'No current user found';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to read profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_testUserId == null) {
      setState(() {
        _status = 'Please create a profile first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Updating profile...';
    });

    try {
      await _userService.updateUserPreferences(_testUserId!, {
        'testData': true,
        'notifications': true,
        'weatherAlerts': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _status = 'Profile updated successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to update profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProfile() async {
    if (_testUserId == null) {
      setState(() {
        _status = 'Please create a profile first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Deleting profile...';
    });

    try {
      await _userService.deleteUserAccount(_testUserId!);
      setState(() {
        _testUserId = null;
        _status = 'Profile deleted successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to delete profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProfiles() async {
    setState(() {
      _isLoading = true;
      _status = 'Searching profiles...';
    });

    try {
      final results = await _userService.searchUsers('test');
      setState(() {
        _status = 'Search completed. Found ${results.length} profiles matching "test"';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to search profiles: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getProfileStats() async {
    if (_testUserId == null) {
      setState(() {
        _status = 'Please create a profile first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Getting profile statistics...';
    });

    try {
      final stats = await _userService.getUserStatistics(_testUserId!);
      setState(() {
        _status = 'Profile stats: Type: ${stats['userType']}, Verified: ${stats['isVerified']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to get profile statistics: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========== UTILITY OPERATIONS ==========

  Future<void> _clearAllTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Clearing all test data...';
    });

    try {
      // Delete all test data
      if (_testHarvestId != null) {
        await _harvestService.deleteHarvest(_testHarvestId!);
      }
      if (_testEquipmentId != null) {
        await _equipmentService.deleteEquipment(_testEquipmentId!);
      }
      if (_testCropId != null) {
        await _cropService.deleteCrop(_testCropId!);
      }
      if (_testUserId != null) {
        await _userService.deleteUserAccount(_testUserId!);
      }

      setState(() {
        _testCropId = null;
        _testEquipmentId = null;
        _testHarvestId = null;
        _testUserId = null;
        _status = 'All test data cleared successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to clear test data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


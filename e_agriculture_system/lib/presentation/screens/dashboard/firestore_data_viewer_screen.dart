import 'package:flutter/material.dart';
import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:e_agriculture_system/data/services/crop_service.dart';
import 'package:e_agriculture_system/data/services/harvest_service.dart';
import 'package:e_agriculture_system/data/services/equipment_service.dart';
import 'package:e_agriculture_system/data/models/crop_models.dart';
import 'package:e_agriculture_system/data/models/harvest_model.dart';
import 'package:e_agriculture_system/data/models/equipment_model.dart';

class FirestoreDataViewerScreen extends StatefulWidget {
  const FirestoreDataViewerScreen({super.key});

  @override
  State<FirestoreDataViewerScreen> createState() => _FirestoreDataViewerScreenState();
}

class _FirestoreDataViewerScreenState extends State<FirestoreDataViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CropService _cropService = CropService();
  final HarvestService _harvestService = HarvestService();
  final EquipmentService _equipmentService = EquipmentService();

  List<CropModel> _crops = [];
  List<HarvestModel> _harvests = [];
  List<EquipmentModel> _equipment = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _cropService.getAllCrops(),
        _harvestService.getAllHarvests(),
        _equipmentService.getAllEquipment(),
      ]);

      setState(() {
        _crops = results[0] as List<CropModel>;
        _harvests = results[1] as List<HarvestModel>;
        _equipment = results[2] as List<EquipmentModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Firestore Data Viewer',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Crops', icon: Icon(Icons.agriculture)),
            Tab(text: 'Harvests', icon: Icon(Icons.grain)),
            Tab(text: 'Equipment', icon: Icon(Icons.build)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCropsTab(),
                    _buildHarvestsTab(),
                    _buildEquipmentTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCropsTab() {
    if (_crops.isEmpty) {
      return const Center(
        child: Text('No crops found. Add some crops to get started!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _crops.length,
      itemBuilder: (context, index) {
        final crop = _crops[index];
        return _buildCropCard(crop);
      },
    );
  }

  Widget _buildCropCard(CropModel crop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          crop.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${crop.variety} - ${crop.status}'),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(crop.status),
          child: Text(
            crop.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Variety', crop.variety),
                _buildInfoRow('Status', crop.status),
                _buildInfoRow('Area', '${crop.area} acres'),
                _buildInfoRow('Planted Date', _formatDate(crop.plantedDate)),
                if (crop.expectedHarvestDate != null)
                  _buildInfoRow('Expected Harvest', _formatDate(crop.expectedHarvestDate!)),
                if (crop.notes != null) _buildInfoRow('Notes', crop.notes!),
                _buildInfoRow('Created', _formatDate(crop.createdAt)),
                if (crop.imageUrls.isNotEmpty)
                  _buildImageGallery(crop.imageUrls),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestsTab() {
    if (_harvests.isEmpty) {
      return const Center(
        child: Text('No harvests found. Add some harvests to get started!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _harvests.length,
      itemBuilder: (context, index) {
        final harvest = _harvests[index];
        return _buildHarvestCard(harvest);
      },
    );
  }

  Widget _buildHarvestCard(HarvestModel harvest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          harvest.cropName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${harvest.quantity} ${harvest.unit} - ${harvest.quality}'),
        leading: CircleAvatar(
          backgroundColor: _getQualityColor(harvest.quality),
          child: Text(
            harvest.cropName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Crop ID', harvest.cropId),
                _buildInfoRow('Quantity', '${harvest.quantity} ${harvest.unit}'),
                _buildInfoRow('Quality', harvest.quality),
                _buildInfoRow('Status', harvest.status),
                _buildInfoRow('Harvest Date', _formatDate(harvest.harvestDate)),
                if (harvest.pricePerUnit != null)
                  _buildInfoRow('Price per Unit', '\$${harvest.pricePerUnit}'),
                if (harvest.notes != null) _buildInfoRow('Notes', harvest.notes!),
                _buildInfoRow('Created', _formatDate(harvest.createdAt)),
                if (harvest.imageUrls.isNotEmpty)
                  _buildImageGallery(harvest.imageUrls),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab() {
    if (_equipment.isEmpty) {
      return const Center(
        child: Text('No equipment found. Add some equipment to get started!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _equipment.length,
      itemBuilder: (context, index) {
        final equipment = _equipment[index];
        return _buildEquipmentCard(equipment);
      },
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          equipment.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${equipment.category} - ${equipment.status}'),
        leading: CircleAvatar(
          backgroundColor: _getEquipmentStatusColor(equipment.status),
          child: Text(
            equipment.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Category', equipment.category),
                _buildInfoRow('Status', equipment.status),
                _buildInfoRow('Description', equipment.description),
                if (equipment.manufacturer != null)
                  _buildInfoRow('Manufacturer', equipment.manufacturer!),
                if (equipment.model != null) _buildInfoRow('Model', equipment.model!),
                if (equipment.serialNumber != null)
                  _buildInfoRow('Serial Number', equipment.serialNumber!),
                if (equipment.purchaseDate != null)
                  _buildInfoRow('Purchase Date', _formatDate(equipment.purchaseDate!)),
                if (equipment.purchasePrice != null)
                  _buildInfoRow('Purchase Price', '\$${equipment.purchasePrice}'),
                if (equipment.lastMaintenance != null)
                  _buildInfoRow('Last Maintenance', _formatDate(equipment.lastMaintenance!)),
                if (equipment.nextMaintenance != null)
                  _buildInfoRow('Next Maintenance', _formatDate(equipment.nextMaintenance!)),
                if (equipment.maintenanceCost != null)
                  _buildInfoRow('Maintenance Cost', '\$${equipment.maintenanceCost}'),
                if (equipment.maintenanceNotes != null)
                  _buildInfoRow('Maintenance Notes', equipment.maintenanceNotes!),
                _buildInfoRow('Created', _formatDate(equipment.createdAt)),
                if (equipment.imageUrls.isNotEmpty)
                  _buildImageGallery(equipment.imageUrls),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Images:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planted':
        return Colors.green;
      case 'growing':
        return Colors.blue;
      case 'ready':
        return Colors.orange;
      case 'harvested':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEquipmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'repair':
        return Colors.red;
      case 'retired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

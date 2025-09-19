import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/core/utills/responsive_helper.dart';
import 'package:e_agriculture_system/data/models/crop_models.dart';
import 'package:e_agriculture_system/data/services/crop_service.dart';
import 'package:flutter/material.dart';

class CropMonitorScreen extends StatefulWidget {
  const CropMonitorScreen({super.key});

  @override
  State<CropMonitorScreen> createState() => _CropMonitorScreenState();
}

class _CropMonitorScreenState extends State<CropMonitorScreen>
    with TickerProviderStateMixin {
  final CropService _cropService = CropService();
  String selectedFilter = 'All';
  List<CropModel> _crops = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<String> filterOptions = [
    'All',
    'Planted',
    'Growing',
    'Ready',
    'Harvested'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCrops();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('=== CROP MONITOR DEBUG ===');
      debugPrint('Loading crops...');
      
      final crops = await _cropService.getAllCrops();
      
      debugPrint('Received ${crops.length} crops from service');
      for (int i = 0; i < crops.length; i++) {
        debugPrint('Crop $i: ${crops[i].name} (${crops[i].status})');
      }
      
      setState(() {
        _crops = crops;
        _isLoading = false;
      });
      
      debugPrint('Crops loaded successfully in UI');
    } catch (e) {
      debugPrint('ERROR loading crops: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<CropModel> get _filteredCrops {
    var filtered = _crops;
    
    // Filter by status
    if (selectedFilter != 'All') {
      filtered = filtered.where((crop) => 
        crop.status.toLowerCase() == selectedFilter.toLowerCase()
      ).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crop) =>
        crop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        crop.variety.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        crop.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (crop.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    return filtered;
  }

  List<CropModel> _getCropsByStatus(String status) {
    return _crops.where((crop) => crop.status.toLowerCase() == status.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(context),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildErrorWidget())
          else ...[
            _buildSearchAndFilterSection(context),
            _buildCropOverviewCard(context),
            _buildCropList(context),
          ],
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: ResponsiveHelper.isSmallScreen(context) ? 120 : 140,
      floating: false,
      pinned: true,
        elevation: 0,
      backgroundColor: AppTheme.primaryGreen,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
                      Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCrops,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Crop Monitor',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.isSmallScreen(context) ? 20 : 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D5A3D),
                Color(0xFF4A7C59),
                Color(0xFF6B8E6B),
                                ],
                              ),
                      ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 50,
                top: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
      decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search crops...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = filterOptions[index];
                  return _buildFilterChip(filter);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropOverviewCard(BuildContext context) {
    final totalCrops = _crops.length;
    final growingCrops = _getCropsByStatus('Growing').length;
    final readyCrops = _getCropsByStatus('Ready').length;
    final plantedCrops = _getCropsByStatus('Planted').length;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
              Color(0xFF2D5A3D),
              Color(0xFF4A7C59),
              Color(0xFF6B8E6B),
          ],
        ),
          borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
        children: [
          Container(
                  padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                        'Crop Overview',
                style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.isSmallScreen(context) ? 18 : 20,
                          fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                        '$totalCrops total crops',
                style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                ),
              ),
            ],
                  ),
          ),
        ],
      ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatusIndicator('Planted', Colors.blue, plantedCrops),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusIndicator('Growing', Colors.orange, growingCrops),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusIndicator('Ready', Colors.green, readyCrops),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropList(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: _filteredCrops.isEmpty
          ? SliverFillRemaining(
              child: _buildEmptyState(),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final crop = _filteredCrops[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildModernCropCard(crop, index),
                    ),
                  );
                },
                childCount: _filteredCrops.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_outlined,
              size: 64,
              color: AppTheme.primaryGreen.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No crops found' : 'No crops added yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add your first crop to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCropDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Crop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddCropDialog(),
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.add),
      label: const Text('Add Crop'),
    );
  }

  Widget _buildStatusIndicator(String label, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
        child: Column(
          children: [
                Container(
            width: 8,
            height: 8,
                  decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 4),
                      Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
                      Text(
            label,
                        style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
                    border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
                      width: 1.5,
                    ),
          boxShadow: isSelected
              ? [
                      BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                ),
              ],
            ),
                      child: Text(
          filter,
                        style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernCropCard(CropModel crop, int index) {
    final statusColor = _getStatusColor(crop.status);
    final daysUntilHarvest = crop.expectedHarvestDate?.difference(DateTime.now()).inDays ?? 0;
    final isHarvestDue = daysUntilHarvest <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showCropDetails(crop),
      child: Padding(
            padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                    // Crop Icon with Status
                Container(
                      width: 60,
                      height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                            statusColor.withOpacity(0.1),
                            statusColor.withOpacity(0.05),
                      ],
                    ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                        color: statusColor.withOpacity(0.2),
                          width: 1,
                      ),
                  ),
                  child: Center(
                    child: Icon(
                          _getCropIcon(crop.name),
                          size: 28,
                      color: statusColor,
                    ),
                  ),
                ),
                    const SizedBox(width: 16),
                // Crop Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5A3D),
                            ),
                            maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                          const SizedBox(height: 4),
                      Text(
                        'Variety: ${crop.variety}',
                        style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                        ),
                            maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                          const SizedBox(height: 8),
                      Row(
                        children: [
                Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    crop.status.toUpperCase(),
                    style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                              const SizedBox(width: 8),
              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                      child: Text(
                                  '${crop.area.toStringAsFixed(1)} ha',
                                  style: const TextStyle(
                                    fontSize: 12,
                          fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                          ),
                        ],
                      ),
                    ),
                    // Action Menu
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleCropAction(value, crop),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'harvest',
                          child: Row(
                            children: [
                              Icon(Icons.agriculture, size: 20),
                              SizedBox(width: 8),
                              Text('Harvest'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                // Additional Info Row
                if (crop.expectedHarvestDate != null || isHarvestDue)
            Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
            Text(
                          'Planted: ${_formatDate(crop.plantedDate)}',
              style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (crop.expectedHarvestDate != null) ...[
                          Icon(
                            Icons.event,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
        Text(
                            'Harvest: ${_formatDate(crop.expectedHarvestDate!)}',
          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (isHarvestDue) ...[
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 4),
              Text(
                            'Harvest due in $daysUntilHarvest days',
                style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planted':
        return Colors.blue;
      case 'growing':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      case 'harvested':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return Icons.grain;
      case 'wheat':
        return Icons.eco;
      case 'corn':
        return Icons.local_florist;
      case 'vegetables':
        return Icons.agriculture;
      default:
        return Icons.eco;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleCropAction(String action, CropModel crop) {
    switch (action) {
      case 'edit':
        _showEditCropDialog(crop);
        break;
      case 'harvest':
        _showHarvestDialog(crop);
        break;
      case 'delete':
        _showDeleteConfirmation(crop);
        break;
    }
  }

  void _showCropDetails(CropModel crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCropDetailsSheet(crop),
    );
  }

  Widget _buildCropDetailsSheet(CropModel crop) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
          child: Column(
            children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getStatusColor(crop.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCropIcon(crop.name),
                          size: 28,
                          color: _getStatusColor(crop.status),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A3D),
                              ),
                            ),
                            Text(
                              'Variety: ${crop.variety}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
              ),
            ],
          ),
        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Details
                  _buildDetailRow('Status', crop.status.toUpperCase()),
                  _buildDetailRow('Variety', crop.variety),
                  _buildDetailRow('Area', '${crop.area.toStringAsFixed(1)} hectares'),
                  _buildDetailRow('Planting Date', _formatDate(crop.plantedDate)),
                  if (crop.expectedHarvestDate != null)
                    _buildDetailRow('Expected Harvest', _formatDate(crop.expectedHarvestDate!)),
                  if (crop.notes != null && crop.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A3D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        crop.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D5A3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCropDialog(CropModel crop) {
    // Implementation for edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _showHarvestDialog(CropModel crop) {
    // Implementation for harvest dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harvest functionality coming soon!')),
    );
  }

  void _showDeleteConfirmation(CropModel crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete "${crop.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
                Navigator.pop(context);
              // Implement delete functionality
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality coming soon!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
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
            'Error loading crops',
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
            onPressed: _loadCrops,
            child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _showAddCropDialog() {
    final formKey = GlobalKey<FormState>();
    final cropNameController = TextEditingController();
    final varietyController = TextEditingController();
    final areaController = TextEditingController();
    final notesController = TextEditingController();
    
    String selectedStatus = 'Planted';
    DateTime? plantingDate = DateTime.now();
    DateTime? expectedHarvestDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
      title: const Text('Add New Crop'),
      content: SingleChildScrollView(
        child: Form(
              key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                    controller: cropNameController,
                decoration: const InputDecoration(
                  labelText: 'Crop Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter crop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                    controller: varietyController,
                decoration: const InputDecoration(
                  labelText: 'Variety',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter variety';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                    controller: areaController,
                decoration: const InputDecoration(
                      labelText: 'Area (hectares)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter area';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Planted', 'Growing', 'Ready', 'Harvested'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                    title: const Text('Planting Date'),
                    subtitle: Text(plantingDate?.toString().split(' ')[0] ?? 'Select date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                        setDialogState(() {
                          plantingDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Expected Harvest Date'),
                    subtitle: Text(expectedHarvestDate?.toString().split(' ')[0] ?? 'Select date (optional)'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                        setDialogState(() {
                          expectedHarvestDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                    controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final newCrop = CropModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: _cropService.currentUserId ?? 'unknown_user',
                      name: cropNameController.text,
                      variety: varietyController.text,
                      status: selectedStatus,
                      area: double.tryParse(areaController.text) ?? 0.0,
                      plantedDate: plantingDate ?? DateTime.now(),
                      expectedHarvestDate: expectedHarvestDate,
                      notes: notesController.text.isNotEmpty ? notesController.text : null,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    await _cropService.addCrop(newCrop);
                    await _loadCrops();
                    
                    if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Crop added successfully!')),
                );
                    }
              } catch (e) {
                    if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding crop: $e')),
                      );
                    }
                  }
                }
              },
          child: const Text('Add Crop'),
        ),
      ],
        ),
      ),
    );
  }
}
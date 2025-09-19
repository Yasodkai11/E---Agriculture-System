import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/core/utills/responsive_helper.dart';
import 'package:e_agriculture_system/data/services/equipment_service.dart';
import 'package:e_agriculture_system/data/models/equipment_model.dart';
import 'package:flutter/material.dart';

class FarmEquipmentScreen extends StatefulWidget {
  const FarmEquipmentScreen({super.key});

  @override
  State<FarmEquipmentScreen> createState() => _FarmEquipmentScreenState();
}

class _FarmEquipmentScreenState extends State<FarmEquipmentScreen>
    with TickerProviderStateMixin {
  final EquipmentService _equipmentService = EquipmentService();
  List<EquipmentModel> _equipment = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEquipment();
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

  Future<void> _loadEquipment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final equipment = await _equipmentService.getAllEquipment();
      setState(() {
        _equipment = equipment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<EquipmentModel> get _filteredEquipment {
    var filtered = _equipment;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((equip) => 
        equip.category.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((equip) =>
        equip.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        equip.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        equip.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (equip.manufacturer?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    return filtered;
  }

  List<String> get _categories {
    final categories = _equipment.map((e) => e.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
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
            _buildEquipmentOverviewCard(context),
            _buildEquipmentList(context),
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
            onPressed: _loadEquipment,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Farm Equipment',
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
                  hintText: 'Search equipment...',
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
            // Category Filter Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryChip(category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentOverviewCard(BuildContext context) {
    final operationalCount = _equipment.where((e) => e.status == 'operational').length;
    final maintenanceCount = _equipment.where((e) => e.status == 'maintenance').length;
    final repairCount = _equipment.where((e) => e.status == 'repair').length;
    final totalValue = _equipment.fold<double>(
      0.0,
      (sum, equipment) => sum + (equipment.purchasePrice ?? 0),
    );

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
                    Icons.precision_manufacturing,
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
                        'Equipment Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.isSmallScreen(context) ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_equipment.length} total equipment',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalValue > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rs. ${totalValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatusIndicator('Operational', Colors.green, operationalCount),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusIndicator('Maintenance', Colors.orange, maintenanceCount),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusIndicator('Repair', Colors.red, repairCount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentList(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: _filteredEquipment.isEmpty
          ? SliverFillRemaining(
              child: _buildEmptyState(),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final equipment = _filteredEquipment[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildModernEquipmentCard(equipment, index),
                    ),
                  );
                },
                childCount: _filteredEquipment.length,
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
              Icons.precision_manufacturing_outlined,
              size: 64,
              color: AppTheme.primaryGreen.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No equipment found' : 'No equipment added yet',
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
                : 'Add your first piece of equipment to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEquipmentDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Equipment'),
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
      onPressed: () => _showAddEquipmentDialog(context),
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.add),
      label: const Text('Add Equipment'),
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
            'Error loading equipment',
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
            onPressed: _loadEquipment,
            child: const Text('Retry'),
          ),
        ],
      ),
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

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
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
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernEquipmentCard(EquipmentModel equipment, int index) {
    final daysUntilMaintenance = equipment.nextMaintenance?.difference(DateTime.now()).inDays ?? 0;
    final isMaintenanceDue = daysUntilMaintenance <= 7;
    final statusColor = _getStatusColor(equipment.status);

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
          onTap: () => _showEquipmentDetails(equipment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Equipment Icon with Status
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
                          _getEquipmentIcon(equipment.category),
                          size: 28,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Equipment Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.name,
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
                            equipment.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
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
                                  equipment.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (equipment.category.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    equipment.category,
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
                      onSelected: (value) => _handleEquipmentAction(value, equipment),
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
                          value: 'maintenance',
                          child: Row(
                            children: [
                              Icon(Icons.build, size: 20),
                              SizedBox(width: 8),
                              Text('Maintenance'),
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
                if (equipment.purchaseDate != null || equipment.purchasePrice != null || isMaintenanceDue)
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
                        if (equipment.purchaseDate != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Purchased: ${_formatDate(equipment.purchaseDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (equipment.purchasePrice != null) ...[
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rs. ${equipment.purchasePrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (isMaintenanceDue) ...[
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Maintenance due in $daysUntilMaintenance days',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleEquipmentAction(String action, EquipmentModel equipment) {
    switch (action) {
      case 'edit':
        _showEditEquipmentDialog(equipment);
        break;
      case 'maintenance':
        _showMaintenanceDialog(equipment);
        break;
      case 'delete':
        _showDeleteConfirmation(equipment);
        break;
    }
  }

  void _showEquipmentDetails(EquipmentModel equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEquipmentDetailsSheet(equipment),
    );
  }

  Widget _buildEquipmentDetailsSheet(EquipmentModel equipment) {
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
                          color: _getStatusColor(equipment.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getEquipmentIcon(equipment.category),
                          size: 28,
                          color: _getStatusColor(equipment.status),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipment.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A3D),
                              ),
                            ),
                            Text(
                              equipment.description,
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
                  _buildDetailRow('Status', equipment.status.toUpperCase()),
                  _buildDetailRow('Category', equipment.category),
                  if (equipment.manufacturer != null)
                    _buildDetailRow('Manufacturer', equipment.manufacturer!),
                  if (equipment.model != null)
                    _buildDetailRow('Model', equipment.model!),
                  if (equipment.serialNumber != null)
                    _buildDetailRow('Serial Number', equipment.serialNumber!),
                  if (equipment.purchaseDate != null)
                    _buildDetailRow('Purchase Date', _formatDate(equipment.purchaseDate!)),
                  if (equipment.purchasePrice != null)
                    _buildDetailRow('Purchase Price', 'Rs. ${equipment.purchasePrice!.toStringAsFixed(0)}'),
                  if (equipment.lastMaintenance != null)
                    _buildDetailRow('Last Maintenance', _formatDate(equipment.lastMaintenance!)),
                  if (equipment.nextMaintenance != null)
                    _buildDetailRow('Next Maintenance', _formatDate(equipment.nextMaintenance!)),
                  if (equipment.maintenanceCost != null)
                    _buildDetailRow('Maintenance Cost', 'Rs. ${equipment.maintenanceCost!.toStringAsFixed(0)}'),
                  if (equipment.maintenanceNotes != null && equipment.maintenanceNotes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Maintenance Notes',
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
                        equipment.maintenanceNotes!,
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

  void _showEditEquipmentDialog(EquipmentModel equipment) {
    // Implementation for edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _showMaintenanceDialog(EquipmentModel equipment) {
    // Implementation for maintenance dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maintenance functionality coming soon!')),
    );
  }

  void _showDeleteConfirmation(EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text('Are you sure you want to delete "${equipment.name}"?'),
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

  Color _getStatusColor(String status) {
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

  IconData _getEquipmentIcon(String category) {
    switch (category.toLowerCase()) {
      case 'machinery':
        return Icons.agriculture;
      case 'implements':
        return Icons.build;
      case 'irrigation':
        return Icons.water_drop;
      case 'tools':
        return Icons.handyman;
      case 'vehicles':
        return Icons.directions_car;
      default:
        return Icons.build;
    }
  }

  void _showAddEquipmentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final manufacturerController = TextEditingController();
    final modelController = TextEditingController();
    final serialNumberController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final maintenanceNotesController = TextEditingController();
    
    String selectedCategory = 'machinery';
    String selectedStatus = 'operational';
    DateTime? purchaseDate;
    DateTime? lastMaintenance;
    DateTime? nextMaintenance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Equipment'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Equipment Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter equipment name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['machinery', 'implements', 'irrigation', 'tools', 'vehicles'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
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
                  items: ['operational', 'maintenance', 'repair', 'retired'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: manufacturerController,
                        decoration: const InputDecoration(
                          labelText: 'Manufacturer (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: serialNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Serial Number (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: purchasePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Price (optional)',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListTile(
                        title: const Text('Purchase Date'),
                        subtitle: Text(purchaseDate?.toString().split(' ')[0] ?? 'Select date'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            purchaseDate = date;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Last Maintenance'),
                        subtitle: Text(lastMaintenance?.toString().split(' ')[0] ?? 'Select date'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            lastMaintenance = date;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListTile(
                        title: const Text('Next Maintenance'),
                        subtitle: Text(nextMaintenance?.toString().split(' ')[0] ?? 'Select date'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            nextMaintenance = date;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: maintenanceNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Maintenance Notes (optional)',
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
                  await _equipmentService.createEquipment(
                    name: nameController.text.trim(),
                    category: selectedCategory,
                    description: descriptionController.text.trim(),
                    status: selectedStatus,
                    purchaseDate: purchaseDate,
                    purchasePrice: purchasePriceController.text.isNotEmpty ? double.parse(purchasePriceController.text) : null,
                    manufacturer: manufacturerController.text.trim().isEmpty ? null : manufacturerController.text.trim(),
                    model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
                    serialNumber: serialNumberController.text.trim().isEmpty ? null : serialNumberController.text.trim(),
                    lastMaintenance: lastMaintenance,
                    nextMaintenance: nextMaintenance,
                    maintenanceNotes: maintenanceNotesController.text.trim().isEmpty ? null : maintenanceNotesController.text.trim(),
                  );
                  
                  Navigator.pop(context);
                  _loadEquipment();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Equipment added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding equipment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Add Equipment'),
          ),
        ],
      ),
    );
  }

  void _showEquipmentMaintenanceDialog(BuildContext context, EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${equipment.name} Maintenance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (equipment.lastMaintenance != null)
              Text('Last Maintenance: ${_formatDate(equipment.lastMaintenance!)}'),
            if (equipment.nextMaintenance != null) ...[
              if (equipment.lastMaintenance != null) const SizedBox(height: 8),
              Text('Next Maintenance: ${_formatDate(equipment.nextMaintenance!)}'),
            ],
            const SizedBox(height: 16),
            const Text('Maintenance schedule feature coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _displayEquipmentDetails(BuildContext context, EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(equipment.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${equipment.category}'),
            const SizedBox(height: 8),
            Text('Status: ${equipment.status}'),
            const SizedBox(height: 8),
            Text('Description: ${equipment.description}'),
            if (equipment.manufacturer != null) ...[
              const SizedBox(height: 8),
              Text('Manufacturer: ${equipment.manufacturer}'),
            ],
            if (equipment.model != null) ...[
              const SizedBox(height: 8),
              Text('Model: ${equipment.model}'),
            ],
            if (equipment.lastMaintenance != null) ...[
              const SizedBox(height: 8),
              Text('Last Maintenance: ${_formatDate(equipment.lastMaintenance!)}'),
            ],
            if (equipment.nextMaintenance != null) ...[
              const SizedBox(height: 8),
              Text('Next Maintenance: ${_formatDate(equipment.nextMaintenance!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateString(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 
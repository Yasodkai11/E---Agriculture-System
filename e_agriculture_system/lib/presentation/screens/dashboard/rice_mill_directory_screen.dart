import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/rice_mill_service.dart';
import '../../../data/models/rice_mill_model.dart';
import '../../widgets/common/rice_mill_card_widget.dart';

class RiceMillDirectoryScreen extends StatefulWidget {
  const RiceMillDirectoryScreen({super.key});

  @override
  State<RiceMillDirectoryScreen> createState() => _RiceMillDirectoryScreenState();
}

class _RiceMillDirectoryScreenState extends State<RiceMillDirectoryScreen> {
  List<RiceMillModel> _riceMills = [];
  List<RiceMillModel> _filteredRiceMills = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _statistics = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showCompactView = false;

  @override
  void initState() {
    super.initState();
    _loadRiceMills();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRiceMills() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final riceMills = await RiceMillService.getRiceMills();
      final stats = await RiceMillService.getRiceMillStatistics();
      
      setState(() {
        _riceMills = riceMills;
        _filteredRiceMills = riceMills;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredRiceMills = _riceMills;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await RiceMillService.searchRiceMills(query);
      setState(() {
        _filteredRiceMills = results;
      });
    } catch (e) {
      // Fallback to local search
      final results = _riceMills.where((mill) =>
          mill.name.toLowerCase().contains(query.toLowerCase()) ||
          mill.location.toLowerCase().contains(query.toLowerCase()) ||
          mill.district.toLowerCase().contains(query.toLowerCase()) ||
          mill.province.toLowerCase().contains(query.toLowerCase()) ||
          (mill.ownerName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          mill.riceVarieties.any((variety) => variety.toLowerCase().contains(query.toLowerCase()))).toList();
      
      setState(() {
        _filteredRiceMills = results;
      });
    }
  }

  void _filterByDistrict(String district) async {
    setState(() {
      _selectedFilter = district;
      _isLoading = true;
    });
    
    try {
      final filtered = await RiceMillService.getRiceMillsByDistrict(district);
      setState(() {
        _filteredRiceMills = filtered;
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
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        title: const Text(
          'Rice Mill Directory',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showCompactView ? Icons.view_list : Icons.view_module,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showCompactView = !_showCompactView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRiceMills,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rice Mill Directory',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_statistics['totalRiceMills'] ?? 0} Rice Mills Registered',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatItem('Contact Info', _statistics['withContactInfo'] ?? 0, Colors.green),
                          const SizedBox(width: 16),
                          _buildStatItem('Owner Details', _statistics['withOwnerInfo'] ?? 0, Colors.blue),
                          const SizedBox(width: 16),
                          _buildStatItem('Location', _statistics['withLocation'] ?? 0, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.grain,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search rice mills, owners, or locations...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Kurunegala'),
                _buildFilterChip('Polonnaruwa'),
                _buildFilterChip('Anuradhapura'),
                _buildFilterChip('Batticaloa'),
                _buildFilterChip('Hambantota'),
                _buildFilterChip('Colombo'),
                _buildFilterChip('Gampaha'),
              ],
            ),
          ),

          // Rice Mills List
          Expanded(
            child: _buildRiceMillsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        _searchController.clear();
        if (filter == 'All') {
          setState(() {
            _selectedFilter = filter;
            _filteredRiceMills = _riceMills;
          });
        } else {
          _filterByDistrict(filter);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRiceMillsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load rice mill data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRiceMills,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRiceMills.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No rice mills found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRiceMills.length,
      itemBuilder: (context, index) {
        final riceMill = _filteredRiceMills[index];
        return _showCompactView
            ? CompactRiceMillCardWidget(
                riceMill: riceMill,
                onTap: () => _showRiceMillDetails(riceMill),
              )
            : RiceMillCardWidget(
                riceMill: riceMill,
                onTap: () => _showRiceMillDetails(riceMill),
              );
      },
    );
  }

  void _showRiceMillDetails(RiceMillModel riceMill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Rice mill details
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.grain,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            riceMill.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            riceMill.fullLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Business information
                if (riceMill.businessType != null || riceMill.capacity != null) ...[
                  const Text(
                    'Business Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (riceMill.businessType != null)
                    _buildDetailItem('Business Type', riceMill.businessType!),
                  if (riceMill.capacity != null)
                    _buildDetailItem('Capacity', riceMill.capacity!),
                  if (riceMill.establishedYear != null)
                    _buildDetailItem('Established', riceMill.establishedYear!),
                  const SizedBox(height: 16),
                ],

                // Rice varieties
                if (riceMill.riceVarieties.isNotEmpty) ...[
                  const Text(
                    'Rice Varieties',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: riceMill.riceVarieties.map((variety) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          variety,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Contact information
                if (riceMill.hasContactInfo) ...[
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (riceMill.phone != null)
                    _buildContactItem(Icons.phone, riceMill.phone!),
                  if (riceMill.email != null)
                    _buildContactItem(Icons.email, riceMill.email!),
                  if (riceMill.website != null)
                    _buildContactItem(Icons.web, riceMill.website!),
                  const SizedBox(height: 16),
                ],

                // Owner information
                if (riceMill.hasOwnerInfo) ...[
                  const Text(
                    'Owner Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (riceMill.ownerName != null)
                    _buildContactItem(Icons.person, riceMill.ownerName!),
                  if (riceMill.ownerPhone != null)
                    _buildContactItem(Icons.phone, riceMill.ownerPhone!),
                  if (riceMill.ownerEmail != null)
                    _buildContactItem(Icons.email, riceMill.ownerEmail!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}





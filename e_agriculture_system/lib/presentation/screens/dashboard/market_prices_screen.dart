import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/core/constants/app_dimensions.dart';
import 'package:e_agriculture_system/data/services/real_market_prices_service.dart';
import 'package:e_agriculture_system/data/services/rice_mill_service.dart';
import 'package:e_agriculture_system/data/models/sri_lanka_market_price_model.dart';
import 'package:e_agriculture_system/data/models/rice_mill_model.dart';
import 'package:e_agriculture_system/presentation/widgets/common/commodity_icon_widget.dart';
import 'package:e_agriculture_system/presentation/screens/dashboard/rice_mill_directory_screen.dart';
import 'package:flutter/material.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  List<SriLankaMarketPriceModel> _commodities = [];
  List<SriLankaMarketPriceModel> _filteredCommodities = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _marketStats = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<RiceMillModel> _riceMills = [];
  Map<String, dynamic> _riceMillStats = {};

  @override
  void initState() {
    super.initState();
    _loadMarketPrices();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketPrices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final prices = await RealMarketPricesService.getRealMarketPrices();
      final stats = await RealMarketPricesService.getMarketStatistics();
      final riceMills = await RiceMillService.getRiceMills();
      final riceMillStats = await RiceMillService.getRiceMillStatistics();
      
      setState(() {
        _commodities = prices;
        _filteredCommodities = prices;
        _marketStats = stats;
        _riceMills = riceMills;
        _riceMillStats = riceMillStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCommodities(String category) async {
    setState(() {
      _selectedFilter = category;
      _isLoading = true;
    });
    
    try {
      final filtered = await RealMarketPricesService.getPricesByCategory(category);
      setState(() {
        _filteredCommodities = filtered;
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
        _filteredCommodities = _commodities;
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
      final results = await RealMarketPricesService.searchCommodities(query);
      setState(() {
        _filteredCommodities = results;
      });
    } catch (e) {
      // Fallback to local search
      final results = _commodities.where((commodity) =>
          commodity.productName.toLowerCase().contains(query.toLowerCase()) ||
          commodity.categoryDisplayName.toLowerCase().contains(query.toLowerCase()) ||
          commodity.marketLocation.toLowerCase().contains(query.toLowerCase()) ||
          commodity.district.toLowerCase().contains(query.toLowerCase())).toList();
      
      setState(() {
        _filteredCommodities = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        title: const Text(
          'Market Prices',
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
            icon: const Icon(Icons.grain, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RiceMillDirectoryScreen(),
                ),
              );
            },
            tooltip: 'Rice Mill Directory',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMarketPrices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Market Overview Card
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
                        'Market Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last updated: ${_marketStats['lastUpdated'] != null ? _formatLastUpdated(_marketStats['lastUpdated']) : 'Loading...'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTrendIndicator('Up', Colors.green, _marketStats['upCount'] ?? 0),
                          const SizedBox(width: 16),
                          _buildTrendIndicator('Down', Colors.red, _marketStats['downCount'] ?? 0),
                          const SizedBox(width: 16),
                          _buildTrendIndicator('Stable', Colors.orange, _marketStats['stableCount'] ?? 0),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTrendIndicator('Rice Mills', Colors.blue, _riceMillStats['totalRiceMills'] ?? 0),
                          const SizedBox(width: 16),
                          _buildTrendIndicator('With Contact', Colors.purple, _riceMillStats['withContactInfo'] ?? 0),
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
                    Icons.trending_up,
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
                hintText: 'Search commodities, markets, or districts...',
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
                _buildFilterChip('Grains'),
                _buildFilterChip('Vegetables'),
                _buildFilterChip('Fruits'),
                _buildFilterChip('Spices'),
                _buildFilterChip('Beverages'),
                _buildFilterChip('Industrial'),
              ],
            ),
          ),

          // Rice Mill Quick Access
          if (_riceMills.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RiceMillDirectoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.grain, size: 18),
                      label: Text('View ${_riceMillStats['totalRiceMills'] ?? 0} Rice Mills'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Commodities List
          Expanded(
            child: _buildCommoditiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(String label, Color color, int count) {
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

  Widget _buildCommoditiesList() {
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
                Icons.wifi_off,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to fetch real-time prices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Showing cached data or sample prices',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadMarketPrices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Show Data'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredCommodities.isEmpty) {
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
              'No commodities found',
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
      itemCount: _filteredCommodities.length,
      itemBuilder: (context, index) {
        final commodity = _filteredCommodities[index];
        return _buildCommodityCard(commodity);
      },
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        _searchController.clear();
        _filterCommodities(filter);
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

  Widget _buildCommodityCard(SriLankaMarketPriceModel commodity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Commodity Icon with Trend
          CommodityIconWithTrendWidget(
            category: commodity.category,
            trend: commodity.trend,
            size: 24,
          ),

          const SizedBox(width: 16),

          // Commodity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  commodity.displayLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${commodity.displayPrice} ${commodity.displayUnit}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (commodity.quality.isNotEmpty)
                  Text(
                    'Quality: ${commodity.displayQuality}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),

          // Price Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    commodity.isPriceUp ? Icons.trending_up : 
                    commodity.isPriceDown ? Icons.trending_down : Icons.trending_flat,
                    color: commodity.trendColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    commodity.displayChange,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: commodity.trendColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                commodity.displayPercentage,
                style: TextStyle(
                  fontSize: 12,
                  color: commodity.trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

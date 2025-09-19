import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../data/models/daily_update_model.dart';
import '../../../data/services/daily_update_service.dart';

class EnhancedDailyScreen extends StatefulWidget {
  const EnhancedDailyScreen({super.key});

  @override
  State<EnhancedDailyScreen> createState() => _EnhancedDailyScreenState();
}

class _EnhancedDailyScreenState extends State<EnhancedDailyScreen>
    with TickerProviderStateMixin {
  final DailyUpdateService _dailyUpdateService = DailyUpdateService();
  final TextEditingController _searchController = TextEditingController();
  
  List<DailyUpdateModel> _dailyUpdates = [];
  List<DailyUpdateModel> _filteredUpdates = [];
  Map<String, dynamic> _summary = {};
  
  bool _isLoading = true;
  bool _isSearching = false;
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  String _searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = [
    'All', 'Weather', 'Market', 'Crops', 'Alerts', 
    'Irrigation', 'Fertilizer', 'Pest', 'Equipment', 'Financial', 'System'
  ];
  
  final List<String> _priorities = ['All', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDailyUpdates();
    _loadSummary();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _loadDailyUpdates() async {
    try {
      setState(() => _isLoading = true);
      final updates = await _dailyUpdateService.getDailyUpdates();
      setState(() {
        _dailyUpdates = updates;
        _filteredUpdates = updates;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load daily updates: $e');
    }
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await _dailyUpdateService.getUpdatesSummary();
      setState(() => _summary = summary);
    } catch (e) {
      debugPrint('Error loading summary: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUpdates = _dailyUpdates.where((update) {
        bool categoryMatch = _selectedCategory == 'All' || 
                           update.category.toLowerCase() == _selectedCategory.toLowerCase();
        bool priorityMatch = _selectedPriority == 'All' || 
                           update.priority.toLowerCase() == _selectedPriority.toLowerCase();
        bool searchMatch = _searchQuery.isEmpty ||
                          update.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          update.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return categoryMatch && priorityMatch && searchMatch;
      }).toList();
    });
  }

  Future<void> _refreshUpdates() async {
    await _loadDailyUpdates();
    await _loadSummary();
    _showSuccessSnackBar('Updates refreshed');
  }

  Future<void> _markAsRead(DailyUpdateModel update) async {
    try {
      await _dailyUpdateService.markAsRead(update.id, true);
      setState(() {
        final index = _dailyUpdates.indexWhere((u) => u.id == update.id);
        if (index != -1) {
          _dailyUpdates[index] = _dailyUpdates[index].copyWith(isRead: true);
        }
      });
      _applyFilters();
      _loadSummary();
    } catch (e) {
      _showErrorSnackBar('Failed to mark as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _dailyUpdateService.markAllAsRead();
      setState(() {
        _dailyUpdates = _dailyUpdates.map((update) => 
          update.copyWith(isRead: true)
        ).toList();
      });
      _applyFilters();
      _loadSummary();
      _showSuccessSnackBar('All updates marked as read');
    } catch (e) {
      _showErrorSnackBar('Failed to mark all as read: $e');
    }
  }

  Future<void> _deleteUpdate(DailyUpdateModel update) async {
    try {
      await _dailyUpdateService.deleteDailyUpdate(update.id);
      setState(() {
        _dailyUpdates.removeWhere((u) => u.id == update.id);
      });
      _applyFilters();
      _loadSummary();
      _showSuccessSnackBar('Update deleted');
    } catch (e) {
      _showErrorSnackBar('Failed to delete update: $e');
    }
  }

  Future<void> _bookmarkUpdate(DailyUpdateModel update) async {
    try {
      await _dailyUpdateService.updateDailyUpdate(update.id, {
        'isBookmarked': !update.isBookmarked,
      });
      setState(() {
        final index = _dailyUpdates.indexWhere((u) => u.id == update.id);
        if (index != -1) {
          _dailyUpdates[index] = _dailyUpdates[index].copyWith(
            isBookmarked: !update.isBookmarked,
          );
        }
      });
      _applyFilters();
      _showSuccessSnackBar(
        update.isBookmarked ? 'Removed from bookmarks' : 'Added to bookmarks'
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update bookmark: $e');
    }
  }

  void _showUpdateDetail(DailyUpdateModel update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getIconData(update.icon),
              color: _getColorFromHex(update.color),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(update.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(update.description),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(update.priorityColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    update.priority,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(update.categoryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    update.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              update.formattedTime,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!update.isRead)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _markAsRead(update);
              },
              child: const Text('Mark as Read'),
            ),
        ],
      ),
    );
  }

  void _showUpdateOptions(DailyUpdateModel update) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                update.isBookmarked ? Icons.bookmark : Icons.bookmark_add,
                color: AppColors.primary,
              ),
              title: Text(update.isBookmarked ? 'Remove Bookmark' : 'Add Bookmark'),
              onTap: () {
                Navigator.pop(context);
                _bookmarkUpdate(update);
              },
            ),
            if (!update.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_read, color: AppColors.success),
                title: const Text('Mark as Read'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(update);
                },
              ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.info),
              title: const Text('Share Update'),
              onTap: () {
                Navigator.pop(context);
                _shareUpdate(update);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Update'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(update);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(DailyUpdateModel update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Update'),
        content: Text('Are you sure you want to delete "${update.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUpdate(update);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _shareUpdate(DailyUpdateModel update) {
    // Implement share functionality
    _showSuccessSnackBar('Share functionality coming soon');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny': return Icons.wb_sunny;
      case 'trending_up': return Icons.trending_up;
      case 'eco': return Icons.eco;
      case 'warning': return Icons.warning;
      case 'water_drop': return Icons.water_drop;
      case 'grass': return Icons.grass;
      case 'bug_report': return Icons.bug_report;
      case 'build': return Icons.build;
      case 'account_balance': return Icons.account_balance;
      case 'system_update': return Icons.system_update;
      default: return Icons.info;
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ResponsiveHelper.screenHeight(context);
    final screenWidth = ResponsiveHelper.screenWidth(context);
    
    return Scaffold(
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Updates',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshUpdates,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSummaryCard(screenWidth, screenHeight),
          ),

          // Search Bar
          SlideTransition(
            position: _slideAnimation,
            child: _buildSearchBar(screenWidth),
          ),

          // Filter Tabs
          SlideTransition(
            position: _slideAnimation,
            child: _buildFilterTabs(screenWidth),
          ),

          const SizedBox(height: 16),

          // Updates List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUpdates.isEmpty
                    ? _buildEmptyState()
                    : _buildUpdatesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.fontSizeXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  '${_summary['totalUpdates'] ?? 0} total • ${_summary['unreadCount'] ?? 0} unread',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: AppDimensions.fontSizeM,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _isSearching = value.isNotEmpty;
          });
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'Search updates...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilterTabs(double screenWidth) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                      _applyFilters();
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : AppTheme.textMedium,
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.fontSizeS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                      side: BorderSide(
                        color: _selectedCategory == category ? AppTheme.primaryGreen : AppTheme.mediumGrey,
                      ),
                    ),
                    elevation: _selectedCategory == category ? 4 : 0,
                    shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (priority) {
              setState(() => _selectedPriority = priority);
              _applyFilters();
            },
            itemBuilder: (context) => _priorities.map((priority) {
              return PopupMenuItem(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppTheme.mediumGrey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPriority),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No updates found',
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeXL,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMedium,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Try adjusting your filters or search terms',
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: AppDimensions.fontSizeM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredUpdates.length,
      itemBuilder: (context, index) {
        final update = _filteredUpdates[index];
        return _buildUpdateCard(update);
      },
    );
  }

  Widget _buildUpdateCard(DailyUpdateModel update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: _getColorFromHex(update.color).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.spacingL),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getColorFromHex(update.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Icon(
            _getIconData(update.icon),
            color: _getColorFromHex(update.color),
            size: AppDimensions.iconL,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                update.title,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeL,
                  fontWeight: FontWeight.bold,
                  color: update.isRead ? AppTheme.textMedium : AppTheme.textDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingS, vertical: AppDimensions.spacingXS),
              decoration: BoxDecoration(
                color: _getColorFromHex(update.priorityColor),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                update.priority,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppDimensions.fontSizeXS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              update.shortDescription,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeM,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                Text(
                  update.formattedTime,
                  style: const TextStyle(fontSize: AppDimensions.fontSizeS, color: AppTheme.textLight),
                ),
                const Spacer(),
                if (update.isBookmarked)
                  const Icon(Icons.bookmark, size: AppDimensions.iconS, color: AppTheme.primaryGreen),
                if (!update.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _showUpdateDetail(update),
        onLongPress: () => _showUpdateOptions(update),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: AppColors.success),
              title: const Text('Mark All as Read'),
              onTap: () {
                Navigator.pop(context);
                _markAllAsRead();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: AppColors.primary),
              title: const Text('Show Bookmarked Only'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _filteredUpdates = _dailyUpdates.where((u) => u.isBookmarked).toList();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.info),
              title: const Text('Preferences'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to preferences
              },
            ),
          ],
        ),
      ),
    );
  }
}

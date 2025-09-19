import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../data/models/daily_update_model.dart';
import '../../../data/services/daily_update_service.dart';

class DailyUpdateAdminScreen extends StatefulWidget {
  const DailyUpdateAdminScreen({super.key});

  @override
  State<DailyUpdateAdminScreen> createState() => _DailyUpdateAdminScreenState();
}

class _DailyUpdateAdminScreenState extends State<DailyUpdateAdminScreen> {
  final DailyUpdateService _dailyUpdateService = DailyUpdateService();
  final _formKey = GlobalKey<FormState>();
  
  List<DailyUpdateModel> _dailyUpdates = [];
  bool _isLoading = true;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Weather';
  String _selectedPriority = 'Medium';
  String _selectedIcon = 'wb_sunny';
  String _selectedColor = '#4CAF50';

  final List<String> _categories = [
    'Weather', 'Market', 'Crops', 'Alerts', 'Irrigation', 
    'Fertilizer', 'Pest', 'Equipment', 'Financial', 'System'
  ];
  
  final List<String> _priorities = ['High', 'Medium', 'Low'];
  
  final Map<String, String> _icons = {
    'wb_sunny': 'Weather',
    'trending_up': 'Market',
    'eco': 'Crops',
    'warning': 'Alerts',
    'water_drop': 'Irrigation',
    'grass': 'Fertilizer',
    'bug_report': 'Pest',
    'build': 'Equipment',
    'account_balance': 'Financial',
    'system_update': 'System',
    'info': 'General',
  };
  
  final Map<String, String> _colors = {
    '#2196F3': 'Blue',
    '#4CAF50': 'Green',
    '#FF9800': 'Orange',
    '#FF5722': 'Red',
    '#9C27B0': 'Purple',
    '#00BCD4': 'Cyan',
    '#607D8B': 'Blue Grey',
    '#795548': 'Brown',
    '#9E9E9E': 'Grey',
  };

  @override
  void initState() {
    super.initState();
    _loadDailyUpdates();
  }

  Future<void> _loadDailyUpdates() async {
    try {
      setState(() => _isLoading = true);
      final updates = await _dailyUpdateService.getDailyUpdates();
      setState(() {
        _dailyUpdates = updates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load updates: $e');
    }
  }

  void _showCreateUpdateDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedCategory = 'Weather';
    _selectedPriority = 'Medium';
    _selectedIcon = 'wb_sunny';
    _selectedColor = '#4CAF50';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Daily Update'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      // Auto-select appropriate icon and color
                      _selectedIcon = _getDefaultIconForCategory(value);
                      _selectedColor = _getDefaultColorForCategory(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: _priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPriority = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedIcon,
                        decoration: const InputDecoration(
                          labelText: 'Icon',
                          border: OutlineInputBorder(),
                        ),
                        items: _icons.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                Icon(_getIconData(entry.key)),
                                const SizedBox(width: 8),
                                Text(entry.value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedIcon = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedColor,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                  ),
                  items: _colors.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getColorFromHex(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedColor = value!);
                  },
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
            onPressed: _createUpdate,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final update = DailyUpdateModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      await _dailyUpdateService.createDailyUpdate(update);
      Navigator.pop(context);
      _loadDailyUpdates();
      _showSuccessSnackBar('Update created successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to create update: $e');
    }
  }

  Future<void> _deleteUpdate(DailyUpdateModel update) async {
    try {
      await _dailyUpdateService.deleteDailyUpdate(update.id);
      _loadDailyUpdates();
      _showSuccessSnackBar('Update deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete update: $e');
    }
  }

  void _showUpdateDetails(DailyUpdateModel update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            const SizedBox(height: 16),
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
              'Created: ${update.formattedTime}',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
            if (update.isRead)
              Text(
                'Status: Read',
                style: TextStyle(
                  color: AppColors.success,
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

  String _getDefaultIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'weather': return 'wb_sunny';
      case 'market': return 'trending_up';
      case 'crops': return 'eco';
      case 'alerts': return 'warning';
      case 'irrigation': return 'water_drop';
      case 'fertilizer': return 'grass';
      case 'pest': return 'bug_report';
      case 'equipment': return 'build';
      case 'financial': return 'account_balance';
      case 'system': return 'system_update';
      default: return 'info';
    }
  }

  String _getDefaultColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'weather': return '#2196F3';
      case 'market': return '#4CAF50';
      case 'crops': return '#8BC34A';
      case 'alerts': return '#FF5722';
      case 'irrigation': return '#00BCD4';
      case 'fertilizer': return '#9C27B0';
      case 'pest': return '#FF9800';
      case 'equipment': return '#607D8B';
      case 'financial': return '#795548';
      case 'system': return '#9E9E9E';
      default: return '#4CAF50';
    }
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    final screenHeight = ResponsiveHelper.screenHeight(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Updates Admin',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadDailyUpdates,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: EdgeInsets.all(screenWidth * 0.04),
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
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
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        '${_dailyUpdates.length} total updates',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Updates List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dailyUpdates.isEmpty
                    ? _buildEmptyState()
                    : _buildUpdatesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUpdateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No updates found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first daily update',
            style: TextStyle(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dailyUpdates.length,
      itemBuilder: (context, index) {
        final update = _dailyUpdates[index];
        return _buildUpdateCard(update);
      },
    );
  }

  Widget _buildUpdateCard(DailyUpdateModel update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getColorFromHex(update.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconData(update.icon),
            color: _getColorFromHex(update.color),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                update.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getColorFromHex(update.priorityColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                update.priority,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  update.formattedTime,
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(update.categoryColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    update.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showUpdateDetails(update),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteUpdate(update);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

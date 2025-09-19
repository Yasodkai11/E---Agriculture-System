import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../utils/sample_data_generator.dart';
import 'daily_update_admin_screen.dart';

class AdminTestScreen extends StatefulWidget {
  const AdminTestScreen({super.key});

  @override
  State<AdminTestScreen> createState() => _AdminTestScreenState();
}

class _AdminTestScreenState extends State<AdminTestScreen> {
  bool _isLoading = false;

  Future<void> _generateSampleData() async {
    setState(() => _isLoading = true);
    try {
      await SampleDataGenerator.generateSampleDailyUpdates();
      _showSuccessSnackBar('Sample data generated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate sample data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateWeatherUpdates() async {
    setState(() => _isLoading = true);
    try {
      await SampleDataGenerator.generateWeatherUpdates();
      _showSuccessSnackBar('Weather updates generated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate weather updates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateMarketUpdates() async {
    setState(() => _isLoading = true);
    try {
      await SampleDataGenerator.generateMarketUpdates();
      _showSuccessSnackBar('Market updates generated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate market updates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateCropUpdates() async {
    setState(() => _isLoading = true);
    try {
      await SampleDataGenerator.generateCropUpdates();
      _showSuccessSnackBar('Crop updates generated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate crop updates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all daily updates? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await SampleDataGenerator.clearAllDailyUpdates();
        _showSuccessSnackBar('All data cleared successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to clear data: $e');
      } finally {
        setState(() => _isLoading = false);
      }
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
          'Admin Test Panel',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Admin Test Panel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                const Text(
                                  'Generate sample data and manage daily updates',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Sample Data Generation Section
                _buildSection(
                  title: 'Sample Data Generation',
                  description: 'Generate sample daily updates for testing',
                  children: [
                    _buildActionCard(
                      icon: Icons.data_usage,
                      title: 'Generate All Sample Data',
                      subtitle: 'Create comprehensive sample updates',
                      onTap: _generateSampleData,
                      color: AppColors.primary,
                    ),
                    _buildActionCard(
                      icon: Icons.wb_sunny,
                      title: 'Generate Weather Updates',
                      subtitle: 'Create weather-related updates',
                      onTap: _generateWeatherUpdates,
                      color: const Color(0xFF2196F3),
                    ),
                    _buildActionCard(
                      icon: Icons.trending_up,
                      title: 'Generate Market Updates',
                      subtitle: 'Create market price updates',
                      onTap: _generateMarketUpdates,
                      color: const Color(0xFF4CAF50),
                    ),
                    _buildActionCard(
                      icon: Icons.eco,
                      title: 'Generate Crop Updates',
                      subtitle: 'Create crop-related updates',
                      onTap: _generateCropUpdates,
                      color: const Color(0xFF8BC34A),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),

                // Management Section
                _buildSection(
                  title: 'Data Management',
                  description: 'Manage existing daily updates',
                  children: [
                    _buildActionCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Daily Updates Admin',
                      subtitle: 'Create, edit, and delete updates',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DailyUpdateAdminScreen(),
                          ),
                        );
                      },
                      color: AppColors.info,
                    ),
                    _buildActionCard(
                      icon: Icons.delete_sweep,
                      title: 'Clear All Data',
                      subtitle: 'Delete all daily updates',
                      onTap: _clearAllData,
                      color: AppColors.error,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),

                // Information Section
                _buildSection(
                  title: 'Information',
                  description: 'Learn about the daily update system',
                  children: [
                    _buildInfoCard(
                      icon: Icons.info,
                      title: 'System Overview',
                      subtitle: 'The daily update system provides farmers with timely information about weather, market prices, crop management, and other agricultural activities.',
                    ),
                    _buildInfoCard(
                      icon: Icons.category,
                      title: 'Supported Categories',
                      subtitle: 'Weather, Market, Crops, Alerts, Irrigation, Fertilizer, Pest, Equipment, Financial, System',
                    ),
                    _buildInfoCard(
                      icon: Icons.priority_high,
                      title: 'Priority Levels',
                      subtitle: 'High (urgent), Medium (important), Low (general information)',
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.info,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

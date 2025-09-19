import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/core/constants/app_dimensions.dart';
import 'package:e_agriculture_system/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final List<DailyUpdate> dailyUpdates = [
    DailyUpdate(
      title: 'Weather Alert',
      description: 'Heavy rainfall expected in your area. Protect your crops.',
      time: '2 hours ago',
      icon: Icons.cloud_queue,
      color: const Color(0xFFFF9800),
      priority: 'High',
    ),
    DailyUpdate(
      title: 'Market Price Update',
      description: 'Rice prices increased by 5% in local markets.',
      time: '4 hours ago',
      icon: Icons.trending_up,
      color: const Color(0xFF4CAF50),
      priority: 'Medium',
    ),
    DailyUpdate(
      title: 'Pest Control Reminder',
      description: 'Time to check for pest infections in tomato crops.',
      time: '6 hours ago',
      icon: Icons.bug_report,
      color: const Color(0xFFFF5722),
      priority: 'High',
    ),
    DailyUpdate(
      title: 'Irrigation Schedule',
      description: 'Next irrigation recommended for wheat field.',
      time: '8 hours ago',
      icon: Icons.water_drop,
      color: const Color(0xFF2196F3),
      priority: 'Medium',
    ),
    DailyUpdate(
      title: 'Fertilizer Application',
      description: 'Apply nitrogen fertilizer to corn crops this week.',
      time: '1 day ago',
      icon: Icons.grass,
      color: const Color(0xFF9C27B0),
      priority: 'Low',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.dailyUpdates,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh updates
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.updatesRefreshed),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(AppDimensions.spacingL),
            padding: const EdgeInsets.all(AppDimensions.spacingXL),
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: AppDimensions.iconXL,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingL),
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
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        '5 new updates • 2 high priority',
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
          ),

          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Weather', false),
                _buildFilterChip('Market', false),
                _buildFilterChip('Crops', false),
                _buildFilterChip('Alerts', false),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Updates List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL),
              itemCount: dailyUpdates.length,
              itemBuilder: (context, index) {
                final update = dailyUpdates[index];
                return _buildUpdateCard(update);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: AppDimensions.spacingM),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Handle filter selection
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textMedium,
          fontWeight: FontWeight.w600,
          fontSize: AppDimensions.fontSizeS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.mediumGrey,
          ),
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
      ),
    );
  }

  Widget _buildUpdateCard(DailyUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: update.color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: update.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(update.icon, color: update.color, size: AppDimensions.iconL),
            ),

            const SizedBox(width: AppDimensions.spacingL),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          update.title,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeL,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingS,
                          vertical: AppDimensions.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(update.priority),
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
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    update.description,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeM,
                      color: AppTheme.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    update.time,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeS, 
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Action Button
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppTheme.textLight),
              onPressed: () {
                _showUpdateOptions(context, update);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.errorRed;
      case 'Medium':
        return AppTheme.warningOrange;
      case 'Low':
        return AppTheme.infoBlue;
      default:
        return AppTheme.infoBlue;
    }
  }

  void _showUpdateOptions(BuildContext context, DailyUpdate update) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.bookmark_add,
                  color: AppTheme.primaryGreen,
                ),
                title: const Text('Save Update'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: const Text('Update saved'),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: AppTheme.infoBlue),
                title: const Text('Share Update'),
                onTap: () {
                  Navigator.pop(context);
                  // Share functionality
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.notifications_off,
                  color: AppTheme.warningOrange,
                ),
                title: const Text('Mark as Read'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class DailyUpdate {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final String priority;

  DailyUpdate({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Weather Alert',
      description: 'Heavy rainfall expected in your area tomorrow. Take necessary precautions for your crops.',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.weather,
      isRead: false,
      priority: Priority.high,
    ),
    NotificationItem(
      title: 'Expert Response',
      description: 'Dr. Smith replied to your query about tomato plant diseases.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.chat,
      isRead: false,
      priority: Priority.medium,
    ),
    NotificationItem(
      title: 'Market Price Update',
      description: 'Rice prices have increased by 8% in the local market.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.market,
      isRead: true,
      priority: Priority.medium,
    ),
    NotificationItem(
      title: 'Irrigation Reminder',
      description: 'It\'s time to water your wheat field. Check soil moisture levels.',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      type: NotificationType.reminder,
      isRead: false,
      priority: Priority.low,
    ),
    NotificationItem(
      title: 'Pest Alert',
      description: 'Aphid infestation reported in nearby farms. Inspect your crops.',
      time: DateTime.now().subtract(const Duration(hours: 6)),
      type: NotificationType.pest,
      isRead: true,
      priority: Priority.high,
    ),
    NotificationItem(
      title: 'Fertilizer Application',
      description: 'Reminder: Apply phosphorus fertilizer to your corn crops this week.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.fertilizer,
      isRead: true,
      priority: Priority.low,
    ),
    NotificationItem(
      title: 'System Update',
      description: 'AGRIGO app has been updated with new features. Check what\'s new!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.system,
      isRead: true,
      priority: Priority.low,
    ),
  ];

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread messages',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog();
              } else if (value == 'settings') {
                // Navigate to notification settings
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Notification Settings'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterTab('All', notifications.length),
                _buildFilterTab('Unread', unreadCount),
                _buildFilterTab('Weather', notifications.where((n) => n.type == NotificationType.weather).length),
                _buildFilterTab('Market', notifications.where((n) => n.type == NotificationType.market).length),
                _buildFilterTab('Alerts', notifications.where((n) => n.priority == Priority.high).length),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(notification, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int count) {
    final isSelected = selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.removeAt(notifications.indexOf(notification));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  notifications.insert(index, notification);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (notification.priority == Priority.high)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'HIGH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.time),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Button
                IconButton(
                  icon: Icon(
                    notification.isRead ? Icons.more_vert : Icons.circle,
                    color: notification.isRead ? AppColors.textHint : AppColors.primary,
                    size: 16,
                  ),
                  onPressed: () => _showNotificationOptions(notification),
                ),
              ],
            ),
          ),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.notifications_off,
              size: 40,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationItem> _getFilteredNotifications() {
    switch (selectedFilter) {
      case 'Unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'Weather':
        return notifications.where((n) => n.type == NotificationType.weather).toList();
      case 'Market':
        return notifications.where((n) => n.type == NotificationType.market).toList();
      case 'Alerts':
        return notifications.where((n) => n.priority == Priority.high).toList();
      default:
        return notifications;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return Icons.wb_cloudy;
      case NotificationType.market:
        return Icons.trending_up;
      case NotificationType.pest:
        return Icons.bug_report;
      case NotificationType.fertilizer:
        return Icons.grass;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.chat:
        return Icons.chat;
      case NotificationType.system:
        return Icons.system_update;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return const Color(0xFF2196F3);
      case NotificationType.market:
        return const Color(0xFF4CAF50);
      case NotificationType.pest:
        return const Color(0xFFFF5722);
      case NotificationType.fertilizer:
        return const Color(0xFF8BC34A);
      case NotificationType.reminder:
        return const Color(0xFF9C27B0);
      case NotificationType.chat:
        return const Color(0xFF00BCD4);
      case NotificationType.system:
        return const Color(0xFF607D8B);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.chat:
        Navigator.pushNamed(context, '/expert-chat');
        break;
      case NotificationType.weather:
        Navigator.pushNamed(context, '/weather');
        break;
      case NotificationType.market:
        Navigator.pushNamed(context, '/market');
        break;
      default:
        // Show detailed notification
        _showNotificationDetail(notification);
    }
  }

  void _showNotificationDetail(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.description),
            const SizedBox(height: 12),
            Text(
              _formatTime(notification.time),
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
        ],
      ),
    );
  }

  void _showNotificationOptions(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  notification.isRead ? Icons.mark_as_unread : Icons.mark_email_read,
                  color: AppColors.primary,
                ),
                title: Text(notification.isRead ? 'Mark as Unread' : 'Mark as Read'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    notification.isRead = !notification.isRead;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    notifications.remove(notification);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

enum NotificationType {
  weather,
  market,
  pest,
  fertilizer,
  reminder,
  chat,
  system,
}

enum Priority {
  low,
  medium,
  high,
}

class NotificationItem {
  final String title;
  final String description;
  final DateTime time;
  final NotificationType type;
  bool isRead;
  final Priority priority;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.isRead,
    required this.priority,
  });
}
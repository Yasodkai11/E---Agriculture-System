import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../providers/notification_provider.dart';

class EnhancedNotificationScreen extends StatefulWidget {
  const EnhancedNotificationScreen({super.key});

  @override
  State<EnhancedNotificationScreen> createState() => _EnhancedNotificationScreenState();
}

class _EnhancedNotificationScreenState extends State<EnhancedNotificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  final String _selectedPriority = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize notification provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                onSelected: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All Notifications'),
                  ),
                  const PopupMenuItem(
                    value: 'unread',
                    child: Text('Unread Only'),
                  ),
                  const PopupMenuItem(
                    value: 'recent',
                    child: Text('Recent (24h)'),
                  ),
                  const PopupMenuItem(
                    value: 'high_priority',
                    child: Text('High Priority'),
                  ),
                ],
              );
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'mark_all_read':
                      provider.markAllAsRead();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(provider);
                      break;
                    case 'test_notification':
                      provider.sendTestNotification();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Text('Mark All as Read'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('Clear All'),
                  ),
                  const PopupMenuItem(
                    value: 'test_notification',
                    child: Text('Send Test Notification'),
                  ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.6),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Weather'),
            Tab(text: 'Market'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(provider, null),
              _buildNotificationList(provider, NotificationType.weather),
              _buildNotificationList(provider, NotificationType.market),
              _buildNotificationList(provider, NotificationType.system),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () => provider.sendTestNotification(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider provider, NotificationType? type) {
    List<NotificationModel> notifications = provider.notifications;

    // Apply type filter
    if (type != null) {
      notifications = notifications.where((n) => n.type == type).toList();
    }

    // Apply additional filters
    switch (_selectedFilter) {
      case 'unread':
        notifications = notifications.where((n) => !n.isRead).toList();
        break;
      case 'recent':
        notifications = notifications.where((n) => n.isRecent).toList();
        break;
      case 'high_priority':
        notifications = notifications.where((n) => 
          n.priority == NotificationPriority.high || 
          n.priority == NotificationPriority.urgent
        ).toList();
        break;
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.initialize(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, provider);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead 
              ? Colors.transparent 
              : _getPriorityColor(notification.priority).withOpacity(0.3),
          width: notification.isRead ? 0 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(notification, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPriorityColor(notification.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getPriorityColor(notification.priority),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification content
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
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: notification.isRead 
                                  ? Colors.grey.shade700 
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notification.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.type.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getTypeColor(notification.type),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(notification.priority),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notification.formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      if (!notification.isRead) {
                        provider.markAsRead(notification.id);
                      }
                      break;
                    case 'delete':
                      _showDeleteDialog(notification, provider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Text('Mark as Read'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification, NotificationProvider provider) {
    // Mark as read if not already read
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
    }

    // Navigate based on notification type or route
    if (notification.route != null) {
      Navigator.pushNamed(context, notification.route!);
    } else {
      _showNotificationDetail(notification);
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(notification.type),
              color: _getPriorityColor(notification.priority),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.type.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(notification.type),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(notification.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(notification.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.formattedTime,
              style: TextStyle(
                color: Colors.grey.shade600,
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

  void _showDeleteDialog(NotificationModel notification, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteNotification(notification.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(NotificationProvider provider) {
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
              provider.clearAllNotifications();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return Icons.wb_sunny;
      case NotificationType.market:
        return Icons.trending_up;
      case NotificationType.pest:
        return Icons.bug_report;
      case NotificationType.fertilizer:
        return Icons.eco;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.chat:
        return Icons.chat;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.order:
        return Icons.shopping_cart;
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.harvest:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.crop:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.equipment:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.buy_request:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.order_confirmation:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.daily_weather:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.green;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return Colors.blue;
      case NotificationType.market:
        return Colors.green;
      case NotificationType.pest:
        return Colors.red;
      case NotificationType.fertilizer:
        return Colors.brown;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.chat:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.order:
        return Colors.indigo;
      case NotificationType.general:
        return Colors.teal;
      case NotificationType.harvest:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.crop:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.equipment:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.buy_request:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.order_confirmation:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.daily_weather:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

























import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Map<String, dynamic> _settings = {};
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get settings => _settings;
  String? get error => _error;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      // Initialize notification service
      await _notificationService.initialize();

      // Load notification settings
      await _loadSettings();

      // Setup listeners
      _setupListeners();

      debugPrint('NotificationProvider initialized successfully');
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
      debugPrint('Error initializing NotificationProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Setup real-time listeners
  void _setupListeners() {
    // Listen to notifications stream
    _notificationService.notificationsStream.listen(
      (notifications) {
        _notifications = notifications;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load notifications: $error');
      },
    );

    // Listen to unread count stream
    _notificationService.unreadCountStream.listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load unread count: $error');
      },
    );
  }

  // Load notification settings
  Future<void> _loadSettings() async {
    try {
      _settings = await _notificationService.getNotificationSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
    String? route,
  }) async {
    try {
      _clearError();
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        type: type,
        priority: priority,
        data: data,
        route: route,
      );
    } catch (e) {
      _setError('Failed to send notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      _clearError();
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      _clearError();
      await _notificationService.markAllAsRead();
    } catch (e) {
      _setError('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      _clearError();
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      _setError('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      _clearError();
      await _notificationService.clearAllNotifications();
    } catch (e) {
      _setError('Failed to clear all notifications: $e');
    }
  }

  // Update notification settings
  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      _clearError();
      await _notificationService.updateNotificationSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update notification settings: $e');
    }
  }

  // Get filtered notifications
  List<NotificationModel> getFilteredNotifications({
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    bool? isRecent,
  }) {
    return _notifications.where((notification) {
      if (type != null && notification.type != type) return false;
      if (priority != null && notification.priority != priority) return false;
      if (isRead != null && notification.isRead != isRead) return false;
      if (isRecent != null && notification.isRecent != isRecent) return false;
      return true;
    }).toList();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get recent notifications (last 24 hours)
  List<NotificationModel> get recentNotifications {
    return _notifications.where((n) => n.isRecent).toList();
  }

  // Get high priority notifications
  List<NotificationModel> get highPriorityNotifications {
    return _notifications.where((n) => 
      n.priority == NotificationPriority.high || 
      n.priority == NotificationPriority.urgent
    ).toList();
  }

  // Check if setting is enabled
  bool isSettingEnabled(String setting) {
    return _settings[setting] == true;
  }

  // Toggle setting
  Future<void> toggleSetting(String setting) async {
    final newSettings = Map<String, dynamic>.from(_settings);
    newSettings[setting] = !(_settings[setting] ?? false);
    await updateSettings(newSettings);
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    await sendNotification(
      userId: _notificationService.currentUserId ?? '',
      title: 'Test Notification',
      body: 'This is a test notification from E-Agriculture System',
      type: NotificationType.system,
      priority: NotificationPriority.medium,
    );
  }

  // Send weather alert
  Future<void> sendWeatherAlert({
    required String userId,
    required String alert,
    required String description,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Weather Alert: $alert',
      body: description,
      type: NotificationType.weather,
      priority: NotificationPriority.high,
      route: '/weather',
    );
  }

  // Send market update
  Future<void> sendMarketUpdate({
    required String userId,
    required String crop,
    required String priceChange,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Market Update: $crop',
      body: 'Price has $priceChange',
      type: NotificationType.market,
      priority: NotificationPriority.medium,
      route: '/market-prices',
    );
  }

  // Send crop reminder
  Future<void> sendCropReminder({
    required String userId,
    required String crop,
    required String reminder,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Crop Reminder: $crop',
      body: reminder,
      type: NotificationType.reminder,
      priority: NotificationPriority.medium,
      route: '/crop-monitor',
    );
  }

  // Send expert chat notification
  Future<void> sendExpertChatNotification({
    required String userId,
    required String expertName,
    required String message,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Expert Response from $expertName',
      body: message,
      type: NotificationType.chat,
      priority: NotificationPriority.medium,
      route: '/expert-chat',
    );
  }

  // Send order update
  Future<void> sendOrderUpdate({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Order Update: #$orderId',
      body: 'Your order status: $status',
      type: NotificationType.order,
      priority: NotificationPriority.medium,
      route: '/my-orders',
    );
  }

  // Send daily weather notification
  Future<void> sendDailyWeatherNotification({
    required String userId,
    required String city,
    required String currentTemp,
    required String condition,
    required String forecast,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Daily Weather Update - $city',
      body: 'Current: $currentTemp°C, $condition. $forecast',
      type: NotificationType.daily_weather,
      priority: NotificationPriority.medium,
      route: '/weather',
      data: {
        'city': city,
        'temperature': currentTemp,
        'condition': condition,
        'forecast': forecast,
      },
    );
  }

  // Send harvest notification to farmer
  Future<void> sendHarvestNotification({
    required String farmerId,
    required String cropName,
    required String harvestDate,
    required String quantity,
  }) async {
    await sendNotification(
      userId: farmerId,
      title: 'Harvest Ready: $cropName',
      body: '$quantity ready for harvest on $harvestDate. Check your fields!',
      type: NotificationType.harvest,
      priority: NotificationPriority.high,
      route: '/harvest-management',
      data: {
        'crop': cropName,
        'harvest_date': harvestDate,
        'quantity': quantity,
      },
    );
  }

  // Send crop notification to farmer
  Future<void> sendCropNotification({
    required String farmerId,
    required String cropName,
    required String message,
    required String action,
  }) async {
    await sendNotification(
      userId: farmerId,
      title: 'Crop Alert: $cropName',
      body: message,
      type: NotificationType.crop,
      priority: NotificationPriority.medium,
      route: '/crop-monitor',
      data: {
        'crop': cropName,
        'action': action,
      },
    );
  }

  // Send equipment notification to farmer
  Future<void> sendEquipmentNotification({
    required String farmerId,
    required String equipmentName,
    required String message,
    required String maintenanceDate,
  }) async {
    await sendNotification(
      userId: farmerId,
      title: 'Equipment Alert: $equipmentName',
      body: message,
      type: NotificationType.equipment,
      priority: NotificationPriority.medium,
      route: '/equipment-management',
      data: {
        'equipment': equipmentName,
        'maintenance_date': maintenanceDate,
      },
    );
  }

  // Send buy request notification to farmer (when buyer wants to buy)
  Future<void> sendBuyRequestNotification({
    required String farmerId,
    required String buyerName,
    required String productName,
    required String quantity,
    required String price,
    required String orderId,
  }) async {
    await sendNotification(
      userId: farmerId,
      title: 'New Buy Request from $buyerName',
      body: 'Wants to buy $quantity of $productName for Rs. $price',
      type: NotificationType.buy_request,
      priority: NotificationPriority.high,
      route: '/farmer-orders',
      data: {
        'buyer_name': buyerName,
        'product': productName,
        'quantity': quantity,
        'price': price,
        'order_id': orderId,
      },
    );
  }

  // Send order confirmation notification to buyer (when farmer confirms)
  Future<void> sendOrderConfirmationNotification({
    required String buyerId,
    required String farmerName,
    required String productName,
    required String quantity,
    required String orderId,
    required String status,
  }) async {
    await sendNotification(
      userId: buyerId,
      title: 'Order Confirmed by $farmerName',
      body: 'Your order for $quantity of $productName has been $status',
      type: NotificationType.order_confirmation,
      priority: NotificationPriority.high,
      route: '/buyer-orders',
      data: {
        'farmer_name': farmerName,
        'product': productName,
        'quantity': quantity,
        'order_id': orderId,
        'status': status,
      },
    );
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}


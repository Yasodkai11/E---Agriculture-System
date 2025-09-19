import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Collections
  CollectionReference get notificationsCollection => _firestore.collection('notifications');
  CollectionReference get userTokensCollection => _firestore.collection('user_tokens');
  CollectionReference get notificationSettingsCollection => _firestore.collection('notification_settings');

  // Stream controllers for real-time updates
  final StreamController<List<NotificationModel>> _notificationsController = 
      StreamController<List<NotificationModel>>.broadcast();
  final StreamController<int> _unreadCountController = 
      StreamController<int>.broadcast();

  // Getters for streams
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize the notification service
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request notification permissions
      await _requestPermissions();
      
      // Setup FCM
      await _setupFirebaseMessaging();
      
      // Setup real-time listeners
      await _setupRealtimeListeners();
      
      // Register device token
      await _registerDeviceToken();
      
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Skip local notifications on web
    if (kIsWeb) return;
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    // Skip permissions on web
    if (kIsWeb) return;
    
    // Request FCM permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');

    // Request local notification permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Setup Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Skip FCM setup on web
    if (kIsWeb) return;
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // Setup real-time listeners
  Future<void> _setupRealtimeListeners() async {
    if (currentUserId == null) return;

    // Listen to user notifications
    notificationsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      _notificationsController.add(notifications);
      
      // Update unread count
      final unreadCount = notifications.where((n) => !n.isRead).length;
      _unreadCountController.add(unreadCount);
    });
  }

  // Register device token for push notifications
  Future<void> _registerDeviceToken() async {
    // Skip token registration on web
    if (kIsWeb) return;
    
    try {
      final token = await _messaging.getToken();
      if (token != null && currentUserId != null) {
        await userTokensCollection.doc(currentUserId).set({
          'token': token,
          'userId': currentUserId,
          'platform': defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Device token registered: $token');
      }
    } catch (e) {
      debugPrint('Error registering device token: $e');
    }
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(message);
    
    // Add to local storage
    await _addNotificationToLocalStorage(message);
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    // Navigate to appropriate screen based on notification data
    final data = message.data;
    if (data.containsKey('route')) {
      // Handle navigation
      _navigateToRoute(data['route']);
    }
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      if (data.containsKey('route')) {
        _navigateToRoute(data['route']);
      }
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'e_agriculture_channel',
      'E-Agriculture Notifications',
      channelDescription: 'Notifications for E-Agriculture System',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  // Add notification to local storage
  Future<void> _addNotificationToLocalStorage(RemoteMessage message) async {
    if (currentUserId == null) return;

    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      type: _getNotificationType(message.data['type'] ?? 'general'),
      priority: _getNotificationPriority(message.data['priority'] ?? 'medium'),
      isRead: false,
      createdAt: DateTime.now(),
      data: message.data,
    );

    await notificationsCollection.add(notification.toMap());
  }

  // Navigate to route
  void _navigateToRoute(String route) {
    // This will be handled by the main app navigation
    debugPrint('Navigate to route: $route');
  }

  // Send notification to user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
    String? route,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: type,
        priority: priority,
        isRead: false,
        createdAt: DateTime.now(),
        data: data ?? {},
      );

      // Save to Firestore
      await notificationsCollection.add({
        ...notification.toMap(),
        'userId': userId,
      });

      // Send push notification via FCM
      await _sendPushNotification(userId, title, body, data, route);

      debugPrint('Notification sent to user: $userId');
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  // Send push notification via FCM
  Future<void> _sendPushNotification(
    String userId,
    String title,
    String body,
    Map<String, dynamic>? data,
    String? route,
  ) async {
    try {
      // Get user's device token
      final tokenDoc = await userTokensCollection.doc(userId).get();
      if (!tokenDoc.exists) return;

      final tokenData = tokenDoc.data() as Map<String, dynamic>;
      final token = tokenData['token'] as String;

      // Send notification via HTTP request to FCM
      // This would typically be done from your backend server
      debugPrint('Would send push notification to token: $token');
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await notificationsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await notificationsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  // Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    if (currentUserId == null) return {};

    try {
      final doc = await notificationSettingsCollection.doc(currentUserId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return _getDefaultSettings();
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      return _getDefaultSettings();
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    if (currentUserId == null) return;

    try {
      await notificationSettingsCollection.doc(currentUserId).set({
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }

  // Get default notification settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'pushNotifications': true,
      'emailNotifications': true,
      'smsNotifications': false,
      'marketUpdates': true,
      'weatherAlerts': true,
      'cropReminders': true,
      'priceAlerts': true,
      'expertChatNotifications': true,
      'dailyUpdates': true,
      'orderUpdates': true,
      'systemUpdates': true,
      'quietHours': {
        'enabled': false,
        'startTime': '22:00',
        'endTime': '07:00',
      },
    };
  }

  // Helper methods
  NotificationType _getNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'weather':
        return NotificationType.weather;
      case 'market':
        return NotificationType.market;
      case 'pest':
        return NotificationType.pest;
      case 'fertilizer':
        return NotificationType.fertilizer;
      case 'reminder':
        return NotificationType.reminder;
      case 'chat':
        return NotificationType.chat;
      case 'system':
        return NotificationType.system;
      case 'order':
        return NotificationType.order;
      case 'harvest':
        return NotificationType.harvest;
      case 'crop':
        return NotificationType.crop;
      case 'equipment':
        return NotificationType.equipment;
      case 'buy_request':
        return NotificationType.buy_request;
      case 'order_confirmation':
        return NotificationType.order_confirmation;
      case 'daily_weather':
        return NotificationType.daily_weather;
      default:
        return NotificationType.general;
    }
  }

  NotificationPriority _getNotificationPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return NotificationPriority.high;
      case 'medium':
        return NotificationPriority.medium;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.medium;
    }
  }

  // Dispose resources
  void dispose() {
    _notificationsController.close();
    _unreadCountController.close();
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

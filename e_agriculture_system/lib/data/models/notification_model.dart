import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  weather,
  market,
  pest,
  fertilizer,
  reminder,
  chat,
  system,
  order,
  general,
  harvest,
  crop,
  equipment,
  buy_request,
  order_confirmation,
  daily_weather,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic> data;
  final String? userId;
  final String? route;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data = const {},
    this.userId,
    this.route,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'data': data,
      'userId': userId,
      'route': route,
    };
  }

  // Create from Map (Firestore)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: _parseNotificationType(map['type']),
      priority: _parseNotificationPriority(map['priority']),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      userId: map['userId'],
      route: map['route'],
    );
  }

  // Create copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    String? userId,
    String? route,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      userId: userId ?? this.userId,
      route: route ?? this.route,
    );
  }

  // Helper methods
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
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
      default:
        return NotificationType.general;
    }
  }

  static NotificationPriority _parseNotificationPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return NotificationPriority.urgent;
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

  // Get notification icon
  String get iconName {
    switch (type) {
      case NotificationType.weather:
        return 'weather';
      case NotificationType.market:
        return 'market';
      case NotificationType.pest:
        return 'pest';
      case NotificationType.fertilizer:
        return 'fertilizer';
      case NotificationType.reminder:
        return 'reminder';
      case NotificationType.chat:
        return 'chat';
      case NotificationType.system:
        return 'system';
      case NotificationType.order:
        return 'order';
      case NotificationType.general:
        return 'notification';
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

  // Get priority color
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.urgent:
        return 'red';
      case NotificationPriority.high:
        return 'orange';
      case NotificationPriority.medium:
        return 'blue';
      case NotificationPriority.low:
        return 'green';
    }
  }

  // Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  // Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, priority: $priority, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


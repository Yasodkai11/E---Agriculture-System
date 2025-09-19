import 'package:cloud_firestore/cloud_firestore.dart';

class DailyUpdateModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String icon;
  final String color;
  final bool isRead;
  final bool isBookmarked;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final Map<String, dynamic>? metadata;

  DailyUpdateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.isBookmarked = false,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.metadata,
  });

  // Create from Firestore document
  factory DailyUpdateModel.fromMap(Map<String, dynamic> map, String id) {
    return DailyUpdateModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      priority: map['priority'] ?? 'Medium',
      icon: map['icon'] ?? 'info',
      color: map['color'] ?? '#4CAF50',
      isRead: map['isRead'] ?? false,
      isBookmarked: map['isBookmarked'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      userId: map['userId'],
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  // Helper method to parse DateTime from various formats (nullable)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    
    if (value is Timestamp) return value.toDate();
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'icon': icon,
      'color': color,
      'isRead': isRead,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'userId': userId,
      'metadata': metadata,
    };
  }

  // Create a copy with updated fields
  DailyUpdateModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? icon,
    String? color,
    bool? isRead,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return DailyUpdateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get formatted time string
  String get formattedTime {
    if (createdAt == null) return 'Unknown time';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  // Get priority color
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return '#FF5722';
      case 'medium':
        return '#FF9800';
      case 'low':
        return '#4CAF50';
      default:
        return '#4CAF50';
    }
  }

  // Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'weather':
        return 'wb_sunny';
      case 'market':
        return 'trending_up';
      case 'crops':
        return 'eco';
      case 'alerts':
        return 'warning';
      case 'irrigation':
        return 'water_drop';
      case 'fertilizer':
        return 'grass';
      case 'pest':
        return 'bug_report';
      case 'equipment':
        return 'build';
      case 'financial':
        return 'account_balance';
      case 'system':
        return 'system_update';
      default:
        return 'info';
    }
  }

  // Get category color
  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'weather':
        return '#2196F3';
      case 'market':
        return '#4CAF50';
      case 'crops':
        return '#8BC34A';
      case 'alerts':
        return '#FF5722';
      case 'irrigation':
        return '#00BCD4';
      case 'fertilizer':
        return '#9C27B0';
      case 'pest':
        return '#FF9800';
      case 'equipment':
        return '#607D8B';
      case 'financial':
        return '#795548';
      case 'system':
        return '#9E9E9E';
      default:
        return '#4CAF50';
    }
  }

  // Check if update is from today
  bool get isFromToday {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final updateDate = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    return today.isAtSameMomentAs(updateDate);
  }

  // Check if update is from this week
  bool get isFromThisWeek {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt!.isAfter(weekAgo);
  }

  // Get short description (truncated)
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'icon': icon,
      'color': color,
      'isRead': isRead,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory DailyUpdateModel.fromJson(Map<String, dynamic> json) {
    return DailyUpdateModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium',
      icon: json['icon'] ?? 'info',
      color: json['color'] ?? '#4CAF50',
      isRead: json['isRead'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      userId: json['userId'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'DailyUpdateModel(id: $id, title: $title, category: $category, priority: $priority, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyUpdateModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

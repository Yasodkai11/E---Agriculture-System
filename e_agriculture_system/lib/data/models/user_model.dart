import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final String userType; // farmer, expert, admin, buyer
  final bool isVerified;
  final bool isPhoneVerified;
  final String? location;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.userType = 'farmer',
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.location,
    this.latitude,
    this.longitude,
  });

  // Role-based access control methods
  bool get isFarmer => userType == 'farmer';
  bool get isBuyer => userType == 'buyer';
  bool get isExpert => userType == 'expert';
  bool get isAdmin => userType == 'admin';
  
  // Permission methods
  bool canAccessFarmerDashboard() => isFarmer || isAdmin;
  bool canAccessBuyerDashboard() => isBuyer || isAdmin;
  bool canSellProducts() => isFarmer || isAdmin;
  bool canBuyProducts() => isBuyer || isAdmin;
  bool canManageOrders() => isFarmer || isBuyer || isAdmin;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
      'userType': userType,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: _parseDateTimeRequired(map['createdAt']),
      updatedAt: _parseDateTimeRequired(map['updatedAt']),
      preferences: map['preferences'],
      userType: map['userType'] ?? 'farmer',
      isVerified: map['isVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
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

  // Helper method to parse DateTime from various formats (required - never null)
  static DateTime _parseDateTimeRequired(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is DateTime) return value;
    
    if (value is Timestamp) return value.toDate();
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    String? userType,
    bool? isVerified,
    bool? isPhoneVerified,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      userType: userType ?? this.userType,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

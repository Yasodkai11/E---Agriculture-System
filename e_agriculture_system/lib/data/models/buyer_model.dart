import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final String userType;
  final bool isVerified;
  final bool isPhoneVerified;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? businessName;
  final String? businessType;
  final String? businessLicense;
  final String? taxId;

  BuyerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.userType = 'buyer',
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.location,
    this.latitude,
    this.longitude,
    this.businessName,
    this.businessType,
    this.businessLicense,
    this.taxId,
  });

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
      'businessName': businessName,
      'businessType': businessType,
      'businessLicense': businessLicense,
      'taxId': taxId,
    };
  }

  factory BuyerModel.fromMap(Map<String, dynamic> map) {
    return BuyerModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: _parseDateTimeRequired(map['createdAt']),
      updatedAt: _parseDateTimeRequired(map['updatedAt']),
      preferences: map['preferences'],
      userType: map['userType'] ?? 'buyer',
      isVerified: map['isVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      businessName: map['businessName'],
      businessType: map['businessType'],
      businessLicense: map['businessLicense'],
      taxId: map['taxId'],
    );
  }

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
}


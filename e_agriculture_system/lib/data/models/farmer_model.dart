import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerModel {
  final String id;
  final String name;
  final String location;
  final String district;
  final String contactNumber;
  final String email;
  final String profileImage;
  final List<String> crops;
  final List<String> livestock;
  final String farmSize;
  final String experience;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final String bio;
  final Map<String, dynamic> certifications;
  final DateTime joinedDate;
  final bool isOnline;
  final Map<String, dynamic> socialMedia;

  FarmerModel({
    required this.id,
    required this.name,
    required this.location,
    required this.district,
    required this.contactNumber,
    required this.email,
    required this.profileImage,
    required this.crops,
    required this.livestock,
    required this.farmSize,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.bio,
    required this.certifications,
    required this.joinedDate,
    required this.isOnline,
    required this.socialMedia,
  });

  factory FarmerModel.fromMap(Map<String, dynamic> map) {
    return FarmerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      district: map['district'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      crops: List<String>.from(map['crops'] ?? []),
      livestock: List<String>.from(map['livestock'] ?? []),
      farmSize: map['farmSize'] ?? '',
      experience: map['experience'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      bio: map['bio'] ?? '',
      certifications: Map<String, dynamic>.from(map['certifications'] ?? {}),
      joinedDate: _parseDateTimeRequired(map['joinedDate']),
      isOnline: map['isOnline'] ?? false,
      socialMedia: Map<String, dynamic>.from(map['socialMedia'] ?? {}),
    );
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'district': district,
      'contactNumber': contactNumber,
      'email': email,
      'profileImage': profileImage,
      'crops': crops,
      'livestock': livestock,
      'farmSize': farmSize,
      'experience': experience,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'bio': bio,
      'certifications': certifications,
      'joinedDate': joinedDate,
      'isOnline': isOnline,
      'socialMedia': socialMedia,
    };
  }

  String get displayName => name;
  String get displayLocation => '$location, $district';
  String get displayCrops => crops.join(', ');
  String get displayLivestock => livestock.join(', ');
  String get experienceText => '$experience years of experience';
  String get ratingText => '$rating ($reviewCount reviews)';
  String get verificationStatus => isVerified ? 'Verified Farmer' : 'Farmer';
  String get onlineStatus => isOnline ? 'Online' : 'Offline';
  String get joinedText => 'Joined ${_formatDate(joinedDate)}';

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  FarmerModel copyWith({
    String? id,
    String? name,
    String? location,
    String? district,
    String? contactNumber,
    String? email,
    String? profileImage,
    List<String>? crops,
    List<String>? livestock,
    String? farmSize,
    String? experience,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    String? bio,
    Map<String, dynamic>? certifications,
    DateTime? joinedDate,
    bool? isOnline,
    Map<String, dynamic>? socialMedia,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      district: district ?? this.district,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      crops: crops ?? this.crops,
      livestock: livestock ?? this.livestock,
      farmSize: farmSize ?? this.farmSize,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      certifications: certifications ?? this.certifications,
      joinedDate: joinedDate ?? this.joinedDate,
      isOnline: isOnline ?? this.isOnline,
      socialMedia: socialMedia ?? this.socialMedia,
    );
  }

  @override
  String toString() {
    return 'FarmerModel(id: $id, name: $name, location: $location, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

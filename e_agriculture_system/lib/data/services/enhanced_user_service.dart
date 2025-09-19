import 'dart:math' show cos, sin, sqrt, atan2, pi;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'imagebb_service.dart';
import 'package:image_picker/image_picker.dart';

class EnhancedUserService {
  static final EnhancedUserService _instance = EnhancedUserService._internal();
  factory EnhancedUserService() => _instance;
  EnhancedUserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageBBService _imageBBService = ImageBBService();

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  /// Create a new user with comprehensive data
  Future<UserModel> createUserWithDetails({
    required String uid,
    required String fullName,
    required String email,
    required String phoneNumber,
    String userType = 'farmer',
    String? location,
    double? latitude,
    double? longitude,
    dynamic profileImage, // Using dynamic to avoid dart:io import
    Map<String, dynamic>? preferences,
  }) async {
    try {
      String? profileImageUrl;
      
      // Upload profile image if provided
      if (profileImage != null) {
        profileImageUrl = await uploadProfileImage(uid, profileImage);
      }

      // Create user model
      final userModel = UserModel(
        id: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userType: userType,
        location: location,
        latitude: latitude,
        longitude: longitude,
        preferences: preferences ?? {},
        isVerified: false,
        isPhoneVerified: false,
      );

      // Save to Firestore
      await _usersCollection.doc(uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get current user data
  Future<UserModel?> getCurrentUserData() async {
    if (currentUserId == null) return null;
    return await getUserById(currentUserId!);
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? location,
    double? latitude,
    double? longitude,
    String? userType,
    dynamic profileImage, // Using dynamic to avoid dart:io import
    Map<String, dynamic>? preferences,
    bool? isVerified,
    bool? isPhoneVerified,
  }) async {
    try {
      // Get current user data
      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      String? profileImageUrl = currentUser.profileImageUrl;

      // Upload new profile image if provided
      if (profileImage != null) {
        profileImageUrl = await uploadProfileImage(userId, profileImage);
      }

      // Create update data
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (location != null) updateData['location'] = location;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (userType != null) updateData['userType'] = userType;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (preferences != null) updateData['preferences'] = preferences;
      if (isVerified != null) updateData['isVerified'] = isVerified;
      if (isPhoneVerified != null) updateData['isPhoneVerified'] = isPhoneVerified;

      // Update in Firestore
      await _usersCollection.doc(userId).update(updateData);

      // Return updated user model
      return await getUserById(userId) ?? currentUser;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Upload profile image using ImageBB
  Future<String> uploadProfileImage(String userId, dynamic imageFile) async {
    try {
      // Convert File to XFile for ImageBB service
      final xFile = XFile(imageFile.path);
      
      // Upload to ImageBB
      final response = await _imageBBService.uploadImage(
        imageFile: xFile,
        name: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (response.success) {
        return response.data.displayUrl;
      } else {
        throw Exception('ImageBB upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete profile image using unified storage
  Future<void> deleteProfileImage(String userId) async {
    try {
      // For unified storage, we need to know the image path
      // This is a simplified implementation - you might need to store the path
      // or implement a different approach based on your storage type
      debugPrint('Profile image deletion handled by unified storage system');
    } catch (e) {
      // Image might not exist, ignore error
      debugPrint('Failed to delete profile image: $e');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else {
      throw Exception('User not found or already verified');
    }
  }

  /// Update email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified) async {
    try {
      await _usersCollection.doc(userId).update({
        'isVerified': isVerified,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  /// Update phone verification status
  Future<void> updatePhoneVerificationStatus(String userId, bool isVerified) async {
    try {
      await _usersCollection.doc(userId).update({
        'isPhoneVerified': isVerified,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update phone verification status: $e');
    }
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not authenticated');
      }

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _usersCollection.doc(userId).update({
        'preferences': preferences,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  /// Get users by type (e.g., experts, farmers)
  Future<List<UserModel>> getUsersByType(String userType) async {
    try {
      final querySnapshot = await _usersCollection
          .where('userType', isEqualTo: userType)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by type: $e');
    }
  }

  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      
      // Search by full name
      final nameQuery = await _usersCollection
          .orderBy('fullName')
          .startAt([lowerQuery])
          .endAt(['$lowerQuery\uf8ff'])
          .get();

      // Search by email
      final emailQuery = await _usersCollection
          .orderBy('email')
          .startAt([lowerQuery])
          .endAt(['$lowerQuery\uf8ff'])
          .get();

      final Set<String> userIds = {};
      final List<UserModel> users = [];

      // Combine results and remove duplicates
      for (final doc in [...nameQuery.docs, ...emailQuery.docs]) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
      }

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get users by location (nearby users)
  Future<List<UserModel>> getUsersByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      // Simple bounding box query (for more precise distance calculation, you'd need a geohash library)
      final latRange = radiusKm / 111.0; // Roughly 111 km per degree
      final lonRange = radiusKm / (111.0 * cos(latitude * pi / 180.0));

      final querySnapshot = await _usersCollection
          .where('latitude', isGreaterThanOrEqualTo: latitude - latRange)
          .where('latitude', isLessThanOrEqualTo: latitude + latRange)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) {
            if (user.latitude == null || user.longitude == null) return false;
            
            // Calculate approximate distance
            final distance = _calculateDistance(
              latitude, longitude,
              user.latitude!, user.longitude!,
            );
            
            return distance <= radiusKm;
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by location: $e');
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth's radius in km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user data from Firestore
      await _usersCollection.doc(userId).delete();

      // Delete profile image from Storage
      await deleteProfileImage(userId);

      // Delete Firebase Auth user
      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');

      final stats = <String, dynamic>{
        'joinDate': user.createdAt.toIso8601String(),
        'lastUpdated': user.updatedAt.toIso8601String(),
        'isVerified': user.isVerified,
        'isPhoneVerified': user.isPhoneVerified,
        'hasProfileImage': user.profileImageUrl != null,
        'userType': user.userType,
        'hasLocation': user.location != null,
        'hasCoordinates': user.latitude != null && user.longitude != null,
        'preferencesCount': user.preferences?.length ?? 0,
      };

      return stats;
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  /// Stream user changes
  Stream<UserModel?> streamUser(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(doc.data() as Map<String, dynamic>);
          }
          return null;
        });
  }

  /// Stream current user changes
  Stream<UserModel?> streamCurrentUser() {
    if (currentUserId == null) {
      return Stream.value(null);
    }
    return streamUser(currentUserId!);
  }

  /// Check if username is available (if you want unique usernames)
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
    }
  }

  /// Link phone number to existing account
  Future<void> linkPhoneNumber(String phoneNumber, String verificationId, String smsCode) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await user.linkWithCredential(credential);
      
      // Update phone verification status
      if (currentUserId != null) {
        await updatePhoneVerificationStatus(currentUserId!, true);
      }
    } catch (e) {
      throw Exception('Failed to link phone number: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  // Initialize Firebase services with error handling
  void _initializeServices() {
    try {
      _firestore ??= FirebaseFirestore.instance;
      _auth ??= FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Error initializing Firebase services: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth?.currentUser;
  String? get currentUserId => _auth?.currentUser?.uid;

  // Collections
  CollectionReference? get usersCollection => _firestore?.collection('users');
  CollectionReference? get cropsCollection => _firestore?.collection('crops');
  CollectionReference? get weatherCollection => _firestore?.collection('weather');
  CollectionReference? get chatCollection => _firestore?.collection('chats');
  CollectionReference? get equipmentCollection => _firestore?.collection('equipment');
  CollectionReference? get notificationCollection => _firestore?.collection('notifications');
  CollectionReference? get dailyUpdatesCollection => _firestore?.collection('daily_updates');

  // User Management
  Future<void> createUser(UserModel user) async {
    try {
      _initializeServices();
      if (usersCollection != null) {
        await usersCollection!.doc(user.id).set(user.toMap());
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      _initializeServices();
      if (usersCollection != null) {
        final doc = await usersCollection!.doc(userId).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
        return null;
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      _initializeServices();
      if (usersCollection != null) {
        await usersCollection!.doc(userId).update(data);
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _initializeServices();
      if (usersCollection != null) {
        await usersCollection!.doc(userId).delete();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Crop Management
  Future<void> addCrop(Map<String, dynamic> cropData) async {
    try {
      _initializeServices();
      if (cropsCollection != null) {
        await cropsCollection!.add(cropData);
      } else {
        debugPrint('Firestore not initialized, crop not added');
        // Don't throw exception, just log the error
      }
    } catch (e) {
      debugPrint('Failed to add crop: $e');
      // Don't throw exception, just log the error
    }
  }

  Future<List<Map<String, dynamic>>> getCrops() async {
    try {
      _initializeServices();
      if (cropsCollection != null) {
        final snapshot = await cropsCollection!.get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get crops: $e');
    }
  }

  // Weather Management
  Future<void> addWeatherData(Map<String, dynamic> weatherData) async {
    try {
      _initializeServices();
      if (weatherCollection != null) {
        await weatherCollection!.add(weatherData);
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to add weather data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWeatherData() async {
    try {
      _initializeServices();
      if (weatherCollection != null) {
        final snapshot = await weatherCollection!.get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get weather data: $e');
    }
  }

  // Chat Management
  Future<void> addChatMessage(Map<String, dynamic> messageData) async {
    try {
      _initializeServices();
      if (chatCollection != null) {
        await chatCollection!.add(messageData);
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to add chat message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages() async {
    try {
      _initializeServices();
      if (chatCollection != null) {
        final snapshot = await chatCollection!.get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  // Equipment Management
  Future<void> addEquipment(Map<String, dynamic> equipmentData) async {
    try {
      _initializeServices();
      if (equipmentCollection != null) {
        await equipmentCollection!.add(equipmentData);
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to add equipment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEquipment() async {
    try {
      _initializeServices();
      if (equipmentCollection != null) {
        final snapshot = await equipmentCollection!.get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get equipment: $e');
    }
  }

  // Notification Management
  Future<void> addNotification(Map<String, dynamic> notificationData) async {
    try {
      _initializeServices();
      if (notificationCollection != null) {
        await notificationCollection!.add(notificationData);
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      _initializeServices();
      if (notificationCollection != null) {
        final snapshot = await notificationCollection!.get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Daily Updates Management
  Future<void> addDailyUpdate(Map<String, dynamic> updateData) async {
    try {
      _initializeServices();
      if (dailyUpdatesCollection != null) {
        await dailyUpdatesCollection!.add(updateData);
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to add daily update: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyUpdates() async {
    try {
      _initializeServices();
      if (dailyUpdatesCollection != null) {
        final snapshot = await dailyUpdatesCollection!.get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      throw Exception('Failed to get daily updates: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserCrops() async {
    try {
      _initializeServices();
      if (cropsCollection != null && currentUserId != null) {
        final snapshot = await cropsCollection!
            .where('userId', isEqualTo: currentUserId)
            .get();
        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        // Return empty list if Firebase is not available
        debugPrint('Firestore not initialized or user not authenticated, returning empty list');
        return [];
      }
    } catch (e) {
      debugPrint('Failed to get user crops: $e');
      // Return empty list on error
      return [];
    }
  }

  // Update document in any collection
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _initializeServices();
      if (_firestore != null) {
        await _firestore!.collection(collection).doc(documentId).update(data);
        debugPrint('Document updated successfully in collection: $collection');
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      debugPrint('Failed to update document: $e');
      throw Exception('Failed to update document: $e');
    }
  }

  // Set document in any collection (create or update)
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _initializeServices();
      if (_firestore != null) {
        await _firestore!.collection(collection).doc(documentId).set(data);
        debugPrint('Document set successfully in collection: $collection');
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      debugPrint('Failed to set document: $e');
      throw Exception('Failed to set document: $e');
    }
  }

  // Get document from any collection
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      _initializeServices();
      if (_firestore != null) {
        final doc = await _firestore!.collection(collection).doc(documentId).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
        return null;
      } else {
        throw Exception('Firestore not initialized');
      }
    } catch (e) {
      debugPrint('Failed to get document: $e');
      throw Exception('Failed to get document: $e');
    }
  }
}
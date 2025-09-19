import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_update_model.dart';
import 'package:flutter/foundation.dart';

class DailyUpdateService {
  static final DailyUpdateService _instance = DailyUpdateService._internal();
  factory DailyUpdateService() => _instance;
  DailyUpdateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  CollectionReference get dailyUpdatesCollection => _firestore.collection('daily_updates');
  CollectionReference get userPreferencesCollection => _firestore.collection('user_preferences');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new daily update
  Future<String> createDailyUpdate(DailyUpdateModel update) async {
    try {
      final docRef = await dailyUpdatesCollection.add({
        ...update.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      });
      
      debugPrint('Daily update created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating daily update: $e');
      throw Exception('Failed to create daily update: $e');
    }
  }

  // Get all daily updates for the current user
  Future<List<DailyUpdateModel>> getDailyUpdates({
    String? category,
    String? priority,
    bool? isRead,
    int? limit,
  }) async {
    try {
      Query query = dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true);

      // Apply filters - only apply one filter at a time to avoid composite index issues
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      } else if (priority != null && priority != 'All') {
        query = query.where('priority', isEqualTo: priority);
      } else if (isRead != null) {
        query = query.where('isRead', isEqualTo: isRead);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      List<DailyUpdateModel> updates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyUpdateModel.fromMap(data, doc.id);
      }).toList();

      // Apply additional filters in memory if needed
      if (category != null && category != 'All' && priority != null && priority != 'All') {
        updates = updates.where((update) => update.priority.toLowerCase() == priority.toLowerCase()).toList();
      } else if (category != null && category != 'All' && isRead != null) {
        updates = updates.where((update) => update.isRead == isRead).toList();
      } else if (priority != null && priority != 'All' && isRead != null) {
        updates = updates.where((update) => update.isRead == isRead).toList();
      }

      return updates;
    } catch (e) {
      debugPrint('Error getting daily updates: $e');
      throw Exception('Failed to get daily updates: $e');
    }
  }

  // Get daily update by ID
  Future<DailyUpdateModel?> getDailyUpdateById(String updateId) async {
    try {
      final doc = await dailyUpdatesCollection.doc(updateId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyUpdateModel.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting daily update by ID: $e');
      throw Exception('Failed to get daily update: $e');
    }
  }

  // Update daily update
  Future<void> updateDailyUpdate(String updateId, Map<String, dynamic> updateData) async {
    try {
      await dailyUpdatesCollection.doc(updateId).update({
        ...updateData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Daily update updated: $updateId');
    } catch (e) {
      debugPrint('Error updating daily update: $e');
      throw Exception('Failed to update daily update: $e');
    }
  }

  // Mark update as read/unread
  Future<void> markAsRead(String updateId, bool isRead) async {
    try {
      await dailyUpdatesCollection.doc(updateId).update({
        'isRead': isRead,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Daily update marked as ${isRead ? 'read' : 'unread'}: $updateId');
    } catch (e) {
      debugPrint('Error marking daily update as read: $e');
      throw Exception('Failed to mark daily update as read: $e');
    }
  }

  // Mark all updates as read
  Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Filter unread updates in memory
      final unreadDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isRead'] == false;
      }).toList();

      for (var doc in unreadDocs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('All daily updates marked as read');
    } catch (e) {
      debugPrint('Error marking all daily updates as read: $e');
      throw Exception('Failed to mark all daily updates as read: $e');
    }
  }

  // Delete daily update
  Future<void> deleteDailyUpdate(String updateId) async {
    try {
      await dailyUpdatesCollection.doc(updateId).delete();
      debugPrint('Daily update deleted: $updateId');
    } catch (e) {
      debugPrint('Error deleting daily update: $e');
      throw Exception('Failed to delete daily update: $e');
    }
  }

  // Delete all daily updates
  Future<void> deleteAllDailyUpdates() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('All daily updates deleted');
    } catch (e) {
      debugPrint('Error deleting all daily updates: $e');
      throw Exception('Failed to delete all daily updates: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .get();
      
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isRead'] == false;
      }).length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  // Get updates by category
  Future<List<DailyUpdateModel>> getUpdatesByCategory(String category) async {
    try {
      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyUpdateModel.fromMap(data, doc.id);
      }).where((update) => update.category.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      debugPrint('Error getting updates by category: $e');
      throw Exception('Failed to get updates by category: $e');
    }
  }

  // Get updates by priority
  Future<List<DailyUpdateModel>> getUpdatesByPriority(String priority) async {
    try {
      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyUpdateModel.fromMap(data, doc.id);
      }).where((update) => update.priority.toLowerCase() == priority.toLowerCase()).toList();
    } catch (e) {
      debugPrint('Error getting updates by priority: $e');
      throw Exception('Failed to get updates by priority: $e');
    }
  }

  // Search updates
  Future<List<DailyUpdateModel>> searchUpdates(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation - for production, consider using Algolia or similar
      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyUpdateModel.fromMap(data, doc.id);
      }).where((update) {
        return update.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
               update.description.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('Error searching updates: $e');
      throw Exception('Failed to search updates: $e');
    }
  }

  // Get today's updates
  Future<List<DailyUpdateModel>> getTodayUpdates() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyUpdateModel.fromMap(data, doc.id);
      }).where((update) {
        if (update.createdAt == null) return false;
        return update.createdAt!.isAfter(startOfDay) && update.createdAt!.isBefore(endOfDay);
      }).toList();
    } catch (e) {
      debugPrint('Error getting today\'s updates: $e');
      throw Exception('Failed to get today\'s updates: $e');
    }
  }

  // Get updates summary
  Future<Map<String, dynamic>> getUpdatesSummary() async {
    try {
      final allUpdates = await getDailyUpdates();
      final unreadCount = await getUnreadCount();
      final todayUpdates = await getTodayUpdates();

      // Count by category
      final categoryCount = <String, int>{};
      final priorityCount = <String, int>{};

      for (var update in allUpdates) {
        categoryCount[update.category] = (categoryCount[update.category] ?? 0) + 1;
        priorityCount[update.priority] = (priorityCount[update.priority] ?? 0) + 1;
      }

      return {
        'totalUpdates': allUpdates.length,
        'unreadCount': unreadCount,
        'todayUpdates': todayUpdates.length,
        'categoryCount': categoryCount,
        'priorityCount': priorityCount,
      };
    } catch (e) {
      debugPrint('Error getting updates summary: $e');
      throw Exception('Failed to get updates summary: $e');
    }
  }

  // Set user preferences for daily updates
  Future<void> setUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await userPreferencesCollection.doc(currentUserId).set({
        ...preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User preferences updated');
    } catch (e) {
      debugPrint('Error setting user preferences: $e');
      throw Exception('Failed to set user preferences: $e');
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final doc = await userPreferencesCollection.doc(currentUserId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return {};
    }
  }

  // Stream for real-time updates
  Stream<List<DailyUpdateModel>> streamDailyUpdates({
    String? category,
    String? priority,
    bool? isRead,
  }) {
    try {
      Query query = dailyUpdatesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true);

      // Apply only one filter to avoid composite index issues
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      } else if (priority != null && priority != 'All') {
        query = query.where('priority', isEqualTo: priority);
      } else if (isRead != null) {
        query = query.where('isRead', isEqualTo: isRead);
      }

      return query.snapshots().map((snapshot) {
        List<DailyUpdateModel> updates = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DailyUpdateModel.fromMap(data, doc.id);
        }).toList();

        // Apply additional filters in memory if needed
        if (category != null && category != 'All' && priority != null && priority != 'All') {
          updates = updates.where((update) => update.priority.toLowerCase() == priority.toLowerCase()).toList();
        } else if (category != null && category != 'All' && isRead != null) {
          updates = updates.where((update) => update.isRead == isRead).toList();
        } else if (priority != null && priority != 'All' && isRead != null) {
          updates = updates.where((update) => update.isRead == isRead).toList();
        }

        return updates;
      });
    } catch (e) {
      debugPrint('Error streaming daily updates: $e');
      return Stream.value([]);
    }
  }
}

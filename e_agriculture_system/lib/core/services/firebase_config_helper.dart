import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfigHelper {
  static bool _isInitialized = false;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  /// Initialize Firebase if not already initialized
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      
      // Simplified initialization without complex settings
      _isInitialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    return _auth?.currentUser != null;
  }

  /// Get current user ID
  static String? get currentUserId {
    return _auth?.currentUser?.uid;
  }

  /// Get current user
  static User? get currentUser {
    return _auth?.currentUser;
  }

  /// Sign out current user
  static Future<void> signOut() async {
    await _auth?.signOut();
  }

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges {
    return _auth?.authStateChanges() ?? Stream.value(null);
  }

  /// Stream of user changes
  static Stream<User?> get userChanges {
    return _auth?.userChanges() ?? Stream.value(null);
  }

  /// Ensure user is authenticated
  static void ensureAuthenticated() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated. Please sign in first.');
    }
  }

  /// Get user document reference
  static DocumentReference<Map<String, dynamic>> getUserDoc(String userId) {
    return firestore.collection('users').doc(userId);
  }

  /// Get crops collection reference
  static CollectionReference<Map<String, dynamic>> getCropsCollection() {
    return firestore.collection('crops');
  }

  /// Get equipment collection reference
  static CollectionReference<Map<String, dynamic>> getEquipmentCollection() {
    return firestore.collection('equipment');
  }

  /// Get harvests collection reference
  static CollectionReference<Map<String, dynamic>> getHarvestsCollection() {
    return firestore.collection('harvests');
  }

  /// Get financial records collection reference
  static CollectionReference<Map<String, dynamic>> getFinancialRecordsCollection() {
    return firestore.collection('financial_records');
  }

  /// Get products collection reference
  static CollectionReference<Map<String, dynamic>> getProductsCollection() {
    return firestore.collection('products');
  }

  /// Get orders collection reference
  static CollectionReference<Map<String, dynamic>> getOrdersCollection() {
    return firestore.collection('orders');
  }

  /// Get market prices collection reference
  static CollectionReference<Map<String, dynamic>> getMarketPricesCollection() {
    return firestore.collection('market_prices');
  }

  /// Get weather data collection reference
  static CollectionReference<Map<String, dynamic>> getWeatherDataCollection() {
    return firestore.collection('weather_data');
  }

  /// Create a batch for multiple operations
  static WriteBatch createBatch() {
    return firestore.batch();
  }

  /// Run a transaction
  static Future<T> runTransaction<T>(Future<T> Function(Transaction) updateFunction) {
    return firestore.runTransaction(updateFunction);
  }

  /// Get server timestamp
  static FieldValue get serverTimestamp {
    return FieldValue.serverTimestamp();
  }

  /// Get delete field value
  static FieldValue get deleteField {
    return FieldValue.delete();
  }

  /// Get increment field value
  static FieldValue increment(int amount) {
    return FieldValue.increment(amount);
  }

  /// Get array union field value
  static FieldValue arrayUnion(List<dynamic> elements) {
    return FieldValue.arrayUnion(elements);
  }

  /// Get array remove field value
  static FieldValue arrayRemove(List<dynamic> elements) {
    return FieldValue.arrayRemove(elements);
  }
}

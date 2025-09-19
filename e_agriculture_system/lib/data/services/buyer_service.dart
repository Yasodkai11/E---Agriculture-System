import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/buyer_model.dart';

class BuyerService {
  static final BuyerService _instance = BuyerService._internal();
  factory BuyerService() => _instance;
  BuyerService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _buyersCollection => _firestore.collection('buyers');

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<BuyerModel> createBuyer({
    required String uid,
    required String fullName,
    required String email,
    required String phoneNumber,
    String? businessName,
    String? businessType,
    String? location,
  }) async {
    try {
      final buyerModel = BuyerModel(
        id: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userType: 'buyer',
        location: location,
        businessName: businessName,
        businessType: businessType,
        preferences: {},
        isVerified: false,
        isPhoneVerified: false,
      );

      await _buyersCollection.doc(uid).set(buyerModel.toMap());
      return buyerModel;
    } catch (e) {
      throw Exception('Failed to create buyer: $e');
    }
  }

  Future<BuyerModel?> getCurrentBuyerData() async {
    if (currentUserId == null) return null;
    try {
      final doc = await _buyersCollection.doc(currentUserId!).get();
      if (doc.exists && doc.data() != null) {
        return BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get buyer: $e');
    }
  }

  Future<BuyerModel> updateBuyerProfile({
    required String buyerId,
    String? fullName,
    String? phoneNumber,
    String? location,
    String? businessName,
    String? businessType,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (location != null) updateData['location'] = location;
      if (businessName != null) updateData['businessName'] = businessName;
      if (businessType != null) updateData['businessType'] = businessType;
      if (preferences != null) updateData['preferences'] = preferences;

      await _buyersCollection.doc(buyerId).update(updateData);
      
      final doc = await _buyersCollection.doc(buyerId).get();
      return BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update buyer: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}

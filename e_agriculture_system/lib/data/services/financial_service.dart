import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/financial_record_model.dart';
import 'unified_image_storage_service.dart';

class FinancialService {
  static final FinancialService _instance = FinancialService._internal();
  factory FinancialService() => _instance;
  FinancialService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UnifiedImageStorageService _storage = UnifiedImageStorageService();

  // Collection references
  CollectionReference get _financialCollection => _firestore.collection('financial_records');

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // ========== FINANCIAL RECORD CRUD OPERATIONS ==========

  /// Create a new financial record
  Future<String> createFinancialRecord({
    required String title,
    required String description,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    List<File>? images,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload images if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _storage.uploadImages(images, 'financial');
      }

      // Create financial record document
      final recordDoc = _financialCollection.doc();
      final record = FinancialRecordModel(
        id: recordDoc.id,
        userId: currentUserId!,
        title: title,
        description: description,
        amount: amount,
        type: type,
        category: category,
        date: date,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        notes: notes,
        imageUrls: imageUrls,
        additionalData: additionalData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await recordDoc.set(record.toMap());
      return recordDoc.id;
    } catch (e) {
      throw Exception('Failed to create financial record: $e');
    }
  }

  /// Get all financial records for current user
  Future<List<FinancialRecordModel>> getAllFinancialRecords({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _financialCollection.where('userId', isEqualTo: currentUserId);
      
      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final querySnapshot = await query.orderBy('date', descending: true).get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FinancialRecordModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get financial records: $e');
    }
  }

  /// Get financial record by ID
  Future<FinancialRecordModel?> getFinancialRecordById(String recordId) async {
    try {
      final doc = await _financialCollection.doc(recordId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FinancialRecordModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get financial record: $e');
    }
  }

  /// Update financial record
  Future<void> updateFinancialRecord({
    required String recordId,
    String? title,
    String? description,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    List<File>? newImages,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get existing record
      final existingRecord = await getFinancialRecordById(recordId);
      if (existingRecord == null) {
        throw Exception('Financial record not found');
      }

      // Upload new images if provided
      List<String> imageUrls = List.from(existingRecord.imageUrls);
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          final imageUrl = await _uploadFinancialImage(currentUserId!, newImages[i], i);
          imageUrls.add(imageUrl);
        }
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (amount != null) updateData['amount'] = amount;
      if (type != null) updateData['type'] = type;
      if (category != null) updateData['category'] = category;
      if (date != null) updateData['date'] = date.toIso8601String();
      if (paymentMethod != null) updateData['paymentMethod'] = paymentMethod;
      if (referenceNumber != null) updateData['referenceNumber'] = referenceNumber;
      if (notes != null) updateData['notes'] = notes;
      if (imageUrls.isNotEmpty) updateData['imageUrls'] = imageUrls;
      if (additionalData != null) updateData['additionalData'] = additionalData;

      await _financialCollection.doc(recordId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update financial record: $e');
    }
  }

  /// Delete financial record
  Future<void> deleteFinancialRecord(String recordId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get record to delete images
      final record = await getFinancialRecordById(recordId);
      if (record != null) {
        // Delete images from storage
        for (String imageUrl in record.imageUrls) {
          try {
            await _storage.deleteImage(imageUrl);
          } catch (e) {
            debugPrint('Failed to delete image: $e');
          }
        }
      }

      await _financialCollection.doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete financial record: $e');
    }
  }

  /// Get financial records by type
  Future<List<FinancialRecordModel>> getFinancialRecordsByType(String type) async {
    try {
      return await getAllFinancialRecords(type: type);
    } catch (e) {
      throw Exception('Failed to get financial records by type: $e');
    }
  }

  /// Get financial records by category
  Future<List<FinancialRecordModel>> getFinancialRecordsByCategory(String category) async {
    try {
      return await getAllFinancialRecords(category: category);
    } catch (e) {
      throw Exception('Failed to get financial records by category: $e');
    }
  }

  /// Get financial records by date range
  Future<List<FinancialRecordModel>> getFinancialRecordsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await getAllFinancialRecords(startDate: startDate, endDate: endDate);
    } catch (e) {
      throw Exception('Failed to get financial records by date range: $e');
    }
  }

  /// Search financial records
  Future<List<FinancialRecordModel>> searchFinancialRecords(String query) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final allRecords = await getAllFinancialRecords();
      return allRecords.where((record) {
        return record.title.toLowerCase().contains(query.toLowerCase()) ||
               record.description.toLowerCase().contains(query.toLowerCase()) ||
               (record.notes?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (record.referenceNumber?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search financial records: $e');
    }
  }

  /// Get financial statistics
  Future<Map<String, dynamic>> getFinancialStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await getAllFinancialRecords(startDate: startDate, endDate: endDate);
      
      final totalRecords = records.length;
      final totalIncome = records
          .where((r) => r.type == 'income')
          .fold(0.0, (sum, record) => sum + record.amount);
      final totalExpenses = records
          .where((r) => r.type == 'expense')
          .fold(0.0, (sum, record) => sum + record.amount);
      final totalInvestments = records
          .where((r) => r.type == 'investment')
          .fold(0.0, (sum, record) => sum + record.amount);
      final netProfit = totalIncome - totalExpenses;

      // Group by type
      final typeStats = <String, double>{};
      for (var record in records) {
        typeStats[record.type] = (typeStats[record.type] ?? 0.0) + record.amount;
      }

      // Group by category
      final categoryStats = <String, double>{};
      for (var record in records) {
        categoryStats[record.category] = (categoryStats[record.category] ?? 0.0) + record.amount;
      }

      // Monthly breakdown
      final monthlyStats = <String, Map<String, double>>{};
      for (var record in records) {
        final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
        if (!monthlyStats.containsKey(monthKey)) {
          monthlyStats[monthKey] = {'income': 0.0, 'expense': 0.0, 'investment': 0.0};
        }
        monthlyStats[monthKey]![record.type] = (monthlyStats[monthKey]![record.type] ?? 0.0) + record.amount;
      }

      return {
        'totalRecords': totalRecords,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'totalInvestments': totalInvestments,
        'netProfit': netProfit,
        'typeStats': typeStats,
        'categoryStats': categoryStats,
        'monthlyStats': monthlyStats,
      };
    } catch (e) {
      throw Exception('Failed to get financial statistics: $e');
    }
  }

  /// Get monthly financial summary
  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      
      final records = await getFinancialRecordsByDateRange(startDate, endDate);
      
      final totalIncome = records
          .where((r) => r.type == 'income')
          .fold(0.0, (sum, record) => sum + record.amount);
      final totalExpenses = records
          .where((r) => r.type == 'expense')
          .fold(0.0, (sum, record) => sum + record.amount);
      final totalInvestments = records
          .where((r) => r.type == 'investment')
          .fold(0.0, (sum, record) => sum + record.amount);
      final netProfit = totalIncome - totalExpenses;

      // Top expense categories
      final expenseCategories = <String, double>{};
      for (var record in records.where((r) => r.type == 'expense')) {
        expenseCategories[record.category] = (expenseCategories[record.category] ?? 0.0) + record.amount;
      }

      // Top income categories
      final incomeCategories = <String, double>{};
      for (var record in records.where((r) => r.type == 'income')) {
        incomeCategories[record.category] = (incomeCategories[record.category] ?? 0.0) + record.amount;
      }

      return {
        'year': year,
        'month': month,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'totalInvestments': totalInvestments,
        'netProfit': netProfit,
        'expenseCategories': expenseCategories,
        'incomeCategories': incomeCategories,
        'totalRecords': records.length,
      };
    } catch (e) {
      throw Exception('Failed to get monthly summary: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Upload financial record image using unified storage
  Future<String> _uploadFinancialImage(String userId, File image, int index) async {
    try {
      return await _storage.uploadImage(image, 'financial', index: index);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Get available financial record types
  List<String> getFinancialTypes() {
    return ['income', 'expense', 'investment'];
  }

  /// Get available financial record categories
  List<String> getFinancialCategories() {
    return [
      'crop_sales',
      'equipment',
      'labor',
      'fertilizer',
      'pesticides',
      'seeds',
      'irrigation',
      'fuel',
      'maintenance',
      'transportation',
      'insurance',
      'taxes',
      'loans',
      'other',
    ];
  }

  /// Get available payment methods
  List<String> getPaymentMethods() {
    return ['cash', 'bank_transfer', 'check', 'credit_card', 'mobile_payment', 'other'];
  }

  /// Get financial type color
  static String getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return '#4CAF50'; // Green
      case 'expense':
        return '#F44336'; // Red
      case 'investment':
        return '#2196F3'; // Blue
      default:
        return '#757575'; // Grey
    }
  }

  /// Get financial type icon
  static String getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return '💰';
      case 'expense':
        return '💸';
      case 'investment':
        return '📈';
      default:
        return '💳';
    }
  }
}

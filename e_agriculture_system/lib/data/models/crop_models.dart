import 'package:cloud_firestore/cloud_firestore.dart';

class CropModel {
  final String id;
  final String userId;
  final String name;
  final String variety;
  final DateTime plantedDate;
  final DateTime? expectedHarvestDate;
  final String status; // planted, growing, ready, harvested
  final double area; // in acres/hectares
  final String? notes;
  final List<String> imageUrls;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  CropModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.variety,
    required this.plantedDate,
    this.expectedHarvestDate,
    this.status = 'planted',
    required this.area,
    this.notes,
    this.imageUrls = const [],
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'variety': variety,
      'plantedDate': plantedDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate?.toIso8601String(),
      'status': status,
      'area': area,
      'notes': notes,
      'imageUrls': imageUrls,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CropModel.fromMap(Map<String, dynamic> map) {
    return CropModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      variety: map['variety'] ?? '',
      plantedDate: _parseDateTimeRequired(map['plantedDate']),
      expectedHarvestDate: _parseDateTime(map['expectedHarvestDate']),
      status: map['status'] ?? 'planted',
      area: map['area']?.toDouble() ?? 0.0,
      notes: map['notes'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      additionalData: map['additionalData'],
      createdAt: _parseDateTimeRequired(map['createdAt']),
      updatedAt: _parseDateTimeRequired(map['updatedAt']),
    );
  }

  String? get cropName => null;

  get plantingDate => null;

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
}

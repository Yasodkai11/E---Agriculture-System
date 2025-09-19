import 'package:cloud_firestore/cloud_firestore.dart';

class HarvestModel {
  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final DateTime harvestDate;
  final double quantity;
  final String unit; // kg, tons, bags, etc.
  final String quality; // excellent, good, fair, poor
  final double? pricePerUnit;
  final String? notes;
  final List<String> imageUrls;
  final String status; // planned, in-progress, completed, sold
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  HarvestModel({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    this.quality = 'good',
    this.pricePerUnit,
    this.notes,
    this.imageUrls = const [],
    this.status = 'planned',
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'harvestDate': harvestDate.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'quality': quality,
      'pricePerUnit': pricePerUnit,
      'notes': notes,
      'imageUrls': imageUrls,
      'status': status,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HarvestModel.fromMap(Map<String, dynamic> map) {
    return HarvestModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cropId: map['cropId'] ?? '',
      cropName: map['cropName'] ?? '',
      harvestDate: _parseDateTimeRequired(map['harvestDate']),
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'kg',
      quality: map['quality'] ?? 'good',
      pricePerUnit: map['pricePerUnit']?.toDouble(),
      notes: map['notes'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: map['status'] ?? 'planned',
      additionalData: map['additionalData'],
      createdAt: _parseDateTimeRequired(map['createdAt']),
      updatedAt: _parseDateTimeRequired(map['updatedAt']),
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

  HarvestModel copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? cropName,
    DateTime? harvestDate,
    double? quantity,
    String? unit,
    String? quality,
    double? pricePerUnit,
    String? notes,
    List<String>? imageUrls,
    String? status,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HarvestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      harvestDate: harvestDate ?? this.harvestDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      quality: quality ?? this.quality,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

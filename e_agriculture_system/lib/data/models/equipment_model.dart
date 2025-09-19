import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String userId;
  final String name;
  final String category; // machinery, implements, irrigation, tools, vehicles
  final String description;
  final String status; // operational, maintenance, repair, retired
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? manufacturer;
  final String? model;
  final String? serialNumber;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final double? maintenanceCost;
  final String? maintenanceNotes;
  final List<String> imageUrls;
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  EquipmentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.description,
    this.status = 'operational',
    this.purchaseDate,
    this.purchasePrice,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.lastMaintenance,
    this.nextMaintenance,
    this.maintenanceCost,
    this.maintenanceNotes,
    this.imageUrls = const [],
    this.specifications,
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'description': description,
      'status': status,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'manufacturer': manufacturer,
      'model': model,
      'serialNumber': serialNumber,
      'lastMaintenance': lastMaintenance?.toIso8601String(),
      'nextMaintenance': nextMaintenance?.toIso8601String(),
      'maintenanceCost': maintenanceCost,
      'maintenanceNotes': maintenanceNotes,
      'imageUrls': imageUrls,
      'specifications': specifications,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    return EquipmentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'operational',
      purchaseDate: _parseDateTime(map['purchaseDate']),
      purchasePrice: map['purchasePrice']?.toDouble(),
      manufacturer: map['manufacturer'],
      model: map['model'],
      serialNumber: map['serialNumber'],
      lastMaintenance: _parseDateTime(map['lastMaintenance']),
      nextMaintenance: _parseDateTime(map['nextMaintenance']),
      maintenanceCost: map['maintenanceCost']?.toDouble(),
      maintenanceNotes: map['maintenanceNotes'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      specifications: map['specifications'],
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

  EquipmentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? description,
    String? status,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    double? maintenanceCost,
    String? maintenanceNotes,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      maintenanceNotes: maintenanceNotes ?? this.maintenanceNotes,
      imageUrls: imageUrls ?? this.imageUrls,
      specifications: specifications ?? this.specifications,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

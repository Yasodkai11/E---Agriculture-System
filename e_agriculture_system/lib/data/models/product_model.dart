import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit; // kg, pieces, bags, etc.
  final int quantity;
  final String category; // grains, vegetables, fruits, etc.
  final String? imageUrl;
  final List<String>? imageUrls;
  final String sellerId;
  final String sellerName;
  final String sellerLocation;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? specifications;
  final double? rating;
  final int? reviewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.category,
    this.imageUrl,
    this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.sellerLocation,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.specifications,
    this.rating,
    this.reviewCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerLocation': sellerLocation,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      quantity: map['quantity'] ?? 0,
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerLocation: map['sellerLocation'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: _parseDateTimeRequired(map['createdAt']),
      updatedAt: _parseDateTimeRequired(map['updatedAt']),
      specifications: map['specifications'],
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'],
    );
  }

  get location => null;

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

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    String? unit,
    int? quantity,
    String? category,
    String? imageUrl,
    String? sellerName,
    String? sellerLocation,
    bool? isAvailable,
    Map<String, dynamic>? specifications,
    double? rating,
    int? reviewCount,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

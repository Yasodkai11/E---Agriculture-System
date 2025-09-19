import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ProductCategory {
  grains,
  vegetables,
  fruits,
  spices,
  beverages,
  industrial,
  dairy,
  meat,
  fish,
  other
}

enum PriceTrend {
  up,
  down,
  stable
}

class SriLankaMarketPriceModel {
  final String id;
  final String productName;
  final String productCode;
  final ProductCategory category;
  final String unit; // kg, piece, dozen, etc.
  final double currentPrice;
  final double previousPrice;
  final double changeAmount;
  final double changePercentage;
  final PriceTrend trend;
  final String marketLocation;
  final String district;
  final String quality; // Grade A, B, C, etc.
  final String source; // Wholesale, Retail, etc.
  final DateTime lastUpdated;
  final DateTime priceDate;
  final String supplier;
  final String description;
  final String imageUrl;
  final bool isAvailable;
  final Map<String, dynamic> additionalInfo;

  SriLankaMarketPriceModel({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.category,
    required this.unit,
    required this.currentPrice,
    required this.previousPrice,
    required this.changeAmount,
    required this.changePercentage,
    required this.trend,
    required this.marketLocation,
    required this.district,
    required this.quality,
    required this.source,
    required this.lastUpdated,
    required this.priceDate,
    required this.supplier,
    required this.description,
    required this.imageUrl,
    required this.isAvailable,
    required this.additionalInfo,
  });

  factory SriLankaMarketPriceModel.fromMap(Map<String, dynamic> map) {
    return SriLankaMarketPriceModel(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      productCode: map['productCode'] ?? '',
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${map['category']}',
        orElse: () => ProductCategory.other,
      ),
      unit: map['unit'] ?? 'kg',
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      previousPrice: (map['previousPrice'] ?? 0.0).toDouble(),
      changeAmount: (map['changeAmount'] ?? 0.0).toDouble(),
      changePercentage: (map['changePercentage'] ?? 0.0).toDouble(),
      trend: PriceTrend.values.firstWhere(
        (e) => e.toString() == 'PriceTrend.${map['trend']}',
        orElse: () => PriceTrend.stable,
      ),
      marketLocation: map['marketLocation'] ?? '',
      district: map['district'] ?? '',
      quality: map['quality'] ?? 'Standard',
      source: map['source'] ?? 'Wholesale',
      lastUpdated: _parseDateTimeRequired(map['lastUpdated']),
      priceDate: _parseDateTimeRequired(map['priceDate']),
      supplier: map['supplier'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
    );
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'productCode': productCode,
      'category': category.name,
      'unit': unit,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'changeAmount': changeAmount,
      'changePercentage': changePercentage,
      'trend': trend.name,
      'marketLocation': marketLocation,
      'district': district,
      'quality': quality,
      'source': source,
      'lastUpdated': lastUpdated,
      'priceDate': priceDate,
      'supplier': supplier,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'additionalInfo': additionalInfo,
    };
  }

  // Helper getters
  String get displayPrice => 'Rs ${currentPrice.toStringAsFixed(2)}';
  String get displayChange => '${changeAmount >= 0 ? '+' : ''}${changeAmount.toStringAsFixed(2)}';
  String get displayPercentage => '${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%';
  String get displayUnit => '$unit';
  String get displayLocation => '$marketLocation, $district';
  String get displayQuality => quality;
  String get displaySource => source;
  String get displaySupplier => supplier;
  String get lastUpdatedText => _formatDate(lastUpdated);
  String get priceDateText => _formatDate(priceDate);
  String get categoryDisplayName => _getCategoryDisplayName(category);
  String get trendIcon => _getTrendIcon(trend);
  Color get trendColor => _getTrendColor(trend);
  bool get isPriceUp => trend == PriceTrend.up;
  bool get isPriceDown => trend == PriceTrend.down;
  bool get isPriceStable => trend == PriceTrend.stable;

  String _getCategoryDisplayName(ProductCategory category) {
    switch (category) {
      case ProductCategory.grains:
        return 'Grains';
      case ProductCategory.vegetables:
        return 'Vegetables';
      case ProductCategory.fruits:
        return 'Fruits';
      case ProductCategory.spices:
        return 'Spices';
      case ProductCategory.beverages:
        return 'Beverages';
      case ProductCategory.industrial:
        return 'Industrial';
      case ProductCategory.dairy:
        return 'Dairy';
      case ProductCategory.meat:
        return 'Meat';
      case ProductCategory.fish:
        return 'Fish';
      case ProductCategory.other:
        return 'Other';
    }
  }

  String _getTrendIcon(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return '📈';
      case PriceTrend.down:
        return '📉';
      case PriceTrend.stable:
        return '➡️';
    }
  }

  Color _getTrendColor(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return Colors.green;
      case PriceTrend.down:
        return Colors.red;
      case PriceTrend.stable:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  SriLankaMarketPriceModel copyWith({
    String? id,
    String? productName,
    String? productCode,
    ProductCategory? category,
    String? unit,
    double? currentPrice,
    double? previousPrice,
    double? changeAmount,
    double? changePercentage,
    PriceTrend? trend,
    String? marketLocation,
    String? district,
    String? quality,
    String? source,
    DateTime? lastUpdated,
    DateTime? priceDate,
    String? supplier,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    Map<String, dynamic>? additionalInfo,
  }) {
    return SriLankaMarketPriceModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      changeAmount: changeAmount ?? this.changeAmount,
      changePercentage: changePercentage ?? this.changePercentage,
      trend: trend ?? this.trend,
      marketLocation: marketLocation ?? this.marketLocation,
      district: district ?? this.district,
      quality: quality ?? this.quality,
      source: source ?? this.source,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      priceDate: priceDate ?? this.priceDate,
      supplier: supplier ?? this.supplier,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'SriLankaMarketPriceModel(id: $id, productName: $productName, currentPrice: $currentPrice, trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SriLankaMarketPriceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

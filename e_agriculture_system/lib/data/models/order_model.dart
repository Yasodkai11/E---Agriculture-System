import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_model.dart' show PaymentStatus;

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded
}

class OrderModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final String farmerName;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String shippingAddress;
  final String contactNumber;
  final String notes;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? trackingNumber;
  final Map<String, dynamic> paymentDetails;
  final bool isRated;
  final DateTime createdAt;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.contactNumber,
    required this.notes,
    required this.orderDate,
    this.deliveryDate,
    this.trackingNumber,
    required this.paymentDetails,
    required this.isRated,
    required this.createdAt,
    required this.deliveryAddress, required DateTime updatedAt, required String buyerName,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      buyerId: map['buyerId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] ?? []).map((item) => OrderItem.fromMap(item)),
      ),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      shipping: (map['shipping'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      shippingAddress: map['shippingAddress'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      notes: map['notes'] ?? '',
      orderDate: _parseDateTimeRequired(map['orderDate']),
      deliveryDate: _parseDateTime(map['deliveryDate']),
      trackingNumber: map['trackingNumber'],
      paymentDetails: Map<String, dynamic>.from(map['paymentDetails'] ?? {}),
      isRated: map['isRated'] ?? false,
      createdAt: _parseDateTimeRequired(map['createdAt']),
      deliveryAddress: map['deliveryAddress'] ?? '', updatedAt: DateTime.now(), buyerName: '',
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'shippingAddress': shippingAddress,
      'contactNumber': contactNumber,
      'notes': notes,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'trackingNumber': trackingNumber,
      'paymentDetails': paymentDetails,
      'isRated': isRated,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryAddress': deliveryAddress,
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get paymentStatusText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get orderDateText => _formatDate(orderDate);
  String get deliveryDateText => deliveryDate != null ? _formatDate(deliveryDate!) : 'Not delivered';
  String get orderNumber => 'ORD-${id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}';
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canTrack => status == OrderStatus.shipped || status == OrderStatus.delivered;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? farmerId,
    String? farmerName,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? total,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? shippingAddress,
    String? contactNumber,
    String? notes,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? trackingNumber,
    Map<String, dynamic>? paymentDetails,
    bool? isRated,
    DateTime? createdAt,
    String? deliveryAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      notes: notes ?? this.notes,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      isRated: isRated ?? this.isRated,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress, updatedAt: DateTime.now(), buyerName: '',
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, status: $status, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  get sellerId => null;
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.total, required double unitPrice, required double totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(), unitPrice: 0.0, totalPrice: 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    double? total,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total, unitPrice: 0.0, totalPrice: 0.0,
    );
  }

  @override
  String toString() {
    return 'OrderItem(productName: $productName, quantity: $quantity, total: $total)';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  creditCard,
  debitCard,
  mobilePayment,
  cashOnDelivery,
  digitalWallet,
  sriLankanBank, bankTransfer,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

class PaymentModel {
  final String id;
  final String orderId;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String productName;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? transactionId;
  final String? paymentGateway;
  final Map<String, dynamic>? paymentDetails;
  final String? failureReason;
  final String? notes;
  // Bank-specific fields
  final String? bankId;
  final String? bankName;
  final String? accountNumber;
  final String? branchCode;
  final String? referenceNumber;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.amount,
    this.currency = 'LKR',
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.transactionId,
    this.paymentGateway,
    this.paymentDetails,
    this.failureReason,
    this.notes,
    this.bankId,
    this.bankName,
    this.accountNumber,
    this.branchCode,
    this.referenceNumber,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'LKR',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: _parseDateTimeRequired(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      transactionId: map['transactionId'],
      paymentGateway: map['paymentGateway'],
      paymentDetails: map['paymentDetails'],
      failureReason: map['failureReason'],
      notes: map['notes'],
      bankId: map['bankId'],
      bankName: map['bankName'],
      accountNumber: map['accountNumber'],
      branchCode: map['branchCode'],
      referenceNumber: map['referenceNumber'],
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
      'orderId': orderId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'transactionId': transactionId,
      'paymentGateway': paymentGateway,
      'paymentDetails': paymentDetails,
      'failureReason': failureReason,
      'notes': notes,
      'bankId': bankId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'branchCode': branchCode,
      'referenceNumber': referenceNumber,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? buyerId,
    String? sellerId,
    String? productId,
    String? productName,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionId,
    String? paymentGateway,
    Map<String, dynamic>? paymentDetails,
    String? failureReason,
    String? notes,
    String? bankId,
    String? bankName,
    String? accountNumber,
    String? branchCode,
    String? referenceNumber,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionId: transactionId ?? this.transactionId,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      failureReason: failureReason ?? this.failureReason,
      notes: notes ?? this.notes,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      branchCode: branchCode ?? this.branchCode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }
}

class PaymentMethodInfo {
  final PaymentMethod method;
  final String name;
  final String description;
  final String icon;
  final bool isAvailable;
  final double? fee;
  final String? feeDescription;

  PaymentMethodInfo({
    required this.method,
    required this.name,
    required this.description,
    required this.icon,
    this.isAvailable = true,
    this.fee,
    this.feeDescription,
  });
}

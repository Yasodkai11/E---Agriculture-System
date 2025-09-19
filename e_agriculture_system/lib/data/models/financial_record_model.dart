class FinancialRecordModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String type; // income, expense, investment
  final String category; // crop_sales, equipment, labor, fertilizer, etc.
  final DateTime date;
  final String? paymentMethod; // cash, bank_transfer, check, etc.
  final String? referenceNumber;
  final String? notes;
  final List<String> imageUrls; // receipts, invoices, etc.
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialRecordModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.referenceNumber,
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
      'title': title,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'imageUrls': imageUrls,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinancialRecordModel.fromMap(Map<String, dynamic> map) {
    return FinancialRecordModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      type: map['type'] ?? 'expense',
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      paymentMethod: map['paymentMethod'],
      referenceNumber: map['referenceNumber'],
      notes: map['notes'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      additionalData: map['additionalData'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  FinancialRecordModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    List<String>? imageUrls,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

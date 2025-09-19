class SavedCard {
  final String id;
  final String name;
  final String cardNumber;
  final String expiryDate;
  final String type;
  final String? cvc;

  SavedCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    required this.expiryDate,
    required this.type,
    this.cvc,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'type': type,
      'cvc': cvc,
    };
  }

  factory SavedCard.fromMap(Map<String, dynamic> map) {
    return SavedCard(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      type: map['type'] ?? '',
      cvc: map['cvc'],
    );
  }

  @override
  String toString() {
    return 'SavedCard(id: $id, name: $name, cardNumber: $cardNumber, expiryDate: $expiryDate, type: $type, cvc: $cvc)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedCard &&
        other.id == id &&
        other.name == name &&
        other.cardNumber == cardNumber &&
        other.expiryDate == expiryDate &&
        other.type == type &&
        other.cvc == cvc;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        cardNumber.hashCode ^
        expiryDate.hashCode ^
        type.hashCode ^
        cvc.hashCode;
  }
}


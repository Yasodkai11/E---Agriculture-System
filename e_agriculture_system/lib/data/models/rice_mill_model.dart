
class RiceMillModel {
  final String id;
  final String name;
  final String location;
  final String district;
  final String province;
  final String? website;
  final String? phone;
  final String? email;
  final String? address;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? businessType;
  final String? capacity;
  final String? establishedYear;
  final String? description;
  final List<String> riceVarieties;
  final Map<String, dynamic> additionalInfo;
  final DateTime lastUpdated;
  final bool isActive;
  final double? latitude;
  final double? longitude;

  RiceMillModel({
    required this.id,
    required this.name,
    required this.location,
    required this.district,
    required this.province,
    this.website,
    this.phone,
    this.email,
    this.address,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.businessType,
    this.capacity,
    this.establishedYear,
    this.description,
    this.riceVarieties = const [],
    this.additionalInfo = const {},
    required this.lastUpdated,
    this.isActive = true,
    this.latitude,
    this.longitude,
  });

  factory RiceMillModel.fromMap(Map<String, dynamic> map) {
    return RiceMillModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
      website: map['website'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      ownerName: map['ownerName'],
      ownerPhone: map['ownerPhone'],
      ownerEmail: map['ownerEmail'],
      businessType: map['businessType'],
      capacity: map['capacity'],
      establishedYear: map['establishedYear'],
      description: map['description'],
      riceVarieties: List<String>.from(map['riceVarieties'] ?? []),
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'district': district,
      'province': province,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'businessType': businessType,
      'capacity': capacity,
      'establishedYear': establishedYear,
      'description': description,
      'riceVarieties': riceVarieties,
      'additionalInfo': additionalInfo,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper getters
  String get displayLocation => '$location, $district';
  String get fullLocation => '$location, $district, $province';
  String get contactInfo => phone ?? email ?? 'No contact info';
  String get ownerInfo => ownerName ?? 'Owner details not available';
  String get lastUpdatedText => _formatDate(lastUpdated);
  bool get hasContactInfo => phone != null || email != null;
  bool get hasOwnerInfo => ownerName != null || ownerPhone != null || ownerEmail != null;
  bool get hasLocation => latitude != null && longitude != null;

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

  RiceMillModel copyWith({
    String? id,
    String? name,
    String? location,
    String? district,
    String? province,
    String? website,
    String? phone,
    String? email,
    String? address,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? businessType,
    String? capacity,
    String? establishedYear,
    String? description,
    List<String>? riceVarieties,
    Map<String, dynamic>? additionalInfo,
    DateTime? lastUpdated,
    bool? isActive,
    double? latitude,
    double? longitude,
  }) {
    return RiceMillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      district: district ?? this.district,
      province: province ?? this.province,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      businessType: businessType ?? this.businessType,
      capacity: capacity ?? this.capacity,
      establishedYear: establishedYear ?? this.establishedYear,
      description: description ?? this.description,
      riceVarieties: riceVarieties ?? this.riceVarieties,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'RiceMillModel(id: $id, name: $name, location: $displayLocation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RiceMillModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

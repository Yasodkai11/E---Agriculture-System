import 'package:flutter/material.dart';

enum BankType {
  commercial,
  development,
  specialized,
  foreign,
  cooperative,
  savings,
}

enum PaymentNetwork {
  ceylonBank,
  visa,
  mastercard,
  americanExpress,
  unionPay,
  local,
}

class SriLankanBank {
  final String id;
  final String name;
  final String shortName;
  final String code; // SWIFT/BIC code
  final BankType type;
  final String logoUrl;
  final String website;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String district;
  final String province;
  final String postalCode;
  final List<PaymentNetwork> supportedNetworks;
  final List<String> supportedCurrencies;
  final bool isActive;
  final bool supportsOnlineBanking;
  final bool supportsMobileBanking;
  final bool supportsATM;
  final bool supportsBranchBanking;
  final Map<String, dynamic> fees;
  final Map<String, dynamic> limits;
  final String description;
  final DateTime establishedDate;
  final String licenseNumber;
  final String regulator; // CBSL, etc.

  SriLankanBank({
    required this.id,
    required this.name,
    required this.shortName,
    required this.code,
    required this.type,
    required this.logoUrl,
    required this.website,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.district,
    required this.province,
    required this.postalCode,
    required this.supportedNetworks,
    required this.supportedCurrencies,
    this.isActive = true,
    this.supportsOnlineBanking = true,
    this.supportsMobileBanking = true,
    this.supportsATM = true,
    this.supportsBranchBanking = true,
    required this.fees,
    required this.limits,
    required this.description,
    required this.establishedDate,
    required this.licenseNumber,
    required this.regulator,
  });

  // Get bank color based on type
  Color get bankColor {
    switch (type) {
      case BankType.commercial:
        return Colors.blue;
      case BankType.development:
        return Colors.green;
      case BankType.specialized:
        return Colors.orange;
      case BankType.foreign:
        return Colors.purple;
      case BankType.cooperative:
        return Colors.red;
      case BankType.savings:
        return Colors.teal;
    }
  }

  // Get bank icon
  IconData get bankIcon {
    switch (type) {
      case BankType.commercial:
        return Icons.account_balance;
      case BankType.development:
        return Icons.trending_up;
      case BankType.specialized:
        return Icons.business;
      case BankType.foreign:
        return Icons.public;
      case BankType.cooperative:
        return Icons.group;
      case BankType.savings:
        return Icons.savings;
    }
  }

  // Check if bank supports specific currency
  bool supportsCurrency(String currency) {
    return supportedCurrencies.contains(currency);
  }

  // Check if bank supports specific payment network
  bool supportsNetwork(PaymentNetwork network) {
    return supportedNetworks.contains(network);
  }

  // Get transfer fee for amount
  double getTransferFee(double amount) {
    if (fees.containsKey('transfer')) {
      final transferFees = fees['transfer'] as Map<String, dynamic>;
      if (transferFees.containsKey('percentage')) {
        return amount * (transferFees['percentage'] as double) / 100;
      } else if (transferFees.containsKey('fixed')) {
        return transferFees['fixed'] as double;
      }
    }
    return 0.0;
  }

  // Get daily transfer limit
  double getDailyLimit() {
    if (limits.containsKey('daily')) {
      return limits['daily'] as double;
    }
    return 1000000.0; // Default 1M LKR
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'code': code,
      'type': type.name,
      'logoUrl': logoUrl,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'district': district,
      'province': province,
      'postalCode': postalCode,
      'supportedNetworks': supportedNetworks.map((e) => e.name).toList(),
      'supportedCurrencies': supportedCurrencies,
      'isActive': isActive,
      'supportsOnlineBanking': supportsOnlineBanking,
      'supportsMobileBanking': supportsMobileBanking,
      'supportsATM': supportsATM,
      'supportsBranchBanking': supportsBranchBanking,
      'fees': fees,
      'limits': limits,
      'description': description,
      'establishedDate': establishedDate.toIso8601String(),
      'licenseNumber': licenseNumber,
      'regulator': regulator,
    };
  }

  factory SriLankanBank.fromMap(Map<String, dynamic> map) {
    return SriLankanBank(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
      code: map['code'] ?? '',
      type: BankType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BankType.commercial,
      ),
      logoUrl: map['logoUrl'] ?? '',
      website: map['website'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
      postalCode: map['postalCode'] ?? '',
      supportedNetworks: (map['supportedNetworks'] as List<dynamic>?)
          ?.map((e) => PaymentNetwork.values.firstWhere(
                (network) => network.name == e,
                orElse: () => PaymentNetwork.local,
              ))
          .toList() ?? [PaymentNetwork.local],
      supportedCurrencies: List<String>.from(map['supportedCurrencies'] ?? ['LKR']),
      isActive: map['isActive'] ?? true,
      supportsOnlineBanking: map['supportsOnlineBanking'] ?? true,
      supportsMobileBanking: map['supportsMobileBanking'] ?? true,
      supportsATM: map['supportsATM'] ?? true,
      supportsBranchBanking: map['supportsBranchBanking'] ?? true,
      fees: Map<String, dynamic>.from(map['fees'] ?? {}),
      limits: Map<String, dynamic>.from(map['limits'] ?? {}),
      description: map['description'] ?? '',
      establishedDate: DateTime.parse(map['establishedDate'] ?? DateTime.now().toIso8601String()),
      licenseNumber: map['licenseNumber'] ?? '',
      regulator: map['regulator'] ?? 'CBSL',
    );
  }

  SriLankanBank copyWith({
    String? id,
    String? name,
    String? shortName,
    String? code,
    BankType? type,
    String? logoUrl,
    String? website,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? district,
    String? province,
    String? postalCode,
    List<PaymentNetwork>? supportedNetworks,
    List<String>? supportedCurrencies,
    bool? isActive,
    bool? supportsOnlineBanking,
    bool? supportsMobileBanking,
    bool? supportsATM,
    bool? supportsBranchBanking,
    Map<String, dynamic>? fees,
    Map<String, dynamic>? limits,
    String? description,
    DateTime? establishedDate,
    String? licenseNumber,
    String? regulator,
  }) {
    return SriLankanBank(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      code: code ?? this.code,
      type: type ?? this.type,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      supportedNetworks: supportedNetworks ?? this.supportedNetworks,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      isActive: isActive ?? this.isActive,
      supportsOnlineBanking: supportsOnlineBanking ?? this.supportsOnlineBanking,
      supportsMobileBanking: supportsMobileBanking ?? this.supportsMobileBanking,
      supportsATM: supportsATM ?? this.supportsATM,
      supportsBranchBanking: supportsBranchBanking ?? this.supportsBranchBanking,
      fees: fees ?? this.fees,
      limits: limits ?? this.limits,
      description: description ?? this.description,
      establishedDate: establishedDate ?? this.establishedDate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      regulator: regulator ?? this.regulator,
    );
  }
}

class BankAccount {
  final String id;
  final String userId;
  final String bankId;
  final String accountNumber;
  final String accountHolderName;
  final String accountType; // savings, current, fixed, etc.
  final String branchCode;
  final String branchName;
  final String ifscCode;
  final bool isPrimary;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? metadata;

  BankAccount({
    required this.id,
    required this.userId,
    required this.bankId,
    required this.accountNumber,
    required this.accountHolderName,
    required this.accountType,
    required this.branchCode,
    required this.branchName,
    required this.ifscCode,
    this.isPrimary = false,
    this.isVerified = false,
    required this.createdAt,
    this.verifiedAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bankId': bankId,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'accountType': accountType,
      'branchCode': branchCode,
      'branchName': branchName,
      'ifscCode': ifscCode,
      'isPrimary': isPrimary,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bankId: map['bankId'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountHolderName: map['accountHolderName'] ?? '',
      accountType: map['accountType'] ?? 'savings',
      branchCode: map['branchCode'] ?? '',
      branchName: map['branchName'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      verifiedAt: map['verifiedAt'] != null 
          ? DateTime.parse(map['verifiedAt']) 
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }
}

// Static data for major Sri Lankan banks
class SriLankanBanksData {
  static List<SriLankanBank> get majorBanks => [
    // Commercial Banks
    SriLankanBank(
      id: 'commercial_001',
      name: 'Bank of Ceylon',
      shortName: 'BOC',
      code: 'BCEYLKLX',
      type: BankType.commercial,
      logoUrl: 'https://www.boc.lk/images/logo.png',
      website: 'https://www.boc.lk',
      phone: '+94 11 220 4444',
      email: 'info@boc.lk',
      address: 'No. 1, BOC Square, Bank of Ceylon Mawatha, Colombo 01',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '00100',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.visa, PaymentNetwork.mastercard],
      supportedCurrencies: ['LKR', 'USD', 'EUR', 'GBP'],
      fees: {
        'transfer': {'percentage': 0.1, 'min': 50.0, 'max': 500.0},
        'withdrawal': {'fixed': 25.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 1000000.0,
        'monthly': 5000000.0,
        'single': 500000.0,
      },
      description: 'Sri Lanka\'s largest commercial bank with extensive branch network',
      establishedDate: DateTime(1939),
      licenseNumber: 'CBSL/001',
      regulator: 'CBSL',
    ),

    SriLankanBank(
      id: 'commercial_002',
      name: 'People\'s Bank',
      shortName: 'PB',
      code: 'PBCYLKLX',
      type: BankType.commercial,
      logoUrl: 'https://www.peoplesbank.lk/images/logo.png',
      website: 'https://www.peoplesbank.lk',
      phone: '+94 11 220 4444',
      email: 'info@peoplesbank.lk',
      address: 'No. 75, Sir Chittampalam A. Gardiner Mawatha, Colombo 02',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '00200',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.visa, PaymentNetwork.mastercard],
      supportedCurrencies: ['LKR', 'USD', 'EUR'],
      fees: {
        'transfer': {'percentage': 0.15, 'min': 50.0, 'max': 750.0},
        'withdrawal': {'fixed': 30.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 800000.0,
        'monthly': 4000000.0,
        'single': 400000.0,
      },
      description: 'Leading commercial bank serving all segments of society',
      establishedDate: DateTime(1961),
      licenseNumber: 'CBSL/002',
      regulator: 'CBSL',
    ),

    SriLankanBank(
      id: 'commercial_003',
      name: 'Commercial Bank of Ceylon',
      shortName: 'CBC',
      code: 'CCEYLKLX',
      type: BankType.commercial,
      logoUrl: 'https://www.combank.lk/images/logo.png',
      website: 'https://www.combank.lk',
      phone: '+94 11 244 4444',
      email: 'info@combank.lk',
      address: 'Commercial House, 21, Sir Razik Fareed Mawatha, Colombo 01',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '00100',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.visa, PaymentNetwork.mastercard, PaymentNetwork.americanExpress],
      supportedCurrencies: ['LKR', 'USD', 'EUR', 'GBP', 'AUD'],
      fees: {
        'transfer': {'percentage': 0.12, 'min': 50.0, 'max': 600.0},
        'withdrawal': {'fixed': 35.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 1200000.0,
        'monthly': 6000000.0,
        'single': 600000.0,
      },
      description: 'Premier private sector commercial bank in Sri Lanka',
      establishedDate: DateTime(1969),
      licenseNumber: 'CBSL/003',
      regulator: 'CBSL',
    ),

    SriLankanBank(
      id: 'commercial_004',
      name: 'Hatton National Bank',
      shortName: 'HNB',
      code: 'HNBELKLX',
      type: BankType.commercial,
      logoUrl: 'https://www.hnb.lk/images/logo.png',
      website: 'https://www.hnb.lk',
      phone: '+94 11 220 4444',
      email: 'info@hnb.lk',
      address: 'HNB Towers, 479, T.B. Jayah Mawatha, Colombo 10',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '01000',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.visa, PaymentNetwork.mastercard],
      supportedCurrencies: ['LKR', 'USD', 'EUR', 'GBP'],
      fees: {
        'transfer': {'percentage': 0.1, 'min': 50.0, 'max': 500.0},
        'withdrawal': {'fixed': 30.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 1000000.0,
        'monthly': 5000000.0,
        'single': 500000.0,
      },
      description: 'Leading private sector bank with strong digital presence',
      establishedDate: DateTime(1888),
      licenseNumber: 'CBSL/004',
      regulator: 'CBSL',
    ),

    SriLankanBank(
      id: 'commercial_005',
      name: 'Sampath Bank',
      shortName: 'Sampath',
      code: 'SAMPKLKLX',
      type: BankType.commercial,
      logoUrl: 'https://www.sampath.lk/images/logo.png',
      website: 'https://www.sampath.lk',
      phone: '+94 11 220 4444',
      email: 'info@sampath.lk',
      address: 'No. 110, Sir James Peiris Mawatha, Colombo 02',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '00200',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.visa, PaymentNetwork.mastercard],
      supportedCurrencies: ['LKR', 'USD', 'EUR'],
      fees: {
        'transfer': {'percentage': 0.15, 'min': 50.0, 'max': 750.0},
        'withdrawal': {'fixed': 25.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 800000.0,
        'monthly': 4000000.0,
        'single': 400000.0,
      },
      description: 'Innovative banking solutions with customer-centric approach',
      establishedDate: DateTime(1987),
      licenseNumber: 'CBSL/005',
      regulator: 'CBSL',
    ),

    // Development Banks
    SriLankanBank(
      id: 'development_001',
      name: 'National Development Bank',
      shortName: 'NDB',
      code: 'NDBELKLX',
      type: BankType.development,
      logoUrl: 'https://www.ndb.lk/images/logo.png',
      website: 'https://www.ndb.lk',
      phone: '+94 11 220 4444',
      email: 'info@ndb.lk',
      address: 'No. 40, Navam Mawatha, Colombo 02',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '00200',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.visa, PaymentNetwork.mastercard],
      supportedCurrencies: ['LKR', 'USD', 'EUR'],
      fees: {
        'transfer': {'percentage': 0.2, 'min': 100.0, 'max': 1000.0},
        'withdrawal': {'fixed': 50.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 500000.0,
        'monthly': 2500000.0,
        'single': 250000.0,
      },
      description: 'Development bank focused on infrastructure and SME financing',
      establishedDate: DateTime(1979),
      licenseNumber: 'CBSL/006',
      regulator: 'CBSL',
    ),

    // Specialized Banks
    SriLankanBank(
      id: 'specialized_001',
      name: 'Lanka Orix Leasing Company',
      shortName: 'LOLC',
      code: 'LOLCLKLX',
      type: BankType.specialized,
      logoUrl: 'https://www.lolc.lk/images/logo.png',
      website: 'https://www.lolc.lk',
      phone: '+94 11 220 4444',
      email: 'info@lolc.lk',
      address: 'No. 481, T.B. Jayah Mawatha, Colombo 10',
      city: 'Colombo',
      district: 'Colombo',
      province: 'Western',
      postalCode: '01000',
      supportedNetworks: [PaymentNetwork.ceylonBank, PaymentNetwork.local],
      supportedCurrencies: ['LKR', 'USD'],
      fees: {
        'transfer': {'percentage': 0.25, 'min': 100.0, 'max': 1250.0},
        'withdrawal': {'fixed': 75.0},
        'deposit': {'fixed': 0.0},
      },
      limits: {
        'daily': 300000.0,
        'monthly': 1500000.0,
        'single': 150000.0,
      },
      description: 'Specialized in leasing and hire purchase financing',
      establishedDate: DateTime(1980),
      licenseNumber: 'CBSL/007',
      regulator: 'CBSL',
    ),
  ];

  // Get banks by type
  static List<SriLankanBank> getBanksByType(BankType type) {
    return majorBanks.where((bank) => bank.type == type).toList();
  }

  // Get active banks only
  static List<SriLankanBank> getActiveBanks() {
    return majorBanks.where((bank) => bank.isActive).toList();
  }

  // Search banks by name
  static List<SriLankanBank> searchBanks(String query) {
    return majorBanks.where((bank) => 
      bank.name.toLowerCase().contains(query.toLowerCase()) ||
      bank.shortName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get bank by ID
  static SriLankanBank? getBankById(String id) {
    try {
      return majorBanks.firstWhere((bank) => bank.id == id);
    } catch (e) {
      return null;
    }
  }
}

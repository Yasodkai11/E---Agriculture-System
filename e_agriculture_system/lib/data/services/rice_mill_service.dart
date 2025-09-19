import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/rice_mill_model.dart';

class RiceMillService {
  // Note: Datantify API would require authentication and payment
  // This service provides sample data and can be extended for real API integration
  static const String _datantifyApiUrl = 'https://api.datantify.com/v1/companies';
  static const String _fallbackDataUrl = 'https://raw.githubusercontent.com/srilanka-agriculture/rice-mills/main/data/sample_rice_mills.json';
  
  // Cache for offline data
  static List<RiceMillModel> _cachedRiceMills = [];
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheValidity = Duration(hours: 12);

  /// Fetch rice mill data from available sources
  static Future<List<RiceMillModel>> getRiceMills() async {
    try {
      // Try to fetch from primary source first
      final riceMills = await _fetchFromPrimarySource();
      if (riceMills.isNotEmpty) {
        _updateCache(riceMills);
        return riceMills;
      }
    } catch (e) {
      debugPrint('Primary source failed: $e');
    }

    // Try fallback source
    try {
      final riceMills = await _fetchFromFallbackSource();
      if (riceMills.isNotEmpty) {
        _updateCache(riceMills);
        return riceMills;
      }
    } catch (e) {
      debugPrint('Fallback source failed: $e');
    }

    // Return cached data if available
    if (_cachedRiceMills.isNotEmpty && _isCacheValid()) {
      return _cachedRiceMills;
    }

    // Return sample data as last resort
    return _getSampleData();
  }

  /// Fetch from Datantify API (primary source)
  static Future<List<RiceMillModel>> _fetchFromPrimarySource() async {
    try {
      // Note: This would require API key and proper authentication
      // For now, we'll return empty list as we don't have API access
      final response = await http.get(
        Uri.parse('$_datantifyApiUrl?industry=rice-mill&location=sri-lanka'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Would need actual API key
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseDatantifyData(data);
      }
    } catch (e) {
      debugPrint('Datantify API error: $e');
    }
    return [];
  }

  /// Fetch from fallback data source
  static Future<List<RiceMillModel>> _fetchFromFallbackSource() async {
    try {
      final response = await http.get(
        Uri.parse(_fallbackDataUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseFallbackData(data);
      }
    } catch (e) {
      debugPrint('Fallback source error: $e');
    }
    return [];
  }

  /// Parse Datantify data format
  static List<RiceMillModel> _parseDatantifyData(dynamic data) {
    // This would parse Datantify API response format
    // For now, return empty list as we don't have API access
    return [];
  }

  /// Parse fallback data
  static List<RiceMillModel> _parseFallbackData(dynamic data) {
    if (data is List) {
      return data.map((item) => RiceMillModel.fromMap(item)).toList();
    }
    return [];
  }

  /// Get sample data with realistic Sri Lankan rice mill information
  static List<RiceMillModel> _getSampleData() {
    final now = DateTime.now();

    return [
      RiceMillModel(
        id: 'rm_001',
        name: 'New Rathna Rice (Pvt) Ltd',
        location: 'Polonnaruwa',
        district: 'Polonnaruwa',
        province: 'North Central Province',
        website: 'https://newrathnarice.com',
        phone: '+94 27 222 3456',
        email: 'info@newrathnarice.com',
        address: 'Polonnaruwa, North Central Province',
        ownerName: 'Mr. Rathna Silva',
        ownerPhone: '+94 77 123 4567',
        ownerEmail: 'rathna@newrathnarice.com',
        businessType: 'Rice Milling & Processing',
        capacity: '50 tons/day',
        establishedYear: '1995',
        description: 'Premium quality rice milling and processing facility',
        riceVarieties: ['Nadu', 'Samba', 'Red Rice', 'Basmati'],
        lastUpdated: now,
        latitude: 7.9403,
        longitude: 81.0188,
      ),
      RiceMillModel(
        id: 'rm_002',
        name: 'Nipuna Rice Mills',
        location: 'Katukeliyawa',
        district: 'Kurunegala',
        province: 'North Western Province',
        phone: '+94 37 223 4567',
        email: 'nipuna@rice.lk',
        address: 'Katukeliyawa, Kurunegala',
        ownerName: 'Mrs. Nipuna Perera',
        ownerPhone: '+94 77 234 5678',
        businessType: 'Rice Milling',
        capacity: '30 tons/day',
        establishedYear: '1988',
        description: 'Family-owned rice milling business',
        riceVarieties: ['Nadu', 'Samba', 'White Rice'],
        lastUpdated: now,
        latitude: 7.4863,
        longitude: 80.3647,
      ),
      RiceMillModel(
        id: 'rm_003',
        name: 'Jayawickrama Rice (Pvt) Ltd',
        location: '26th Mile Post',
        district: 'Kurunegala',
        province: 'North Western Province',
        website: 'https://jayawickramarice.com',
        phone: '+94 37 224 5678',
        email: 'contact@jayawickramarice.com',
        address: '26th Mile Post, Kurunegala',
        ownerName: 'Mr. Jayawickrama Fernando',
        ownerPhone: '+94 77 345 6789',
        ownerEmail: 'jayawickrama@jayawickramarice.com',
        businessType: 'Rice Processing & Export',
        capacity: '75 tons/day',
        establishedYear: '2001',
        description: 'Modern rice processing facility with export capabilities',
        riceVarieties: ['Nadu', 'Samba', 'Red Rice', 'Brown Rice', 'Basmati'],
        lastUpdated: now,
        latitude: 7.4863,
        longitude: 80.3647,
      ),
      RiceMillModel(
        id: 'rm_004',
        name: 'INDUNIL RICE ඉඳුනිල් සහල්',
        location: 'Siripura',
        district: 'Anuradhapura',
        province: 'North Central Province',
        phone: '+94 25 225 6789',
        email: 'indunil@rice.lk',
        address: 'Siripura, Anuradhapura',
        ownerName: 'Mr. Indunil Rajapaksa',
        ownerPhone: '+94 77 456 7890',
        businessType: 'Traditional Rice Milling',
        capacity: '25 tons/day',
        establishedYear: '1975',
        description: 'Traditional rice milling with modern equipment',
        riceVarieties: ['Nadu', 'Samba', 'Red Rice'],
        lastUpdated: now,
        latitude: 8.3114,
        longitude: 80.4037,
      ),
      RiceMillModel(
        id: 'rm_005',
        name: 'Araliya Rice Mill',
        location: 'Polonnaruwa',
        district: 'Polonnaruwa',
        province: 'North Central Province',
        phone: '+94 27 226 7890',
        email: 'araliya@rice.lk',
        address: 'Polonnaruwa, North Central Province',
        ownerName: 'Mrs. Araliya Jayawardena',
        ownerPhone: '+94 77 567 8901',
        businessType: 'Rice Milling & Distribution',
        capacity: '40 tons/day',
        establishedYear: '1990',
        description: 'Quality rice milling and distribution services',
        riceVarieties: ['Nadu', 'Samba', 'White Rice', 'Red Rice'],
        lastUpdated: now,
        latitude: 7.9403,
        longitude: 81.0188,
      ),
      RiceMillModel(
        id: 'rm_006',
        name: 'SHUKRY RICE MILL PVT LTD',
        location: 'Sinnamuhathuvaram',
        district: 'Batticaloa',
        province: 'Eastern Province',
        phone: '+94 65 227 8901',
        email: 'shukry@rice.lk',
        address: 'Sinnamuhathuvaram, Batticaloa',
        ownerName: 'Mr. Shukry Mohamed',
        ownerPhone: '+94 77 678 9012',
        businessType: 'Rice Milling & Trading',
        capacity: '35 tons/day',
        establishedYear: '1985',
        description: 'Rice milling and trading business',
        riceVarieties: ['Nadu', 'Samba', 'Red Rice'],
        lastUpdated: now,
        latitude: 7.7102,
        longitude: 81.6924,
      ),
      RiceMillModel(
        id: 'rm_007',
        name: 'Hewage Rice Mill හේවගේ හාල්මෝල',
        location: 'Weerakatiya',
        district: 'Hambantota',
        province: 'Southern Province',
        phone: '+94 47 228 9012',
        email: 'hewage@rice.lk',
        address: 'Weerakatiya, Hambantota',
        ownerName: 'Mr. Hewage Bandara',
        ownerPhone: '+94 77 789 0123',
        businessType: 'Rice Milling',
        capacity: '20 tons/day',
        establishedYear: '1980',
        description: 'Traditional rice milling business',
        riceVarieties: ['Nadu', 'Samba'],
        lastUpdated: now,
        latitude: 6.1244,
        longitude: 81.1185,
      ),
      RiceMillModel(
        id: 'rm_008',
        name: 'Kasun Rice Mills',
        location: 'Madinnoruwa',
        district: 'Kurunegala',
        province: 'North Western Province',
        phone: '+94 37 229 0123',
        email: 'kasun@rice.lk',
        address: 'Madinnoruwa, Kurunegala',
        ownerName: 'Mr. Kasun Perera',
        ownerPhone: '+94 77 890 1234',
        businessType: 'Rice Milling',
        capacity: '30 tons/day',
        establishedYear: '1992',
        description: 'Modern rice milling facility',
        riceVarieties: ['Nadu', 'Samba', 'White Rice'],
        lastUpdated: now,
        latitude: 7.4863,
        longitude: 80.3647,
      ),
      RiceMillModel(
        id: 'rm_009',
        name: 'Sanjeewa Ricemill',
        location: 'Adhikarigama',
        district: 'Kurunegala',
        province: 'North Western Province',
        phone: '+94 37 230 1234',
        email: 'sanjeeva@rice.lk',
        address: 'Adhikarigama, Kurunegala',
        ownerName: 'Mr. Sanjeewa Silva',
        ownerPhone: '+94 77 901 2345',
        businessType: 'Rice Milling',
        capacity: '25 tons/day',
        establishedYear: '1987',
        description: 'Family-owned rice milling business',
        riceVarieties: ['Nadu', 'Samba'],
        lastUpdated: now,
        latitude: 7.4863,
        longitude: 80.3647,
      ),
      RiceMillModel(
        id: 'rm_010',
        name: 'Asmath Rice Mill',
        location: 'Gallella',
        district: 'Kurunegala',
        province: 'North Western Province',
        phone: '+94 37 231 2345',
        email: 'asmath@rice.lk',
        address: 'Gallella, Kurunegala',
        ownerName: 'Mr. Asmath Mohamed',
        ownerPhone: '+94 77 012 3456',
        businessType: 'Rice Milling',
        capacity: '35 tons/day',
        establishedYear: '1995',
        description: 'Rice milling and processing',
        riceVarieties: ['Nadu', 'Samba', 'Red Rice'],
        lastUpdated: now,
        latitude: 7.4863,
        longitude: 80.3647,
      ),
    ];
  }

  /// Update cache with new data
  static void _updateCache(List<RiceMillModel> riceMills) {
    _cachedRiceMills = riceMills;
    _lastCacheUpdate = DateTime.now();
  }

  /// Check if cache is still valid
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidity;
  }

  /// Get rice mills by district
  static Future<List<RiceMillModel>> getRiceMillsByDistrict(String district) async {
    final allRiceMills = await getRiceMills();
    return allRiceMills.where((mill) => mill.district.toLowerCase() == district.toLowerCase()).toList();
  }

  /// Get rice mills by province
  static Future<List<RiceMillModel>> getRiceMillsByProvince(String province) async {
    final allRiceMills = await getRiceMills();
    return allRiceMills.where((mill) => mill.province.toLowerCase() == province.toLowerCase()).toList();
  }

  /// Search rice mills
  static Future<List<RiceMillModel>> searchRiceMills(String query) async {
    final allRiceMills = await getRiceMills();
    return allRiceMills.where((mill) =>
        mill.name.toLowerCase().contains(query.toLowerCase()) ||
        mill.location.toLowerCase().contains(query.toLowerCase()) ||
        mill.district.toLowerCase().contains(query.toLowerCase()) ||
        mill.province.toLowerCase().contains(query.toLowerCase()) ||
        (mill.ownerName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        mill.riceVarieties.any((variety) => variety.toLowerCase().contains(query.toLowerCase()))).toList();
  }

  /// Get rice mills with contact information
  static Future<List<RiceMillModel>> getRiceMillsWithContact() async {
    final allRiceMills = await getRiceMills();
    return allRiceMills.where((mill) => mill.hasContactInfo).toList();
  }

  /// Get rice mills by rice variety
  static Future<List<RiceMillModel>> getRiceMillsByVariety(String variety) async {
    final allRiceMills = await getRiceMills();
    return allRiceMills.where((mill) => 
        mill.riceVarieties.any((v) => v.toLowerCase().contains(variety.toLowerCase()))).toList();
  }

  /// Get rice mill statistics
  static Future<Map<String, dynamic>> getRiceMillStatistics() async {
    final riceMills = await getRiceMills();
    
    final districtCount = <String, int>{};
    final provinceCount = <String, int>{};
    int withContactInfo = 0;
    int withOwnerInfo = 0;
    int withLocation = 0;
    
    for (final mill in riceMills) {
      districtCount[mill.district] = (districtCount[mill.district] ?? 0) + 1;
      provinceCount[mill.province] = (provinceCount[mill.province] ?? 0) + 1;
      
      if (mill.hasContactInfo) withContactInfo++;
      if (mill.hasOwnerInfo) withOwnerInfo++;
      if (mill.hasLocation) withLocation++;
    }
    
    return {
      'totalRiceMills': riceMills.length,
      'withContactInfo': withContactInfo,
      'withOwnerInfo': withOwnerInfo,
      'withLocation': withLocation,
      'districtCount': districtCount,
      'provinceCount': provinceCount,
      'lastUpdated': riceMills.isNotEmpty ? riceMills.first.lastUpdated : DateTime.now(),
    };
  }

  /// Get real-time updates stream
  static Stream<List<RiceMillModel>> getRiceMillsStream() async* {
    while (true) {
      yield await getRiceMills();
      await Future.delayed(const Duration(hours: 6)); // Update every 6 hours
    }
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'weather_service.dart';

class NotificationAutomationService {
  static final NotificationAutomationService _instance = NotificationAutomationService._internal();
  factory NotificationAutomationService() => _instance;
  NotificationAutomationService._internal();

  final NotificationService _notificationService = NotificationService();
  final WeatherService _weatherService = WeatherService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _dailyWeatherTimer;
  Timer? _harvestCheckTimer;
  Timer? _equipmentMaintenanceTimer;

  // Initialize automation service
  Future<void> initialize() async {
    debugPrint('Initializing Notification Automation Service...');
    
    // Start daily weather notifications at 7:00 AM
    _scheduleDailyWeatherNotifications();
    
    // Start harvest check every 6 hours
    _scheduleHarvestCheck();
    
    // Start equipment maintenance check daily at 8:00 AM
    _scheduleEquipmentMaintenanceCheck();
    
    debugPrint('Notification Automation Service initialized');
  }

  // Schedule daily weather notifications
  void _scheduleDailyWeatherNotifications() {
    // Cancel existing timer
    _dailyWeatherTimer?.cancel();
    
    // Calculate time until next 7:00 AM
    final now = DateTime.now();
    var next7AM = DateTime(now.year, now.month, now.day, 7, 0);
    
    // If it's already past 7:00 AM today, schedule for tomorrow
    if (now.isAfter(next7AM)) {
      next7AM = next7AM.add(const Duration(days: 1));
    }
    
    final duration = next7AM.difference(now);
    
    _dailyWeatherTimer = Timer(duration, () {
      _sendDailyWeatherNotifications();
      // Schedule next day
      _scheduleDailyWeatherNotifications();
    });
    
    debugPrint('Daily weather notifications scheduled for: $next7AM');
  }

  // Send daily weather notifications to all farmers
  Future<void> _sendDailyWeatherNotifications() async {
    try {
      debugPrint('Sending daily weather notifications...');
      
      // Get all farmer users
      final farmers = await _getAllFarmers();
      
      for (final farmer in farmers) {
        try {
          // Get farmer's preferred city (default to Colombo if not set)
          final city = farmer['preferredCity'] ?? 'Colombo';
          
          // Get weather data
          final weatherResult = await _weatherService.getWeatherForCity(city);
          
          // Create weather summary
          final currentTemp = weatherResult.currentTemperatureC.round().toString();
          final condition = weatherResult.currentDescription;
          final forecast = _createWeatherForecast(weatherResult.forecast);
          
          // Send notification
          await _notificationService.sendNotificationToUser(
            userId: farmer['id'],
            title: 'Daily Weather Update - $city',
            body: 'Current: $currentTemp°C, $condition. $forecast',
            type: NotificationType.daily_weather,
            priority: NotificationPriority.medium,
            route: '/weather',
            data: {
              'city': city,
              'temperature': currentTemp,
              'condition': condition,
              'forecast': forecast,
            },
          );
          
          debugPrint('Daily weather notification sent to farmer: ${farmer['id']}');
        } catch (e) {
          debugPrint('Error sending weather notification to farmer ${farmer['id']}: $e');
        }
      }
      
      debugPrint('Daily weather notifications completed');
    } catch (e) {
      debugPrint('Error in daily weather notifications: $e');
    }
  }

  // Schedule harvest check
  void _scheduleHarvestCheck() {
    _harvestCheckTimer?.cancel();
    
    // Check every 6 hours
    _harvestCheckTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      _checkHarvestReadiness();
    });
    
    debugPrint('Harvest check scheduled every 6 hours');
  }

  // Check harvest readiness for all farmers
  Future<void> _checkHarvestReadiness() async {
    try {
      debugPrint('Checking harvest readiness...');
      
      // Get all farmers with crops
      final farmers = await _getAllFarmers();
      
      for (final farmer in farmers) {
        try {
          // Get farmer's crops
          final crops = await _getFarmerCrops(farmer['id']);
          
          for (final crop in crops) {
            // Check if crop is ready for harvest
            if (_isCropReadyForHarvest(crop)) {
              await _notificationService.sendNotificationToUser(
                userId: farmer['id'],
                title: 'Harvest Ready: ${crop['name']}',
                body: '${crop['quantity']} ready for harvest on ${crop['harvestDate']}. Check your fields!',
                type: NotificationType.harvest,
                priority: NotificationPriority.high,
                route: '/harvest-management',
                data: {
                  'crop': crop['name'],
                  'harvest_date': crop['harvestDate'],
                  'quantity': crop['quantity'],
                },
              );
              
              debugPrint('Harvest notification sent for crop: ${crop['name']}');
            }
          }
        } catch (e) {
          debugPrint('Error checking harvest for farmer ${farmer['id']}: $e');
        }
      }
      
      debugPrint('Harvest check completed');
    } catch (e) {
      debugPrint('Error in harvest check: $e');
    }
  }

  // Schedule equipment maintenance check
  void _scheduleEquipmentMaintenanceCheck() {
    _equipmentMaintenanceTimer?.cancel();
    
    // Calculate time until next 8:00 AM
    final now = DateTime.now();
    var next8AM = DateTime(now.year, now.month, now.day, 8, 0);
    
    // If it's already past 8:00 AM today, schedule for tomorrow
    if (now.isAfter(next8AM)) {
      next8AM = next8AM.add(const Duration(days: 1));
    }
    
    final duration = next8AM.difference(now);
    
    _equipmentMaintenanceTimer = Timer(duration, () {
      _checkEquipmentMaintenance();
      // Schedule next day
      _scheduleEquipmentMaintenanceCheck();
    });
    
    debugPrint('Equipment maintenance check scheduled for: $next8AM');
  }

  // Check equipment maintenance for all farmers
  Future<void> _checkEquipmentMaintenance() async {
    try {
      debugPrint('Checking equipment maintenance...');
      
      final farmers = await _getAllFarmers();
      
      for (final farmer in farmers) {
        try {
          final equipment = await _getFarmerEquipment(farmer['id']);
          
          for (final item in equipment) {
            if (_isEquipmentDueForMaintenance(item)) {
              await _notificationService.sendNotificationToUser(
                userId: farmer['id'],
                title: 'Equipment Maintenance: ${item['name']}',
                body: '${item['name']} is due for maintenance on ${item['nextMaintenanceDate']}',
                type: NotificationType.equipment,
                priority: NotificationPriority.medium,
                route: '/equipment-management',
                data: {
                  'equipment': item['name'],
                  'maintenance_date': item['nextMaintenanceDate'],
                },
              );
              
              debugPrint('Equipment maintenance notification sent for: ${item['name']}');
            }
          }
        } catch (e) {
          debugPrint('Error checking equipment for farmer ${farmer['id']}: $e');
        }
      }
      
      debugPrint('Equipment maintenance check completed');
    } catch (e) {
      debugPrint('Error in equipment maintenance check: $e');
    }
  }

  // Helper methods
  Future<List<Map<String, dynamic>>> _getAllFarmers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'farmer')
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error getting farmers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getFarmerCrops(String farmerId) async {
    try {
      final snapshot = await _firestore
          .collection('crops')
          .where('farmerId', isEqualTo: farmerId)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error getting farmer crops: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getFarmerEquipment(String farmerId) async {
    try {
      final snapshot = await _firestore
          .collection('equipment')
          .where('farmerId', isEqualTo: farmerId)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error getting farmer equipment: $e');
      return [];
    }
  }

  bool _isCropReadyForHarvest(Map<String, dynamic> crop) {
    try {
      final harvestDate = DateTime.tryParse(crop['harvestDate'] ?? '');
      if (harvestDate == null) return false;
      
      final now = DateTime.now();
      final daysUntilHarvest = harvestDate.difference(now).inDays;
      
      // Notify if harvest is within 3 days
      return daysUntilHarvest <= 3 && daysUntilHarvest >= 0;
    } catch (e) {
      debugPrint('Error checking harvest readiness: $e');
      return false;
    }
  }

  bool _isEquipmentDueForMaintenance(Map<String, dynamic> equipment) {
    try {
      final maintenanceDate = DateTime.tryParse(equipment['nextMaintenanceDate'] ?? '');
      if (maintenanceDate == null) return false;
      
      final now = DateTime.now();
      final daysUntilMaintenance = maintenanceDate.difference(now).inDays;
      
      // Notify if maintenance is within 7 days
      return daysUntilMaintenance <= 7 && daysUntilMaintenance >= 0;
    } catch (e) {
      debugPrint('Error checking equipment maintenance: $e');
      return false;
    }
  }

  String _createWeatherForecast(List<ForecastDay> forecast) {
    if (forecast.isEmpty) return 'No forecast available';
    
    final today = forecast.first;
    final tomorrow = forecast.length > 1 ? forecast[1] : null;
    
    String summary = 'Today: ${today.description} (${today.temperatureMaxC.round()}°C)';
    
    if (tomorrow != null) {
      summary += ', Tomorrow: ${tomorrow.description} (${tomorrow.temperatureMaxC.round()}°C)';
    }
    
    return summary;
  }

  // Manual trigger methods for testing
  Future<void> triggerDailyWeatherNotifications() async {
    await _sendDailyWeatherNotifications();
  }

  Future<void> triggerHarvestCheck() async {
    await _checkHarvestReadiness();
  }

  Future<void> triggerEquipmentMaintenanceCheck() async {
    await _checkEquipmentMaintenance();
  }

  // Dispose resources
  void dispose() {
    _dailyWeatherTimer?.cancel();
    _harvestCheckTimer?.cancel();
    _equipmentMaintenanceTimer?.cancel();
  }
}

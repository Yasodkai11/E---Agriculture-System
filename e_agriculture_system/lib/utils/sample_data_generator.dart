import '../data/models/daily_update_model.dart';
import '../data/services/daily_update_service.dart';

class SampleDataGenerator {
  static final DailyUpdateService _dailyUpdateService = DailyUpdateService();

  static Future<void> generateSampleDailyUpdates() async {
    try {
      final sampleUpdates = [
        DailyUpdateModel(
          id: '',
          title: 'Weather Alert: Heavy Rainfall Expected',
          description: 'Heavy rainfall is expected in your area today. Please protect your crops and ensure proper drainage.',
          category: 'Weather',
          priority: 'High',
          icon: 'wb_sunny',
          color: '#FF9800',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Market Price Update: Rice Prices Up',
          description: 'Rice prices have increased by 5% in local markets. Consider selling your rice stock.',
          category: 'Market',
          priority: 'Medium',
          icon: 'trending_up',
          color: '#4CAF50',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Crop Health: Wheat Disease Alert',
          description: 'Wheat rust disease detected in nearby farms. Check your wheat crops and apply preventive measures.',
          category: 'Crops',
          priority: 'High',
          icon: 'eco',
          color: '#FF5722',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Irrigation Schedule Update',
          description: 'Your irrigation system is scheduled for maintenance tomorrow. Prepare alternative watering methods.',
          category: 'Irrigation',
          priority: 'Medium',
          icon: 'water_drop',
          color: '#00BCD4',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Fertilizer Application Reminder',
          description: 'Time to apply nitrogen fertilizer to your corn field. Optimal application window is this week.',
          category: 'Fertilizer',
          priority: 'Medium',
          icon: 'grass',
          color: '#9C27B0',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Pest Control: Aphid Infestation',
          description: 'Aphid infestation reported in nearby soybean fields. Monitor your crops and apply insecticides if needed.',
          category: 'Pest',
          priority: 'High',
          icon: 'bug_report',
          color: '#FF9800',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Equipment Maintenance Due',
          description: 'Your tractor is due for routine maintenance. Schedule service to avoid breakdowns during harvest.',
          category: 'Equipment',
          priority: 'Low',
          icon: 'build',
          color: '#607D8B',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Financial Report: Monthly Summary',
          description: 'Your monthly financial report is ready. Check your expenses and revenue for better planning.',
          category: 'Financial',
          priority: 'Medium',
          icon: 'account_balance',
          color: '#795548',
        ),
        DailyUpdateModel(
          id: '',
          title: 'System Update: New Features Available',
          description: 'New features have been added to the AGRIGO app. Update to access improved crop monitoring tools.',
          category: 'System',
          priority: 'Low',
          icon: 'system_update',
          color: '#9E9E9E',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Emergency Alert: Storm Warning',
          description: 'Severe storm warning issued for your region. Secure all equipment and protect livestock immediately.',
          category: 'Alerts',
          priority: 'High',
          icon: 'warning',
          color: '#FF5722',
        ),
      ];

      for (final update in sampleUpdates) {
        await _dailyUpdateService.createDailyUpdate(update);
      }

      print('Sample daily updates generated successfully!');
    } catch (e) {
      print('Error generating sample data: $e');
    }
  }

  static Future<void> clearAllDailyUpdates() async {
    try {
      await _dailyUpdateService.deleteAllDailyUpdates();
      print('All daily updates cleared successfully!');
    } catch (e) {
      print('Error clearing daily updates: $e');
    }
  }

  static Future<void> generateWeatherUpdates() async {
    try {
      final weatherUpdates = [
        DailyUpdateModel(
          id: '',
          title: 'Sunny Weather Expected',
          description: 'Clear skies and sunny weather expected for the next 3 days. Perfect for harvesting activities.',
          category: 'Weather',
          priority: 'Medium',
          icon: 'wb_sunny',
          color: '#2196F3',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Temperature Drop Alert',
          description: 'Temperature expected to drop to 5°C tonight. Protect sensitive crops from frost damage.',
          category: 'Weather',
          priority: 'High',
          icon: 'wb_sunny',
          color: '#FF9800',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Wind Advisory',
          description: 'Strong winds expected today. Secure loose equipment and protect tall crops.',
          category: 'Weather',
          priority: 'Medium',
          icon: 'wb_sunny',
          color: '#2196F3',
        ),
      ];

      for (final update in weatherUpdates) {
        await _dailyUpdateService.createDailyUpdate(update);
      }

      print('Weather updates generated successfully!');
    } catch (e) {
      print('Error generating weather updates: $e');
    }
  }

  static Future<void> generateMarketUpdates() async {
    try {
      final marketUpdates = [
        DailyUpdateModel(
          id: '',
          title: 'Corn Prices Stable',
          description: 'Corn prices remain stable this week. Good time to plan your selling strategy.',
          category: 'Market',
          priority: 'Medium',
          icon: 'trending_up',
          color: '#4CAF50',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Soybean Price Increase',
          description: 'Soybean prices increased by 8% due to high demand. Consider selling your soybean stock.',
          category: 'Market',
          priority: 'High',
          icon: 'trending_up',
          color: '#4CAF50',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Wheat Market Update',
          description: 'Wheat prices showing downward trend. Monitor market conditions before selling.',
          category: 'Market',
          priority: 'Medium',
          icon: 'trending_up',
          color: '#4CAF50',
        ),
      ];

      for (final update in marketUpdates) {
        await _dailyUpdateService.createDailyUpdate(update);
      }

      print('Market updates generated successfully!');
    } catch (e) {
      print('Error generating market updates: $e');
    }
  }

  static Future<void> generateCropUpdates() async {
    try {
      final cropUpdates = [
        DailyUpdateModel(
          id: '',
          title: 'Corn Growth Stage: Tasseling',
          description: 'Your corn crop has entered the tasseling stage. Monitor for pollination and pest activity.',
          category: 'Crops',
          priority: 'Medium',
          icon: 'eco',
          color: '#8BC34A',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Soybean Pod Development',
          description: 'Soybean pods are developing well. Continue monitoring for disease and pest pressure.',
          category: 'Crops',
          priority: 'Medium',
          icon: 'eco',
          color: '#8BC34A',
        ),
        DailyUpdateModel(
          id: '',
          title: 'Wheat Harvest Preparation',
          description: 'Wheat crop is nearing harvest readiness. Check moisture content and prepare harvesting equipment.',
          category: 'Crops',
          priority: 'High',
          icon: 'eco',
          color: '#8BC34A',
        ),
      ];

      for (final update in cropUpdates) {
        await _dailyUpdateService.createDailyUpdate(update);
      }

      print('Crop updates generated successfully!');
    } catch (e) {
      print('Error generating crop updates: $e');
    }
  }
}

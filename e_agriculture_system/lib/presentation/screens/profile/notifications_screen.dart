import 'package:flutter/material.dart';
import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _marketUpdates = true;
  bool _weatherAlerts = true;
  bool _cropReminders = true;
  bool _priceAlerts = true;
  bool _expertChatNotifications = true;
  bool _dailyUpdates = true;
  bool _orderUpdates = true;
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pushNotifications = prefs.getBool('push_notifications') ?? true;
        _emailNotifications = prefs.getBool('email_notifications') ?? true;
        _smsNotifications = prefs.getBool('sms_notifications') ?? false;
        _marketUpdates = prefs.getBool('market_updates') ?? true;
        _weatherAlerts = prefs.getBool('weather_alerts') ?? true;
        _cropReminders = prefs.getBool('crop_reminders') ?? true;
        _priceAlerts = prefs.getBool('price_alerts') ?? true;
        _expertChatNotifications = prefs.getBool('expert_chat_notifications') ?? true;
        _dailyUpdates = prefs.getBool('daily_updates') ?? true;
        _orderUpdates = prefs.getBool('order_updates') ?? true;
        _systemUpdates = prefs.getBool('system_updates') ?? true;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', _pushNotifications);
      await prefs.setBool('email_notifications', _emailNotifications);
      await prefs.setBool('sms_notifications', _smsNotifications);
      await prefs.setBool('market_updates', _marketUpdates);
      await prefs.setBool('weather_alerts', _weatherAlerts);
      await prefs.setBool('crop_reminders', _cropReminders);
      await prefs.setBool('price_alerts', _priceAlerts);
      await prefs.setBool('expert_chat_notifications', _expertChatNotifications);
      await prefs.setBool('daily_updates', _dailyUpdates);
      await prefs.setBool('order_updates', _orderUpdates);
      await prefs.setBool('system_updates', _systemUpdates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.primary),
            onPressed: _saveNotificationSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Notifications
            _buildNotificationSection(
              title: 'General Notifications',
              subtitle: 'Manage your notification preferences',
              children: [
                _buildNotificationItem(
                  icon: Icons.notifications_active,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications on your device',
                  value: _pushNotifications,
                  onChanged: (value) => setState(() => _pushNotifications = value),
                ),
                _buildNotificationItem(
                  icon: Icons.email,
                  title: 'Email Notifications',
                  subtitle: 'Receive notifications via email',
                  value: _emailNotifications,
                  onChanged: (value) => setState(() => _emailNotifications = value),
                ),
                _buildNotificationItem(
                  icon: Icons.sms,
                  title: 'SMS Notifications',
                  subtitle: 'Receive notifications via SMS',
                  value: _smsNotifications,
                  onChanged: (value) => setState(() => _smsNotifications = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Farming Notifications
            _buildNotificationSection(
              title: 'Farming Notifications',
              subtitle: 'Stay updated with your farming activities',
              children: [
                _buildNotificationItem(
                  icon: Icons.agriculture,
                  title: 'Crop Reminders',
                  subtitle: 'Get reminded about crop maintenance',
                  value: _cropReminders,
                  onChanged: (value) => setState(() => _cropReminders = value),
                ),
                _buildNotificationItem(
                  icon: Icons.wb_sunny,
                  title: 'Weather Alerts',
                  subtitle: 'Get weather updates and alerts',
                  value: _weatherAlerts,
                  onChanged: (value) => setState(() => _weatherAlerts = value),
                ),
                _buildNotificationItem(
                    icon: Icons.update,
                  title: 'Daily Updates',
                  subtitle: 'Receive daily farming updates',
                  value: _dailyUpdates,
                  onChanged: (value) => setState(() => _dailyUpdates = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Market Notifications
            _buildNotificationSection(
              title: 'Market Notifications',
              subtitle: 'Stay informed about market changes',
              children: [
                _buildNotificationItem(
                  icon: Icons.trending_up,
                  title: 'Market Updates',
                  subtitle: 'Get market price updates',
                  value: _marketUpdates,
                  onChanged: (value) => setState(() => _marketUpdates = value),
                ),
                _buildNotificationItem(
                  icon: Icons.attach_money,
                  title: 'Price Alerts',
                  subtitle: 'Get notified about price changes',
                  value: _priceAlerts,
                  onChanged: (value) => setState(() => _priceAlerts = value),
                ),
                _buildNotificationItem(
                  icon: Icons.shopping_cart,
                  title: 'Order Updates',
                  subtitle: 'Get updates about your orders',
                  value: _orderUpdates,
                  onChanged: (value) => setState(() => _orderUpdates = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Support Notifications
            _buildNotificationSection(
              title: 'Support Notifications',
              subtitle: 'Stay connected with support services',
              children: [
                _buildNotificationItem(
                  icon: Icons.support_agent,
                  title: 'Expert Chat',
                  subtitle: 'Get notified about expert responses',
                  value: _expertChatNotifications,
                  onChanged: (value) => setState(() => _expertChatNotifications = value),
                ),
                _buildNotificationItem(
                  icon: Icons.system_update,
                  title: 'System Updates',
                  subtitle: 'Get notified about app updates',
                  value: _systemUpdates,
                  onChanged: (value) => setState(() => _systemUpdates = value),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveNotificationSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

import 'package:e_agriculture_system/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  bool _locationSharing = true;
  bool _dataAnalytics = true;
  bool _profileVisibility = true;
  bool _marketDataSharing = true;
  bool _expertChatHistory = true;
  bool _autoBackup = true;
  bool _crashReports = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _biometricAuth = prefs.getBool('biometric_auth') ?? false;
        _twoFactorAuth = prefs.getBool('two_factor_auth') ?? false;
        _locationSharing = prefs.getBool('location_sharing') ?? true;
        _dataAnalytics = prefs.getBool('data_analytics') ?? true;
        _profileVisibility = prefs.getBool('profile_visibility') ?? true;
        _marketDataSharing = prefs.getBool('market_data_sharing') ?? true;
        _expertChatHistory = prefs.getBool('expert_chat_history') ?? true;
        _autoBackup = prefs.getBool('auto_backup') ?? true;
        _crashReports = prefs.getBool('crash_reports') ?? true;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _savePrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_auth', _biometricAuth);
      await prefs.setBool('two_factor_auth', _twoFactorAuth);
      await prefs.setBool('location_sharing', _locationSharing);
      await prefs.setBool('data_analytics', _dataAnalytics);
      await prefs.setBool('profile_visibility', _profileVisibility);
      await prefs.setBool('market_data_sharing', _marketDataSharing);
      await prefs.setBool('expert_chat_history', _expertChatHistory);
      await prefs.setBool('auto_backup', _autoBackup);
      await prefs.setBool('crash_reports', _crashReports);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy settings saved successfully'),
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

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Choose how you want to change your password:',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.changePassword);
            },
            child: const Text(
              'Change Now',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.resetPassword);
            },
            child: const Text(
              'Reset via Email',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion initiated'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
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
          'Privacy & Security',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.primary),
            onPressed: _savePrivacySettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Settings
            _buildSettingsSection(
              title: 'Security',
              subtitle: 'Manage your account security',
              children: [
                _buildSettingItem(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face ID to login',
                  value: _biometricAuth,
                  onChanged: (value) => setState(() => _biometricAuth = value),
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  value: _twoFactorAuth,
                  onChanged: (value) => setState(() => _twoFactorAuth = value),
                ),
                _buildActionItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Privacy Settings
            _buildSettingsSection(
              title: 'Privacy',
              subtitle: 'Control your data and privacy',
              children: [
                _buildSettingItem(
                  icon: Icons.location_on,
                  title: 'Location Sharing',
                  subtitle: 'Share your location for weather updates',
                  value: _locationSharing,
                  onChanged: (value) => setState(() => _locationSharing = value),
                ),
                _buildSettingItem(
                  icon: Icons.analytics,
                  title: 'Data Analytics',
                  subtitle: 'Help improve the app with usage data',
                  value: _dataAnalytics,
                  onChanged: (value) => setState(() => _dataAnalytics = value),
                ),
                _buildSettingItem(
                  icon: Icons.visibility,
                  title: 'Profile Visibility',
                  subtitle: 'Make your profile visible to other farmers',
                  value: _profileVisibility,
                  onChanged: (value) => setState(() => _profileVisibility = value),
                ),
                _buildSettingItem(
                  icon: Icons.trending_up,
                  title: 'Market Data Sharing',
                  subtitle: 'Share your market data anonymously',
                  value: _marketDataSharing,
                  onChanged: (value) => setState(() => _marketDataSharing = value),
                ),
                _buildSettingItem(
                  icon: Icons.chat,
                  title: 'Expert Chat History',
                  subtitle: 'Save your chat history with experts',
                  value: _expertChatHistory,
                  onChanged: (value) => setState(() => _expertChatHistory = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Data Settings
            _buildSettingsSection(
              title: 'Data & Backup',
              subtitle: 'Manage your data and backups',
              children: [
                _buildSettingItem(
                  icon: Icons.backup,
                  title: 'Auto Backup',
                  subtitle: 'Automatically backup your data',
                  value: _autoBackup,
                  onChanged: (value) => setState(() => _autoBackup = value),
                ),
                _buildSettingItem(
                  icon: Icons.bug_report,
                  title: 'Crash Reports',
                  subtitle: 'Send crash reports to help improve the app',
                  value: _crashReports,
                  onChanged: (value) => setState(() => _crashReports = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Account Actions
            _buildSettingsSection(
              title: 'Account Actions',
              subtitle: 'Manage your account',
              children: [
                _buildActionItem(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  onTap: _showDeleteAccountDialog,
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePrivacySettings,
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

  Widget _buildSettingsSection({
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

  Widget _buildSettingItem({
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

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

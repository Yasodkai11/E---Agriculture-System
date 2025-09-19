import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:e_agriculture_system/data/services/enhanced_user_service.dart';
import 'package:e_agriculture_system/data/services/auth_service.dart';
import 'package:e_agriculture_system/data/models/user_model.dart';
import 'package:e_agriculture_system/l10n/app_localizations.dart';
import 'package:e_agriculture_system/presentation/providers/auth_provider.dart';
import 'package:e_agriculture_system/presentation/widgets/common/custom_button.dart';
import 'package:e_agriculture_system/presentation/widgets/common/custom_text_field.dart';
import 'package:e_agriculture_system/presentation/widgets/common/language_toggle.dart';
import 'package:e_agriculture_system/presentation/widgets/common/profile_picture_widget.dart';
import 'package:e_agriculture_system/presentation/providers/theme_provider.dart';
import 'package:e_agriculture_system/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  final EnhancedUserService _userService = EnhancedUserService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.getCurrentUserData();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.fullName;
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber;
          _locationController.text = user.location ?? '';

          // Safely access preferences with null checking
          final preferences = user.preferences ?? <String, dynamic>{};
          _farmSizeController.text = preferences['farmSize']?.toString() ?? '';
          _experienceController.text =
              preferences['experience']?.toString() ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load user profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user data available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Get current preferences safely
      final currentPreferences =
          _currentUser!.preferences ?? <String, dynamic>{};

      // Create updated preferences
      final updatedPreferences = <String, dynamic>{
        ...currentPreferences, // Keep existing preferences
        'farmSize': _farmSizeController.text.trim(),
        'experience': _experienceController.text.trim(),
      };

      // Update user profile
      final updatedUser = await _userService.updateUserProfile(
        userId: _currentUser!.id,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        preferences: updatedPreferences,
      );

      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _loadUserProfile,
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture
                        ProfileScreenPicture(
                          imageUrl: _currentUser?.profileImageUrl,
                          onTap: () {
                            // Navigate to appropriate profile screen based on user type
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.isBuyer) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.buyerProfile,
                              );
                            } else {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.enhancedProfile,
                              );
                            }
                          },
                          size: 100,
                          isEditing: _isEditing,
                        ),

                        const SizedBox(height: 16),

                        // Welcome Text
                        Text(
                          'Welcome ${_currentUser?.fullName ?? 'User'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _currentUser?.email ?? 'No email available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Profile Information Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 24),

                        CustomTextField(
                          label: 'Full Name',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          enabled: _isEditing,
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          enabled: false, // Email is typically not editable
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Location',
                          controller: _locationController,
                          prefixIcon: Icons.location_on_outlined,
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Farm Information
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farm Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 24),

                        CustomTextField(
                          label: 'Farm Size',
                          controller: _farmSizeController,
                          prefixIcon: Icons.landscape_outlined,
                          enabled: _isEditing,
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Farming Experience - Years',
                          controller: _experienceController,
                          prefixIcon: Icons.timeline_outlined,
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Settings Options
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.settings,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Theme Toggle
                        _buildSettingItem(
                          icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          title: AppLocalizations.of(context)!.darkMode,
                          subtitle: isDarkMode
                              ? AppLocalizations.of(context)!.switchToLightTheme
                              : AppLocalizations.of(context)!.switchToDarkTheme,
                          onTap: () {
                            themeProvider.toggleTheme();
                          },
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              if (value) {
                                themeProvider.setDarkTheme();
                              } else {
                                themeProvider.setLightTheme();
                              }
                            },
                          ),
                        ),

                        // Language Toggle
                        _buildSettingItem(
                          icon: Icons.language,
                          title: AppLocalizations.of(context)!.language,
                          subtitle: 'Choose your preferred language',
                          onTap: () {
                            // Language toggle is handled by the trailing widget
                          },
                          trailing: const LanguageToggle(showLabel: false),
                        ),

                        _buildSettingItem(
                          icon: Icons.notifications_active,
                          title: 'Notifications',
                          subtitle: 'notifications',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.enhancedNotifications,
                            );
                          },
                        ),

                        _buildSettingItem(
                          icon: Icons.photo_camera,
                          title: 'Profile Update',
                          subtitle: 'Update your profile picture and details',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.enhancedProfile,
                            );
                          },
                        ),

                        _buildSettingItem(
                          icon: Icons.security_outlined,
                          title: AppLocalizations.of(context)!.privacy,
                          subtitle: AppLocalizations.of(
                            context,
                          )!.managePrivacySettings,
                          onTap: () {
                            Navigator.pushNamed(context, '/privacy-security');
                          },
                        ),

                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: AppLocalizations.of(context)!.helpSupport,
                          subtitle: AppLocalizations.of(context)!.getHelp,
                          onTap: () {
                            Navigator.pushNamed(context, '/help-support');
                          },
                        ),

                        _buildSettingItem(
                          icon: Icons.info_outline,
                          title: AppLocalizations.of(context)!.about,
                          subtitle: AppLocalizations.of(context)!.appInfo,
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                        ),

                        const SizedBox(height: 8),

                        _buildSettingItem(
                          icon: Icons.logout,
                          title: AppLocalizations.of(context)!.logout,
                          subtitle: 'Sign out of your account',
                          onTap: () {
                            _showLogoutDialog();
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Update Button (only visible when editing)
                  if (_isEditing)
                    CustomButton(
                      text: AppLocalizations.of(context)!.update,
                      onPressed: _isUpdating ? null : _handleUpdate,
                      isLoading: _isUpdating,
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to login screen and clear navigation stack
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

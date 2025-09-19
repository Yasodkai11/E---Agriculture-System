import 'package:flutter/material.dart';
import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const ChangePasswordScreen({super.key, this.arguments});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isPasswordReset = false;

  @override
  void initState() {
    super.initState();
    _isPasswordReset = widget.arguments?['isPasswordReset'] ?? false;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (!_isPasswordReset) {
        // Re-authenticate user before changing password (only for regular password change)
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text.trim(),
        );

        await user.reauthenticateWithCredential(credential);
      }
      
      // Change password
      await user.updatePassword(_newPasswordController.text.trim());

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isPasswordReset 
                ? 'Password reset successfully! You can now login with your new password.' 
                : 'Password changed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        if (_isPasswordReset) {
          // Navigate to login screen for password reset
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          // Just go back for regular password change
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_getErrorMessage(e.toString())}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('wrong-password')) {
      return 'Current password is incorrect';
    } else if (error.contains('weak-password')) {
      return 'New password is too weak. Use at least 6 characters';
    } else if (error.contains('requires-recent-login')) {
      return 'Please log in again to change your password';
    } else {
      return 'Failed to change password. Please try again';
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
        title: Text(
          _isPasswordReset ? 'Set New Password' : 'Change Password',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Current Password (only show if not password reset)
              if (!_isPasswordReset)
                _buildPasswordField(
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  showPassword: _showCurrentPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 20),

              // New Password
              _buildPasswordField(
                label: 'New Password',
                controller: _newPasswordController,
                showPassword: _showNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a new password';
                  }
                  if (value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Confirm Password
              _buildPasswordField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                showPassword: _showConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isPasswordReset ? 'Set New Password' : 'Change Password',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !showPassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: validator,
        ),
      ],
    );
  }
}


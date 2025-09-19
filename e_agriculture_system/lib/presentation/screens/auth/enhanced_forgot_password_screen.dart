import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/enhanced_user_service.dart';

class EnhancedForgotPasswordScreen extends StatefulWidget {
  const EnhancedForgotPasswordScreen({super.key});

  @override
  State<EnhancedForgotPasswordScreen> createState() => _EnhancedForgotPasswordScreenState();
}

class _EnhancedForgotPasswordScreenState extends State<EnhancedForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final EnhancedUserService _userService = EnhancedUserService();

  bool _isLoading = false;
  bool _isEmailSent = false;
  bool _isPhoneSent = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  String _selectedMethod = 'email'; // 'email' or 'phone'
  String? _verificationId;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _successController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _emailController.addListener(_validateEmail);
    _phoneController.addListener(_validatePhone);
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    setState(() {
      _isEmailValid = isValid;
    });
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    // Basic phone validation - you can enhance this based on your requirements
    final isValid = phone.length >= 10 && RegExp(r'^\+?[0-9]+$').hasMatch(phone);
    setState(() {
      _isPhoneValid = isValid;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _successController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedMethod == 'email') {
        await _resetPasswordViaEmail();
      } else {
        await _resetPasswordViaPhone();
      }
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _resetPasswordViaEmail() async {
    try {
      await _userService.sendPasswordResetEmail(_emailController.text.trim());
      
      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });

      _successController.forward();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Password reset email sent successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> _resetPasswordViaPhone() async {
    try {
      final phoneNumber = _phoneController.text.trim();
      // Format phone number if needed
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed
          _handlePhoneVerificationSuccess(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          _handleError(e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isPhoneSent = true;
            _isLoading = false;
          });
          _successController.forward();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'SMS code sent successfully!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  void _handlePhoneVerificationSuccess(PhoneAuthCredential credential) {
    // This would typically be handled in a separate OTP verification screen
    // For now, we'll show a success message
    setState(() {
      _isPhoneSent = true;
      _isLoading = false;
    });
    _successController.forward();
  }

  void _handleError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getErrorMessage(error),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this ${_selectedMethod == 'email' ? 'email address' : 'phone number'}';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address';
    } else if (error.contains('invalid-phone-number')) {
      return 'Please enter a valid phone number';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection';
    } else {
      return 'Failed to send reset ${_selectedMethod == 'email' ? 'email' : 'SMS'}. Please try again';
    }
  }

  void _goBackToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _navigateToOtpVerification() {
    if (_verificationId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.otpAuth,
        arguments: {
          'verificationId': _verificationId,
          'phoneNumber': _phoneController.text.trim(),
          'isPasswordReset': true,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.veryLightGreen,
              AppTheme.paleGreen,
              AppTheme.accentGreen,
              AppTheme.primaryGreen,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Header Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _goBackToLogin,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logo and Title
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                color: AppTheme.primaryGreen,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Choose how you\'d like to reset your password',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Form Section
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Success State
                          if (_isEmailSent || _isPhoneSent)
                            ScaleTransition(
                              scale: _successAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryGreen,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _isEmailSent ? 'Email Sent Successfully!' : 'SMS Sent Successfully!',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isEmailSent 
                                          ? 'Please check your email and follow the instructions to reset your password.'
                                          : 'Please check your phone for the verification code.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textMedium,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        if (_isPhoneSent) ...[
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _navigateToOtpVerification,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryGreen,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Verify Code',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _isEmailSent = false;
                                                _isPhoneSent = false;
                                                _emailController.clear();
                                                _phoneController.clear();
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              side: const BorderSide(color: AppTheme.primaryGreen),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Try Again',
                                              style: TextStyle(color: AppTheme.primaryGreen),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _goBackToLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryGreen,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Back to Login',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Method Selection
                                _buildMethodSelection(),

                                const SizedBox(height: 24),

                                // Input Field
                                if (_selectedMethod == 'email')
                                  _buildEmailField()
                                else
                                  _buildPhoneField(),

                                const SizedBox(height: 30),

                                // Reset Button
                                _buildResetButton(),

                                const SizedBox(height: 24),

                                // Back to Login
                                Center(
                                  child: TextButton(
                                    onPressed: _goBackToLogin,
                                    child: const Text(
                                      'Back to Login',
                                      style: TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Help Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If you don\'t receive the ${_selectedMethod == 'email' ? 'email' : 'SMS'}, check your spam folder or contact support.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact support feature coming soon'),
                                backgroundColor: AppTheme.primaryGreen,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Contact Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMethodOption(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'Reset via email',
                isSelected: _selectedMethod == 'email',
                onTap: () => setState(() => _selectedMethod = 'email'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodOption(
                icon: Icons.phone_outlined,
                title: 'Phone',
                subtitle: 'Reset via SMS',
                isSelected: _selectedMethod == 'phone',
                onTap: () => setState(() => _selectedMethod = 'phone'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            hintStyle: const TextStyle(color: AppTheme.textMedium),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppTheme.textMedium,
            ),
            suffixIcon: _isEmailValid
                ? const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your phone number (e.g., +1234567890)',
            hintStyle: const TextStyle(color: AppTheme.textMedium),
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: AppTheme.textMedium,
            ),
            suffixIcon: _isPhoneValid
                ? const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.mediumGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your phone number';
            }
            if (value!.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Send Reset ${_selectedMethod == 'email' ? 'Email' : 'SMS'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}







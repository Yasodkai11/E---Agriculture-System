import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/app_logo_widget.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _imageController;
  late AnimationController _buttonsController;
  late AnimationController _floatingController;

  late Animation<double> _titleAnimation;
  late Animation<double> _imageAnimation;
  late Animation<Offset> _buttonsAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    ));

    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    ));

    _buttonsAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _imageController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _buttonsController.forward();
    });

    // Floating animation loop
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _buttonsController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive sizes
    final titleFontSize = (screenWidth * 0.09).clamp(28.0, 38.0);
    final subtitleFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    final imageSize = (screenHeight * 0.15).clamp(100.0, 140.0);
    final outerRingSize = imageSize + 20;
    final buttonHeight = (screenHeight * 0.065).clamp(50.0, 55.0);
    final buttonFontSize = (screenWidth * 0.045).clamp(16.0, 18.0);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppTheme.veryLightGreen, // Very light green
              AppTheme.paleGreen, // Light green
              AppTheme.accentGreen, // Medium light green
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Floating background elements
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background decorative circles
                                AnimatedBuilder(
                                  animation: _floatingAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        _floatingAnimation.value * 0.5,
                                        _floatingAnimation.value * 0.3,
                                      ),
                                      child: Container(
                                        width: screenWidth * 0.5,
                                        height: screenWidth * 0.5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryDarkGreen.withOpacity(0.1),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                Column(
                                  children: [
                                    // Animated App Logo
                                    ScaleTransition(
                                      scale: _titleAnimation,
                                      child: AppLogoWidget(
                                        size: imageSize,
                                        showText: true,
                                        showSubtitle: true,
                                        textColor: AppTheme.primaryDarkGreen,
                                        customTitle: 'AGRIGO',
                                        customSubtitle: 'Cultivating Tomorrow\'s Harvest',
                                        isAnimated: true,
                                        animationDuration: const Duration(milliseconds: 1200),
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.05),

                                    // Animated decorative elements around logo
                                    AnimatedBuilder(
                                      animation: _imageAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _imageAnimation.value,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Floating icons around the logo - only show on larger screens
                                              if (screenHeight > 600)
                                                ..._buildFloatingIcons(screenWidth, imageSize),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Animated buttons
                      SlideTransition(
                        position: _buttonsAnimation,
                        child: Column(
                          children: [
                            // Login button
                            _buildAnimatedButton(
                              text: 'Login',
                              icon: Icons.login_rounded,
                              isPrimary: true,
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, AppRoutes.login);
                              },
                              screenWidth: screenWidth,
                              buttonHeight: buttonHeight,
                              buttonFontSize: buttonFontSize,
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Sign up button
                            _buildAnimatedButton(
                              text: 'Create Account',
                              icon: Icons.person_add_rounded,
                              isPrimary: false,
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, AppRoutes.register);
                              },
                              screenWidth: screenWidth,
                              buttonHeight: buttonHeight,
                              buttonFontSize: buttonFontSize,
                            ),

                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
    required double screenWidth,
    required double buttonHeight,
    required double buttonFontSize,
  }) {
    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonHeight / 2),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [AppTheme.primaryDarkGreen, AppTheme.accentGreen],
              )
            : null,
        border: isPrimary
            ? null
            : Border.all(
                color: AppTheme.primaryDarkGreen,
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.primaryDarkGreen,
              size: buttonFontSize * 1.2,
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              text,
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : AppTheme.primaryDarkGreen,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingIcons(double screenWidth, double imageSize) {
    final icons = [
      Icons.eco,
      Icons.agriculture,
      Icons.local_florist,
      Icons.wb_sunny,
    ];

    final iconDistance = imageSize * 0.6; // Distance from center
    final iconSize = (screenWidth * 0.04).clamp(14.0, 16.0);

    return List.generate(icons.length, (index) {
      final angle = (index * 90.0) * (3.14159 / 180);
      return AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              iconDistance * math.cos(angle) + _floatingAnimation.value * 0.3,
              iconDistance * math.sin(angle) + _floatingAnimation.value * 0.2,
            ),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icons[index],
                color: AppTheme.primaryDarkGreen,
                size: iconSize,
              ),
            ),
          );
        },
      );
    });
  }
}


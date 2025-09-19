import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class AppLogoWidget extends StatelessWidget {
  final double? size;
  final bool showText;
  final bool showSubtitle;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final double? iconSize;
  final bool isAnimated;
  final Duration animationDuration;
  final String? customTitle;
  final String? customSubtitle;

  const AppLogoWidget({
    super.key,
    this.size,
    this.showText = true,
    this.showSubtitle = true,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.iconSize,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.customTitle,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = size ?? (screenWidth * 0.25).clamp(80.0, 120.0);
    final textColor = this.textColor ?? AppColors.textPrimary;
    final iconColor = this.iconColor ?? AppColors.primary;
    final fontSize = this.fontSize ?? (screenWidth * 0.06).clamp(18.0, 24.0);
    final iconSize = this.iconSize ?? logoSize * 0.6;

    Widget logoContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: logoSize * 0.9,
                height: logoSize * 0.9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              // Agriculture icon
              Icon(
                Icons.agriculture,
                size: iconSize,
                color: iconColor,
              ),
              // Small wheat icon overlay
              Positioned(
                bottom: logoSize * 0.15,
                right: logoSize * 0.15,
                child: Container(
                  width: logoSize * 0.25,
                  height: logoSize * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                  child: Icon(
                    Icons.eco,
                    size: logoSize * 0.15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        if (showText) ...[
          SizedBox(height: AppDimensions.spacingM),
          
          // App Title
          Text(
            customTitle ?? 'AGRIGO',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
          ),
          
          if (showSubtitle) ...[
            SizedBox(height: AppDimensions.spacingXS),
            
            // Subtitle
            Text(
              customSubtitle ?? 'Smart Agriculture Solutions',
              style: TextStyle(
                fontSize: fontSize * 0.6,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );

    if (isAnimated) {
      return AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        child: logoContent,
      );
    }

    return logoContent;
  }
}

// Compact version for headers and small spaces
class AppLogoCompact extends StatelessWidget {
  final double? size;
  final Color? color;
  final bool showText;

  const AppLogoCompact({
    super.key,
    this.size,
    this.color,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = size ?? (screenWidth * 0.12).clamp(30.0, 50.0);
    final color = this.color ?? AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact icon
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.agriculture,
            size: logoSize * 0.6,
            color: Colors.white,
          ),
        ),
        
        if (showText) ...[
          SizedBox(width: AppDimensions.spacingS),
          
          // Compact text
          Text(
            'AGRIGO',
            style: TextStyle(
              fontSize: logoSize * 0.5,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}

// Loading logo with animation
class AppLogoLoading extends StatefulWidget {
  final double? size;
  final Color? color;

  const AppLogoLoading({
    super.key,
    this.size,
    this.color,
  });

  @override
  State<AppLogoLoading> createState() => _AppLogoLoadingState();
}

class _AppLogoLoadingState extends State<AppLogoLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationController.repeat();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = widget.size ?? (screenWidth * 0.25).clamp(80.0, 120.0);
    final color = widget.color ?? AppColors.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.agriculture,
                size: logoSize * 0.6,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isOutlined;
  final IconData? icon;
  final bool isSmall; // New parameter for smaller buttons

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 44, // Reduced from 50 to 44
    this.borderRadius = 12, // Reduced from 25 to 12 for more modern look
    this.isOutlined = false,
    this.icon,
    this.isSmall = false, // Default to normal size
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSmall ? 36.0 : height;
    final buttonWidth = isSmall ? (width ?? 120) : (width ?? double.infinity);
    
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: backgroundColor ?? AppColors.primary,
                  width: 1.5, // Reduced border width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 12 : 16,
                  vertical: isSmall ? 8 : 12,
                ),
              ),
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColors.buttonPrimary,
                foregroundColor: textColor ?? AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 1, // Reduced elevation for modern look
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 12 : 16,
                  vertical: isSmall ? 8 : 12,
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: isSmall ? 16 : 20,
        width: isSmall ? 16 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined 
                ? (backgroundColor ?? AppColors.primary)
                : (textColor ?? AppColors.textLight),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isSmall ? 16 : 20),
          SizedBox(width: isSmall ? 6 : 8),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: isOutlined 
                  ? (backgroundColor ?? AppColors.primary)
                  : (textColor ?? AppColors.textLight),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: isSmall ? 14 : 16,
        fontWeight: FontWeight.w600,
        color: isOutlined 
            ? (backgroundColor ?? AppColors.primary)
            : (textColor ?? AppColors.textLight),
      ),
    );
  }
}
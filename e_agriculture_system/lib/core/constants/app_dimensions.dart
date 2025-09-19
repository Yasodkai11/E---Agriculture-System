import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 50.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 28.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeDisplay = 28.0;

  // Card Dimensions
  static const double cardElevation = 4.0;
  static const double cardElevationHover = 8.0;
  static const double cardMinHeight = 120.0;
  static const double cardMaxHeight = 200.0;

  // Button Dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightS = 36.0;
  static const double buttonHeightL = 56.0;
  static const double buttonBorderRadius = 12.0;

  // Input Field Dimensions
  static const double inputHeight = 48.0;
  static const double inputBorderRadius = 12.0;
  static const double inputPadding = 16.0;

  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // Bottom Navigation
  static const double bottomNavHeight = 80.0;
  static const double bottomNavIconSize = 24.0;

  // Screen Padding
  static const double screenPadding = 16.0;
  static const double screenPaddingS = 12.0;
  static const double screenPaddingL = 20.0;
  static const double screenPaddingXL = 24.0;

  // Grid Spacing
  static const double gridSpacing = 12.0;
  static const double gridSpacingL = 16.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Helper methods for responsive design
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return baseSpacing * 0.8;
    } else if (screenWidth < tabletBreakpoint) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.2;
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return baseFontSize * 0.9;
    } else if (screenWidth < tabletBreakpoint) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(screenPaddingS);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(screenPadding);
    } else {
      return const EdgeInsets.all(screenPaddingL);
    }
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return 2;
    } else if (screenWidth < tabletBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  static double getCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return 1.1;
    } else if (screenWidth < tabletBreakpoint) {
      return 1.0;
    } else {
      return 0.9;
    }
  }
}

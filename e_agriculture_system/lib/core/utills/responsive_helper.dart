import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double paddingTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double paddingBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double availableHeight(BuildContext context) {
    return screenHeight(context) - paddingTop(context) - paddingBottom(context);
  }

  // Responsive font sizes with much more conservative limits
  static double getResponsiveFontSize(BuildContext context, double percentage) {
    final calculatedSize = screenWidth(context) * percentage;
    
    // Much more conservative limits to prevent overflow
    if (isSmallScreen(context)) {
      return calculatedSize.clamp(10.0, 18.0); // Mobile: 10-18px
    } else if (isMediumScreen(context)) {
      return calculatedSize.clamp(12.0, 20.0); // Tablet: 12-20px
    } else {
      return calculatedSize.clamp(14.0, 22.0); // Desktop: 14-22px (max 22px!)
    }
  }

  // Responsive spacing with much more conservative limits
  static double getResponsiveSpacing(BuildContext context, double percentage) {
    final calculatedSpacing = screenHeight(context) * percentage;
    
    // Much more conservative limits to prevent overflow
    if (isSmallScreen(context)) {
      return calculatedSpacing.clamp(4.0, 12.0); // Mobile: 4-12px
    } else if (isMediumScreen(context)) {
      return calculatedSpacing.clamp(6.0, 16.0); // Tablet: 6-16px
    } else {
      return calculatedSpacing.clamp(8.0, 20.0); // Desktop: 8-20px (max 20px!)
    }
  }

  // Responsive width with much more conservative limits
  static double getResponsiveWidth(BuildContext context, double percentage) {
    final calculatedWidth = screenWidth(context) * percentage;
    
    // Much more conservative limits to prevent overflow
    if (isSmallScreen(context)) {
      return calculatedWidth.clamp(40.0, 150.0); // Mobile: 40-150px
    } else if (isMediumScreen(context)) {
      return calculatedWidth.clamp(60.0, 200.0); // Tablet: 60-200px
    } else {
      return calculatedWidth.clamp(80.0, 250.0); // Desktop: 80-250px (max 250px!)
    }
  }

  // Responsive height with much more conservative limits
  static double getResponsiveHeight(BuildContext context, double percentage) {
    final calculatedHeight = screenHeight(context) * percentage;
    
    // Much more conservative limits to prevent overflow
    if (isSmallScreen(context)) {
      return calculatedHeight.clamp(40.0, 120.0); // Mobile: 40-120px
    } else if (isMediumScreen(context)) {
      return calculatedHeight.clamp(60.0, 150.0); // Tablet: 60-150px
    } else {
      return calculatedHeight.clamp(80.0, 180.0); // Desktop: 80-180px (max 180px!)
    }
  }

  // Check if screen is small (mobile)
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < AppDimensions.mobileBreakpoint;
  }

  // Check if screen is medium (tablet)
  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= AppDimensions.mobileBreakpoint && screenWidth(context) < AppDimensions.tabletBreakpoint;
  }

  // Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= AppDimensions.desktopBreakpoint;
  }

  // Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isSmallScreen(context)) return 2;
    if (isMediumScreen(context)) return 3;
    return 4;
  }

  // Get responsive padding with fixed, reasonable values
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  // Get responsive margin with fixed, reasonable values
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(12.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  // Get responsive border radius with fixed values
  static double getResponsiveBorderRadius(BuildContext context) {
    if (isSmallScreen(context)) {
      return 12.0;
    } else if (isMediumScreen(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  // Get responsive icon size with fixed values
  static double getResponsiveIconSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 20.0;
    } else if (isMediumScreen(context)) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  // Get responsive button height with fixed values
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 48.0;
    } else if (isMediumScreen(context)) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  // Get responsive image size with much more conservative limits
  static double getResponsiveImageSize(BuildContext context, double percentage) {
    final calculatedSize = screenHeight(context) * percentage;
    
    // Much more conservative limits for images
    if (isSmallScreen(context)) {
      return calculatedSize.clamp(50.0, 100.0); // Mobile: 50-100px
    } else if (isMediumScreen(context)) {
      return calculatedSize.clamp(60.0, 120.0); // Tablet: 60-120px
    } else {
      return calculatedSize.clamp(70.0, 140.0); // Desktop: 70-140px (max 140px!)
    }
  }

  // Get responsive card aspect ratio with better proportions
  static double getResponsiveCardAspectRatio(BuildContext context) {
    if (isSmallScreen(context)) {
      return 0.9; // Slightly taller cards for mobile to prevent overflow
    } else if (isMediumScreen(context)) {
      return 1.0; // Square cards for tablet
    } else {
      return 1.1; // Slightly wider for desktop
    }
  }

  // Get responsive card height constraints with fixed, reasonable values
  static double getResponsiveCardHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 140.0; // Fixed height for mobile to prevent overflow
    } else if (isMediumScreen(context)) {
      return 150.0;
    } else {
      return 160.0;
    }
  }

  // New method: Get compact spacing for better desktop experience
  static double getCompactSpacing(BuildContext context, double percentage) {
    final calculatedSpacing = screenHeight(context) * percentage;
    
    // Very conservative limits for desktop
    if (isSmallScreen(context)) {
      return calculatedSpacing.clamp(4.0, 16.0);
    } else if (isMediumScreen(context)) {
      return calculatedSpacing.clamp(6.0, 20.0);
    } else {
      return calculatedSpacing.clamp(8.0, 24.0); // Desktop: max 24px
    }
  }

  // New method: Get compact font size for better desktop experience
  static double getCompactFontSize(BuildContext context, double percentage) {
    final calculatedSize = screenWidth(context) * percentage;
    
    // Very conservative limits for desktop
    if (isSmallScreen(context)) {
      return calculatedSize.clamp(10.0, 16.0);
    } else if (isMediumScreen(context)) {
      return calculatedSize.clamp(12.0, 18.0);
    } else {
      return calculatedSize.clamp(14.0, 20.0); // Desktop: max 20px
    }
  }

  // New method: Get safe spacing that won't cause overflow
  static double getSafeSpacing(BuildContext context, double percentage) {
    final calculatedSpacing = screenHeight(context) * percentage;
    
    // Very safe limits to prevent any overflow
    if (isSmallScreen(context)) {
      return calculatedSpacing.clamp(2.0, 8.0);
    } else if (isMediumScreen(context)) {
      return calculatedSpacing.clamp(4.0, 12.0);
    } else {
      return calculatedSpacing.clamp(6.0, 16.0); // Desktop: max 16px
    }
  }
}

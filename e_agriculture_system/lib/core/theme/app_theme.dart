import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  // Modern Agriculture Color Palette - Enhanced
  static const Color primaryDarkGreen = Color(0xFF1B5E20); // Rich deep green
  static const Color primaryGreen = Color(0xFF2E7D32); // Vibrant main green
  static const Color mediumGreen = Color(0xFF4CAF50); // Fresh medium green
  static const Color lightGreen = Color(0xFF81C784); // Gentle light green
  static const Color accentGreen = Color(0xFFA5D6A7); // Soft accent green
  static const Color paleGreen = Color(0xFFC8E6C9); // Very pale green
  static const Color veryLightGreen = Color(
    0xFFF1F8E9,
  ); // Subtle background green
  static const Color white = Color(0xFFFFFFFF); // Pure white
  static const Color offWhite = Color(0xFFFAFAFA); // Off white
  static const Color lightGrey = Color(0xFFF5F5F5); // Clean light grey
  static const Color mediumGrey = Color(0xFFE0E0E0); // Medium grey
  static const Color darkGrey = Color(0xFF424242); // Dark grey
  static const Color textDark = Color(0xFF212121); // Rich dark text
  static const Color textMedium = Color(0xFF757575); // Medium text
  static const Color textLight = Color(0xFFBDBDBD); // Light text
  static const Color errorRed = Color(0xFFD32F2F); // Clear error red
  static const Color successGreen = Color(0xFF388E3C); // Success green
  static const Color warningOrange = Color(0xFFF57C00); // Warning orange
  static const Color infoBlue = Color(0xFF1976D2); // Info blue

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: veryLightGreen,
      primaryColor: primaryGreen,
      primarySwatch: Colors.green,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: white,
        surfaceContainerHighest: veryLightGreen,
        error: errorRed,
        onPrimary: white,
        onSecondary: textDark,
        onSurface: textDark,
        onSurfaceVariant: textMedium,
        onError: white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: AppDimensions.fontSizeXXL,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: white),
        toolbarHeight: AppDimensions.appBarHeight,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textDark),
        bodyMedium: TextStyle(fontSize: 14, color: textDark),
        bodySmall: TextStyle(fontSize: 12, color: textMedium),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: mediumGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.inputPadding,
          vertical: AppDimensions.inputPadding,
        ),
        hintStyle: const TextStyle(color: textLight),
        labelStyle: const TextStyle(color: textMedium),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          elevation: 2,
          shadowColor: primaryGreen.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXXL,
            vertical: AppDimensions.spacingL,
          ),
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          textStyle: const TextStyle(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(
            fontSize: AppDimensions.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXXL,
            vertical: AppDimensions.spacingL,
          ),
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          textStyle: const TextStyle(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
        ),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusL),
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppDimensions.fontSizeS,
        ),
        unselectedLabelStyle: TextStyle(fontSize: AppDimensions.fontSizeS),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGrey,
        selectedColor: primaryGreen,
        disabledColor: mediumGrey,
        labelStyle: const TextStyle(color: textDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: mediumGrey,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: AppDimensions.iconM,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: lightGrey,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return mediumGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen.withOpacity(0.5);
          }
          return mediumGrey.withOpacity(0.5);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return mediumGrey;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: lightGrey,
        thumbColor: primaryGreen,
        overlayColor: primaryGreen.withOpacity(0.2),
      ),
    );
  }

  // Dark Theme (Optional - for future use)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: lightGreen,
      brightness: Brightness.dark,
      // Add dark theme colors here if needed
    );
  }
}

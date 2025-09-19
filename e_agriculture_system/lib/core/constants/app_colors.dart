import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Subtle Agriculture Theme
  static const Color primary = Color(0xFF4A7C59); // Muted fresh green
  static const Color primaryLight = Color(0xFF8FBC8F); // Softer natural green
  static const Color primaryDark = Color(0xFF2D5A3D); // Softer deep green
  static const Color accent = Color(0xFFD4A574); // Warm muted amber (harvest)
  
  // Secondary Colors - Earth Tones
  static const Color secondary = Color(0xFF6B8E6B); // Muted sage green
  static const Color secondaryLight = Color(0xFFA8D5A8); // Soft mint green
  static const Color earthBrown = Color(0xFFA68B5B); // Muted soil brown
  static const Color skyBlue = Color(0xFF7FB3D3); // Soft sky blue
  
  // Background Colors - Natural Subtle Palette
  static const Color background = Color(0xFFE8F5E8); // Very subtle green background
  static const Color cardBackground = Colors.white;
  static const Color surfaceBackground = Color(0xFFF8F9FA); // Soft cream white
  static const Color overlayBackground = Color(0xFF495057);
  static const Color gradientStart = Color(0xFF8FBC8F); // Softer gradient start
  static const Color gradientEnd = Color(0xFF4A7C59); // Softer gradient end
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50); // Softer dark text
  static const Color textSecondary = Color(0xFF6C757D); // Muted secondary text
  static const Color textLight = Colors.white;
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textAccent = Color(0xFF4A7C59); // Muted green accent text
  
  // Status Colors - Agriculture Themed
  static const Color success = Color(0xFF27AE60); // Softer healthy plant green
  static const Color error = Color(0xFFE74C3C); // Softer alert red
  static const Color warning = Color(0xFFF39C12); // Softer harvest orange
  static const Color info = Color(0xFF3498DB); // Softer water blue
  static const Color growth = Color(0xFF6B8E6B); // Muted growth indicator
  
  // Border Colors
  static const Color border = Color(0xFFE9ECEF); // Softer border
  static const Color borderFocus = Color(0xFF4A7C59); // Muted primary green focus
  static const Color borderLight = Color(0xFFF8F9FA); // Very light border
  
  // Special Agriculture Colors
  static const Color verified = Color(0xFF8FBC8F); // Softer verified green
  static const Color shadow = Color(0x1A4A7C59); // Muted green-tinted shadow
  static const Color harvest = Color(0xFFD4A574); // Muted harvest gold
  static const Color soil = Color(0xFFA68B5B); // Muted soil
  static const Color water = Color(0xFF7FB3D3); // Softer water blue
  static const Color seed = Color(0xFFE9DCC9); // Softer seed beige
  
  // Gradient Colors for modern cards (Subtle and modern)
  static const List<Color> cardGradient = [
    Color(0xFF8FBC8F),
    Color(0xFF4A7C59),
  ];
  
  // Background gradient (Subtle and modern)
  static const List<Color> backgroundGradient = [
    Color(0xFF8FBC8F),
    Color(0xFF4A7C59),
    Color(0xFF2D5A3D),
  ];
  
  static const List<Color> harvestGradient = [
    Color(0xFFD4A574),
    Color(0xFFB8946B),
  ];
  
  static const List<Color> skyGradient = [
    Color(0xFFA8D5A8),
    Color(0xFF4A7C59),
  ];
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFF4A7C59);
  static const Color buttonSecondary = Color(0xFFD4A574);
  static const Color buttonSuccess = Color(0xFF8FBC8F);
  static const Color buttonOutline = Color(0xFF6B8E6B);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextHint = Color(0xFF808080);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkBorderLight = Color(0xFF2D2D2D);
  static const Color darkShadow = Color(0x1A000000);
}

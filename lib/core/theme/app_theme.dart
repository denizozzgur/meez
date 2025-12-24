import 'package:flutter/material.dart';

class AppColors {
  // Modern Slate Dark Theme
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  
  // Vibrant Accents
  static const Color accentBlue = Color(0xFF38BDF8); // Sky 400
  static const Color accentGreen = Color(0xFF4ADE80); // Green 400
  static const Color accentPurple = Color(0xFFC084FC); // Purple 400 (retained but lighter)
  
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
}

class GlassTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accentBlue,
      // Removed custom fontFamily - use system default
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentGreen,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}


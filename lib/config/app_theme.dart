import 'package:flutter/material.dart';

class AppTheme {
  // Noter-inspired minimal color palette
  static const Color primary = Color(0xFF1A1A1A); // Deep black
  static const Color secondary = Color(0xFF6B7280); // Muted gray
  static const Color accent = Color(0xFF10B981); // Subtle green accent
  static const Color background = Color(0xFFFAFAFA); // Off-white background
  static const Color cardColor = Color(0xFFFFFFFF); // Pure white cards
  static const Color textPrimary = Color(0xFF111827); // Rich black text
  static const Color textSecondary = Color(0xFF6B7280); // Muted text
  static const Color border = Color(0xFFE5E7EB); // Light border

  static ThemeData get noterTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: cardColor,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),

      // Clean typography matching Noter
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -1.2,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.4,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.7,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
      ),

      // Minimal card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Clean app bar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Minimal buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Clean input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

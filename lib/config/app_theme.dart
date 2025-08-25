import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color lightPrimary = Color(0xFF1A1A1A);
  static const Color lightSecondary = Color(0xFF6B7280);
  static const Color lightAccent = Color(0xFF10B981);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark theme colors inspired by the reference image
  static const Color darkPrimary = Color(0xFFFFFFFF); // White for primary text
  static const Color darkSecondary = Color(0xFFB3B3B3); // Light gray for secondary text
  static const Color darkAccent = Color(0xFFFFFFFF); // White for accents and buttons
  static const Color darkBackground = Color(0xFF000000); // Pure black background
  static const Color darkCard = Color(0xFF1A1A1A); // Very dark gray for cards
  static const Color darkText = Color(0xFFFFFFFF); // Pure white for body text
  static const Color darkTextSecondary = Color(0xFFB3B3B3); // Light gray for subtitles
  static const Color darkBorder = Color(0xFF2A2A2A); // Subtle border for cards

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,

    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      surface: lightCard,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightText,
      onBackground: lightText,
    ),

    scaffoldBackgroundColor: lightBackground,
    dividerColor: lightBorder,

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: lightText,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: lightText,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: lightText,
        letterSpacing: -0.4,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightText,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightText,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: lightText,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: lightText,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: lightText,
        height: 1.7,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightTextSecondary,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: lightTextSecondary,
        height: 1.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightText,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightPrimary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,

    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkAccent,
      surface: darkCard,
      background: darkBackground,
      onPrimary: darkBackground, // Black text on white buttons
      onSecondary: darkBackground,
      onSurface: darkText,
      onBackground: darkText,
    ),

    scaffoldBackgroundColor: darkBackground,
    dividerColor: darkBorder,

    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: darkText, letterSpacing: -1.2, height: 1.1),
      displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: darkText, letterSpacing: -0.8, height: 1.2),
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: darkText, letterSpacing: -0.4, height: 1.3),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: darkText, height: 1.3),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkText, height: 1.4),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: darkText, height: 1.4),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: darkText, height: 1.5),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: darkText, height: 1.7),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextSecondary, height: 1.6),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: darkTextSecondary, height: 1.5),
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: darkBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground, // Black AppBar
      foregroundColor: darkText, // White text/icons on AppBar
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
    ),

    // This style matches the high-contrast "Try for free" button in the image
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // White button background
        foregroundColor: Colors.black, // Black button text
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: darkBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: darkBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: darkAccent, width: 2)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

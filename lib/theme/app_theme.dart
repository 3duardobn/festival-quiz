import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Quiz Palette
  static const Color trueGreen = Color(0xFF10B981);
  static const Color trueGreenDark = Color(0xFF059669);
  static const Color trueGreenBg = Color(0xFFE8F5E9);

  static const Color falseRed = Color(0xFFF43F5E);
  static const Color falseRedDark = Color(0xFFE11D48);
  static const Color falseRedBg = Color(0xFFFFEBEE);

  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color secondaryCyan = Color(0xFF06B6D4);
  static const Color amberStreak = Color(0xFFF59E0B);

  // Player distinct colors for simultaneous multiplayer
  static const List<Color> playerColors = [
    Color(0xFF3B82F6), // Player 1: Royal Blue
    Color(0xFFEC4899), // Player 2: Rose Pink
    Color(0xFFF59E0B), // Player 3: Vibrant Amber
    Color(0xFF8B5CF6), // Player 4: Purple Iris
  ];

  static const List<IconData> playerIcons = [
    Icons.face_rounded,
    Icons.sentiment_very_satisfied_rounded,
    Icons.star_rounded,
    Icons.bolt_rounded,
  ];

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      brightness: Brightness.light,
      primary: primaryIndigo,
      secondary: secondaryCyan,
      surface: const Color(0xFFF8FAFC),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF1F5F9),
      surfaceContainer: const Color(0xFFE2E8F0),
      surfaceContainerHigh: const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFF38BDF8),
      surface: const Color(0xFF0F172A),
      surfaceContainerLowest: const Color(0xFF020617),
      surfaceContainerLow: const Color(0xFF1E293B),
      surfaceContainer: const Color(0xFF334155),
      surfaceContainerHigh: const Color(0xFF475569),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        color: const Color(0xFF1E293B),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData annaTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AnnaColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AnnaColors.bg,
      surfaceContainer: AnnaColors.surface,
      primary: AnnaColors.gold,
      secondary: AnnaColors.goldSoft,
      onPrimary: AnnaColors.bg,
      error: AnnaColors.red,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AnnaColors.text,
      displayColor: AnnaColors.text,
    ),
    iconTheme: const IconThemeData(color: AnnaColors.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AnnaColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AnnaColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AnnaColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AnnaColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AnnaColors.gold),
      ),
      hintStyle: const TextStyle(color: AnnaColors.textFaint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AnnaColors.gold,
        foregroundColor: AnnaColors.bg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

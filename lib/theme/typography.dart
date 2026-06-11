import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Reusable text styles. Instrument Serif for headlines and warm moments,
/// JetBrains Mono for technical/eyebrow labels, Inter for body.
class AnnaText {
  AnnaText._();

  // Headlines — Instrument Serif
  static TextStyle greeting = GoogleFonts.instrumentSerif(
    fontSize: 38,
    height: 1.0,
    letterSpacing: -0.5,
    color: AnnaColors.text,
  );

  static TextStyle greetingAccent = GoogleFonts.instrumentSerif(
    fontSize: 38,
    height: 1.0,
    letterSpacing: -0.5,
    fontStyle: FontStyle.italic,
    color: AnnaColors.gold,
    shadows: [Shadow(color: AnnaColors.goldGlow, blurRadius: 20)],
  );

  static TextStyle sectionTitle = GoogleFonts.instrumentSerif(
    fontSize: 28,
    height: 1.1,
    color: AnnaColors.text,
  );

  static TextStyle callerName = GoogleFonts.instrumentSerif(
    fontSize: 44,
    color: AnnaColors.text,
    height: 1.0,
  );

  // Body — Inter
  static TextStyle reminderTitle = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AnnaColors.text,
    height: 1.2,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: AnnaColors.text,
    height: 1.4,
  );

  static TextStyle bodySoft = GoogleFonts.inter(
    fontSize: 13,
    color: AnnaColors.textSoft,
    height: 1.4,
  );

  // Italic accents — Instrument Serif italic
  static TextStyle italicCaption = GoogleFonts.instrumentSerif(
    fontSize: 15,
    fontStyle: FontStyle.italic,
    color: AnnaColors.textSoft,
    height: 1.4,
  );

  // Time display
  static TextStyle timeNum = GoogleFonts.instrumentSerif(
    fontSize: 22,
    height: 1.0,
    color: AnnaColors.text,
  );

  // Eyebrows / labels — JetBrains Mono
  static TextStyle eyebrow = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    letterSpacing: 2.0,
    color: AnnaColors.textSoft,
    fontWeight: FontWeight.w500,
  );

  static TextStyle eyebrowGold = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    letterSpacing: 2.0,
    color: AnnaColors.gold,
    fontWeight: FontWeight.w500,
  );

  static TextStyle meta = GoogleFonts.jetBrainsMono(
    fontSize: 9,
    letterSpacing: 1.4,
    color: AnnaColors.textSoft,
    fontWeight: FontWeight.w500,
  );
}
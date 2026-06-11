import 'package:flutter/material.dart';

/// Anna's color palette — deep dark with warm gold accents to match the logo.
class AnnaColors {
  AnnaColors._();

  // Surfaces
  static const bg = Color(0xFF0A0A0C);
  static const surface = Color(0xFF15151A);
  static const surface2 = Color(0xFF1C1C22);
  static const surface3 = Color(0xFF25252D);
  static const line = Color(0xFF2A2A32);

  // Text
  static const text = Color(0xFFF5F0E6);
  static const textSoft = Color(0xFF8A8A95);
  static const textFaint = Color(0xFF4A4A52);

  // Brand gold (from your logo)
  static const gold = Color(0xFFF5B942);
  static const goldSoft = Color(0xFFFBD388);
  static const goldDeep = Color(0xFFC89020);
  static Color goldGlow = const Color(0xFFF5B942).withOpacity(0.4);

  // System
  static const red = Color(0xFFEF4444);
  static const green = Color(0xFF22C55E);
}

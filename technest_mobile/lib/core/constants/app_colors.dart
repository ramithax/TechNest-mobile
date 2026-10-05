import 'package:flutter/material.dart';

class AppColors {
  // ── Primary accent ── Deep Dark Navy / Tech Blue
  static const primary = Color(0xFF1E3A8A); // rich dark navy blue
  static const primaryLight = Color(0xFF2563EB); // cobalt blue
  static const primaryDark = Color(0xFF0F172A); // deep navy slate
  static const primaryMuted = Color(0xFFEFF6FF); // light blue tint

  // ── Dark / Navy ── For strong elements, dark surfaces
  static const dark = Color(0xFF111827); // near-black charcoal
  static const darkSecondary = Color(0xFF1F2937); // dark gray
  static const darkTertiary = Color(0xFF374151); // medium-dark gray
  static const darkCard = Color(0xFF1F2937); // card in dark contexts
  static const backgroundDark = dark;
  static const cardDark = darkCard;

  // ── Light / Clean backgrounds ──
  static const background = Color(0xFFF8F9FB); // very light cool gray
  static const surface = Colors.white;
  static const surfaceLight = Color(0xFFF1F5F9); // light neutral
  static const backgroundLight = background;
  static const cardLight = surface;

  // ── Cool neutral ── for secondary UI elements
  static const coolGray = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE2E8F0); // subtle borders
  static const chipBg = Color(0xFFF1F5F9); // chips, pills background

  // ── Text colors ──
  static const textPrimary = Color(0xFF111827); // near-black
  static const textSecondary = Color(0xFF6B7280); // cool gray
  static const textMuted = Color(0xFF9CA3AF); // lighter gray

  // ── Borders ──
  static const border = Color(0xFFE2E8F0); // subtle cool border
  static const borderLight = Color(0xFFF1F5F9); // very subtle

  // ── Status colors ──
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const info = Color(0xFF2563EB);

  // ── Utilities ──
  static const white = Colors.white;
  static const black = Colors.black;

  // ── Legacy aliases (for smooth migration) ──
  // These map old brown/gold usages → new tech equivalents
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
}

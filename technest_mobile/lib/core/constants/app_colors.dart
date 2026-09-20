import 'package:flutter/material.dart';

class AppColors {
  // Primary - Gold/Amber accent
  static const primary = Color(0xFFB08A4A);
  static const primaryLight = Color(0xFFD4A85A);
  static const primaryDark = Color(0xFF8F6D38);
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFB08A4A), Color(0xFFD4A85A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark backgrounds
  static const dark = Color(0xFF0F1923);
  static const darkSecondary = Color(0xFF18202A);
  static const darkTertiary = Color(0xFF1E2A36);
  static const darkCard = Color(0xFF1A2634);

  // Light backgrounds
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const surfaceLight = Color(0xFFFAFAFA);

  // Text colors
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Borders
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF0F0F0);

  // Status colors
  static const success = Color(0xFF22A06B);
  static const error = Color(0xFFD64545);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Utilities
  static const white = Colors.white;
  static const black = Colors.black;

  // Glass effect
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
}

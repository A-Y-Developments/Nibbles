import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF4CAF82);
  static const Color primaryLight = Color(0xFF80E0AB);
  static const Color primaryDark = Color(0xFF2E7D5A);

  // Secondary / accent
  static const Color secondary = Color(0xFFFF8C42);
  static const Color secondaryLight = Color(0xFFFFB47A);

  // Backgrounds
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F4F3);

  // Text
  static const Color text = Color(0xFF1A1A2E);
  static const Color subtext = Color(0xFF6B7280);
  static const Color hint = Color(0xFFB0B8C1);

  // Semantic
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);

  // Misc
  static const Color divider = Color(0xFFE5E7EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1A1A2E);
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color onError = Color(0xFFFFFFFF);

  // Allergen chip states
  static const Color allergenSafe = Color(0xFF38A169);
  static const Color allergenFlagged = Color(0xFFE53E3E);
  static const Color allergenInProgress = Color(0xFFD69E2E);
  static const Color allergenNotStarted = Color(0xFFB0B8C1);
}

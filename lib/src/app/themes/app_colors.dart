import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF3D5236);
  static const Color primaryLight = Color(0xFF5C7852);
  static const Color primaryDark = Color(0xFF67835B);

  // Secondary / accent
  static const Color secondary = Color(0xFFF8A175);
  static const Color secondaryLight = Color(0xFFFDF2EC);

  // Backgrounds
  static const Color background = Color(0xFFFFFDF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F4F3);

  // Text
  static const Color text = Color(0xFF2C2C2C);
  static const Color subtext = Color(0xFF6B7280);
  static const Color hint = Color(0xFFB0B8C1);

  // Semantic
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);

  // Misc
  static const Color divider = Color(0xFFEAEAEA);
  static const Color onPrimary = Color(0xFFFFFDF8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF2C2C2C);
  static const Color onSurface = Color(0xFF2C2C2C);
  static const Color onError = Color(0xFFFFFFFF);

  // Allergen chip states
  static const Color allergenSafe = Color(0xFF38A169);
  static const Color allergenFlagged = Color(0xFFE53E3E);
  static const Color allergenInProgress = Color(0xFFD69E2E);
  static const Color allergenNotStarted = Color(0xFFB0B8C1);

  // ── New brand tokens — sage / butter / coral palette ──────────
  // Sage green
  static const Color greenDeep = Color(0xFF3D5236);
  static const Color green = Color(0xFF5C7852);
  static const Color greenSoft = Color(0xFF67835B);
  static const Color greenTint = Color(0xFFE8EEE5);

  // Butter yellow
  static const Color butter = Color(0xFFEAEC8C);
  static const Color butterSoft = Color(0xFFFFFCD5);
  static const Color butterDark = Color(0xFFC8CA5A);

  // Coral / peach
  static const Color coral = Color(0xFFF8A175);
  static const Color coralSoft = Color(0xFFFDF2EC);
  static const Color coralDeep = Color(0xFFC97850);

  // Cream surface base
  static const Color cream = Color(0xFFFFFDF8);

  // Warm red — destructive
  static const Color destructive = Color(0xFF851E1E);
  static const Color destructiveSoft = Color(0xFFFFE8E8);

  // ── Semantic tokens ───────────────────────────────────────────
  static const Color fgStrong = Color(0xFF2C2C2C);
  static const Color fgDefault = Color(0xFF2D1F17);
  static const Color fgMuted = Color(0xFF6B7280);
  static const Color fgFaint = Color(0xFF969696);
  static const Color onGreen = Color(0xFFFFFDF8);
  static const Color borderSoft = Color(0xFFEAEAEA);
  static const Color borderMuted = Color(0xFFD9D9D9);
  static const Color bgCardTint = Color(0xFFFFFCD5);
  static const Color bgInput = Color(0xFFF2F2F2);

  // ── Tan / wheat scale ─────────────────────────────────────────
  static const Color tanBase = Color(0xFFFFE0A9);
  static const Color tan10 = Color(0xFFFFF9EE);
  static const Color tan20 = Color(0xFFFFF5E2);
  static const Color tan30 = Color(0xFFFFF0D4);
  static const Color tan40 = Color(0xFFFFEAC6);
  static const Color tan50 = Color(0xFFFFE5B7);
  static const Color tan60 = Color(0xFFD5BB8D);
  static const Color tan70 = Color(0xFFAA9571);
  static const Color tan80 = Color(0xFF807055);
  static const Color tan90 = Color(0xFF554B38);
  static const Color tan100 = Color(0xFF332D22);

  // ── Orange scale ──────────────────────────────────────────────
  static const Color orangeBase = Color(0xFFFF6D0F);
  static const Color orange10 = Color(0xFFFFE2CF);
  static const Color orange20 = Color(0xFFFFCEAF);
  static const Color orange30 = Color(0xFFFFB687);
  static const Color orange40 = Color(0xFFFF9E5F);
  static const Color orange50 = Color(0xFFFF8537);
  static const Color orange60 = Color(0xFFD55B0D);
  static const Color orange70 = Color(0xFFAA490A);
  static const Color orange80 = Color(0xFF803708);
  static const Color orange90 = Color(0xFF552405);
  static const Color orange100 = Color(0xFF331603);
}

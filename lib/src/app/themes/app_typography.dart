import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

abstract final class AppTypography {
  // Per NIB-120: Parkinsans for display/title/headline slots; Figtree for
  // body/label/caption slots (bundled via google_fonts). Size/weight/line-
  // height ramp is unchanged from NIB-46 — only the family is swapped.
  // GoogleFonts.figtree() returns a non-const TextStyle, so anything on the
  // Figtree side cannot be const (textTheme, the body helpers below).
  static final TextTheme textTheme = TextTheme(
    // displayLarge/displayMedium — large Parkinsans bold (no feature usage).
    displayLarge: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 57,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.25,
    ),
    displayMedium: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 45,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
    ),
    // title1 — 28/700 h1.214 ls-0.01em (→ -0.28 logical px).
    displaySmall: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.28,
    ),
    headlineLarge: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.28,
    ),
    headlineMedium: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.28,
    ),
    // title2 — 22/700 h1.273.
    headlineSmall: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.273,
      color: AppColors.text,
    ),
    titleLarge: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.273,
      color: AppColors.text,
    ),
    // title3 — 20/700 h1.30.
    titleMedium: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.30,
      color: AppColors.text,
    ),
    // headline — 17/600 h1.294 (Parkinsans display headline slot).
    titleSmall: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.294,
      color: AppColors.text,
    ),
    // body — 15/400 h1.467.
    bodyLarge: GoogleFonts.figtree(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.467,
      color: AppColors.text,
    ),
    // callout — 14/400 h1.50.
    bodyMedium: GoogleFonts.figtree(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.50,
      color: AppColors.text,
    ),
    // caption — 12/400 h1.333.
    bodySmall: GoogleFonts.figtree(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.333,
      color: AppColors.subtext,
    ),
    // label (headline metrics 17/600 h1.294) — Figtree label slot.
    labelLarge: GoogleFonts.figtree(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.294,
      color: AppColors.text,
    ),
    // subhead — 13/600 h1.538. Parkinsans display family per kit (--font-display).
    labelMedium: const TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.538,
      color: AppColors.text,
    ),
    // overline — 10/700 h1.20 ls0.6 (uppercase applied at widget level).
    labelSmall: GoogleFonts.figtree(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.20,
      color: AppColors.subtext,
      letterSpacing: 0.6,
    ),
  );

  // brandWordmark — logo lockup wordmark (kit: 800 42px/1 Parkinsans,
  // green-deep, ls -0.02em). letterSpacing in logical px = 42 * -0.02 = -0.84
  // (same em→px convention as displaySmall's -0.28). height 1.0 per kit '/1'.
  static const TextStyle brandWordmark = TextStyle(
    fontFamily: FontFamily.parkinsans,
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 1,
    color: AppColors.greenDeep,
    letterSpacing: -0.84,
  );

  // sectionTitle — title3 (20/700 h1.30). Parkinsans display slot.
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: FontFamily.parkinsans,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.30,
    color: AppColors.text,
  );

  // caption — 12/400 h1.333. Figtree body helper.
  static final TextStyle caption = GoogleFonts.figtree(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.333,
    color: AppColors.subtext,
  );

  // button ~ headline (15/700 h1.294). Figtree body helper.
  static final TextStyle button = GoogleFonts.figtree(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.294,
    color: AppColors.onPrimary,
  );

  // body-bold — 15/700 h1.467 (ramp completeness; no slot mapping). Figtree.
  static final TextStyle bodyBold = GoogleFonts.figtree(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.467,
    color: AppColors.text,
  );
}

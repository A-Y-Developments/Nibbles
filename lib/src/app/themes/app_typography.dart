import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    // displayLarge/displayMedium — large Parkinsans bold (no feature usage).
    displayLarge: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 57,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 45,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
    ),
    // title1 — 28/700 h1.214 ls-0.01em (→ -0.28 logical px).
    displaySmall: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.28,
    ),
    headlineLarge: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.28,
    ),
    headlineMedium: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.214,
      color: AppColors.text,
      letterSpacing: -0.28,
    ),
    // title2 — 22/700 h1.273.
    headlineSmall: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.273,
      color: AppColors.text,
    ),
    titleLarge: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.273,
      color: AppColors.text,
    ),
    // title3 — 20/700 h1.30.
    titleMedium: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.30,
      color: AppColors.text,
    ),
    // headline — 17/600 h1.294.
    titleSmall: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.294,
      color: AppColors.text,
    ),
    // body — 15/400 h1.467.
    bodyLarge: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.467,
      color: AppColors.text,
    ),
    // callout — 14/400 h1.50.
    bodyMedium: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.50,
      color: AppColors.text,
    ),
    // caption — 12/400 h1.333.
    bodySmall: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.333,
      color: AppColors.subtext,
    ),
    // headline — 17/600 h1.294.
    labelLarge: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.294,
      color: AppColors.text,
    ),
    // subhead — 13/600 h1.538.
    labelMedium: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.538,
      color: AppColors.text,
    ),
    // overline — 10/700 h1.20 ls0.6 (uppercase applied at widget level).
    labelSmall: TextStyle(
      fontFamily: FontFamily.parkinsans,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.20,
      color: AppColors.subtext,
      letterSpacing: 0.6,
    ),
  );

  // sectionTitle — title3 (20/700 h1.30).
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: FontFamily.parkinsans,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.30,
    color: AppColors.text,
  );

  // caption — 12/400 h1.333.
  static const TextStyle caption = TextStyle(
    fontFamily: FontFamily.parkinsans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.333,
    color: AppColors.subtext,
  );

  // button ~ headline (15/700 h1.294).
  static const TextStyle button = TextStyle(
    fontFamily: FontFamily.parkinsans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.294,
    color: AppColors.onPrimary,
  );

  // body-bold — 15/700 h1.467 (ramp completeness; no slot mapping).
  static const TextStyle bodyBold = TextStyle(
    fontFamily: FontFamily.parkinsans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.467,
    color: AppColors.text,
  );
}

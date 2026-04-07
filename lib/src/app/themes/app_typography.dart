import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.text,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.text,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.text,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.subtext,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.subtext,
      letterSpacing: 0.5,
    ),
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.subtext,
    letterSpacing: 0.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
    letterSpacing: 0.5,
  );
}

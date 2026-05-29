import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

export 'package:nibbles/src/app/themes/app_colors.dart';
export 'package:nibbles/src/app/themes/app_sizes.dart';
export 'package:nibbles/src/app/themes/app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // greenDeep #3D5236 brand primary; cream foreground on it.
      primary: AppColors.greenDeep,
      onPrimary: AppColors.cream,
      primaryContainer: AppColors.green,
      onPrimaryContainer: AppColors.cream,
      secondary: AppColors.coral,
      onSecondary: AppColors.cream,
      secondaryContainer: AppColors.coralSoft,
      onSecondaryContainer: AppColors.fgStrong,
      // Maroon #851E1E is destructive-button intent; validation borders use
      // AppColors.error (#E53E3E) explicitly in inputDecorationTheme.
      error: AppColors.destructive,
      onError: AppColors.cream,
      surface: AppColors.surface,
      onSurface: AppColors.fgStrong,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.fgMuted,
      outline: AppColors.borderSoft,
      outlineVariant: AppColors.borderMuted,
    );

    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: FontFamily.parkinsans,
      scaffoldBackgroundColor: AppColors.cream,
      dividerColor: AppColors.borderSoft,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: AppSizes.dividerThickness,
        space: 0,
      ),
      // Most screens use the custom AppHeader (later ticket); this AppBarTheme
      // is a sane cream/transparent-tint fallback.
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: AppColors.borderSoft,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: AppColors.fgStrong,
          size: AppSizes.iconMd,
        ),
      ),
      // Canonical nav is the custom AppBottomNav (later ticket); this block is
      // a fallback only — retuned to the new palette.
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.greenDeep,
        unselectedItemColor: AppColors.fgFaint,
        selectedLabelStyle: TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          color: AppColors.greenDeep,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          color: AppColors.fgFaint,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      // Primary CTA — greenDeep/cream pill, no per-call override needed.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenDeep,
          foregroundColor: AppColors.cream,
          disabledBackgroundColor: AppColors.borderMuted,
          disabledForegroundColor: AppColors.cream,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenDeep,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          side: const BorderSide(color: AppColors.greenDeep, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: AppTypography.button.copyWith(color: AppColors.greenDeep),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.greenDeep,
          textStyle: textTheme.labelLarge,
        ),
      ),
      // Filled bgInput per kit (.field); focused border = greenDeep (sage
      // focus). Validation reds use AppColors.error (#E53E3E) explicitly, NOT
      // ColorScheme.error (maroon).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.greenSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.greenDeep, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXl)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.butter,
        labelStyle: textTheme.labelMedium,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
      ),
      // Floating P2 toast — fgStrong surface, cream text, radiusMd.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.fgStrong,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.cream,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
        ),
      ),
    );
  }
}

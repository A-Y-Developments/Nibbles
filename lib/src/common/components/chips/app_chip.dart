import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Tone for [AppChip]. kit.css `.chip--*` is authoritative on colours/sizing;
/// warn/flag come from the components-chips preview (no kit.css entry).
enum AppChipTone { neutral, safe, warn, flag, mute, butter, green }

/// Small tag chip. h24, radiusFull, Parkinsans 700/11. Mirrors kit `.chip`.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.tone = AppChipTone.neutral,
    this.icon,
    this.emoji,
    super.key,
  });

  final String label;
  final AppChipTone tone;

  /// Optional leading icon widget (rendered before the label).
  final Widget? icon;

  /// Optional leading emoji string (alternative to [icon]).
  final String? emoji;

  Color get _background {
    switch (tone) {
      case AppChipTone.neutral:
        return AppColors.coralSoft;
      case AppChipTone.safe:
        return AppColors.success.withValues(alpha: 0.12);
      case AppChipTone.warn:
        return AppColors.warning.withValues(alpha: 0.15);
      case AppChipTone.flag:
        return AppColors.error.withValues(alpha: 0.12);
      case AppChipTone.mute:
        return AppColors.surfaceVariant;
      case AppChipTone.butter:
        return AppColors.butter;
      case AppChipTone.green:
        return AppColors.greenDeep;
    }
  }

  Color get _foreground {
    switch (tone) {
      case AppChipTone.neutral:
        return AppColors.coralDeep;
      case AppChipTone.safe:
        return AppColors.safeFg;
      case AppChipTone.warn:
        return AppColors.warnFg;
      case AppChipTone.flag:
        return AppColors.flagFg;
      case AppChipTone.mute:
        return AppColors.fgMuted;
      case AppChipTone.butter:
        return AppColors.greenDeep;
      case AppChipTone.green:
        return AppColors.cream;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _foreground;
    final leading =
        icon ??
        (emoji != null
            ? Text(emoji!, style: const TextStyle(fontSize: 11, height: 1))
            : null);

    return Container(
      height: AppSizes.chipHeightSm,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: fg, size: 12),
              child: leading,
            ),
            const SizedBox(width: AppSizes.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

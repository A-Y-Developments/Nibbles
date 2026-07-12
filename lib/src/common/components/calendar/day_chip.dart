import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Visual state for [DayChip] — mirrors components-calendar preview states.
enum DayChipState { selected, idle, filled }

/// Single 64x86 day chip in a horizontal week strip. Mirrors the
/// components-calendar preview (radius2xl). NOT table_calendar.
///
/// - selected: greenDeep bg, butterSoft text
/// - idle: white bg, greenDeep text, borderSoft border
/// - filled: butterSoft bg, green border, green check + greenDeep text
class DayChip extends StatelessWidget {
  const DayChip({
    required this.dayOfWeek,
    required this.date,
    required this.state,
    this.onTap,
    super.key,
  });

  /// Short weekday label (e.g. "Mon").
  final String dayOfWeek;

  /// Short date label (e.g. "18 Apr").
  final String date;
  final DayChipState state;
  final VoidCallback? onTap;

  Color get _background {
    switch (state) {
      case DayChipState.selected:
        return AppColors.greenDeep;
      case DayChipState.idle:
        return AppColors.surface;
      case DayChipState.filled:
        return AppColors.butterSoft;
    }
  }

  Color get _foreground => state == DayChipState.selected
      ? AppColors.butterSoft
      : AppColors.greenDeep;

  BoxBorder? get _border {
    switch (state) {
      case DayChipState.selected:
        return null;
      case DayChipState.idle:
        return Border.all(color: AppColors.borderSoft);
      case DayChipState.filled:
        return Border.all(color: AppColors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = state == DayChipState.selected;
    final dayStyle =
        (isSelected
                ? (AppTypography.textTheme.labelMedium ?? AppTypography.caption)
                : AppTypography.caption)
            .copyWith(
              color: _foreground,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            );
    final dateStyle = AppTypography.caption.copyWith(
      color: _foreground,
      fontWeight: FontWeight.w700,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.quick,
        curve: AppCurves.standard,
        width: AppSizes.dayChipW,
        height: AppSizes.dayChipH,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(AppSizes.radius2xl),
          border: _border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.base,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: state == DayChipState.filled
                  ? const Icon(
                      Icons.check,
                      key: ValueKey('filled'),
                      size: 18,
                      color: AppColors.green,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            AnimatedDefaultTextStyle(
              duration: AppDurations.quick,
              curve: AppCurves.standard,
              style: dayStyle,
              child: Text(dayOfWeek),
            ),
            const SizedBox(height: AppSizes.xs),
            AnimatedDefaultTextStyle(
              duration: AppDurations.quick,
              curve: AppCurves.standard,
              style: dateStyle,
              child: Text(date),
            ),
          ],
        ),
      ),
    );
  }
}

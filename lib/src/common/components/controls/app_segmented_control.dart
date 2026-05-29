import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// 2-up segmented control. Mirrors kit components-segmented preview:
/// track #EAEAEA (borderSoft), radiusMd, active segment greenDeep/cream.
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  }) : assert(segments.length == 2, 'AppSegmentedControl is 2-up only');

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppSizes.segmentedHeight,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: AppColors.borderSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: List.generate(segments.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: active ? AppColors.greenDeep : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(
                  segments[i],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.cream : AppColors.greenDeep,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

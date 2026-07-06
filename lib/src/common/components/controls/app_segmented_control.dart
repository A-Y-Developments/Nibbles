import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// 2-up segmented control. Mirrors kit components-segmented preview:
/// track #EAEAEA (borderSoft), radiusFull (pill), active segment greenDeep/cream,
/// labels in Parkinsans display 700/15 (kit `var(--font-display)` 700 15px/1).
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
    return Container(
      height: AppSizes.segmentedHeight,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: AppColors.borderSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
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
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                alignment: Alignment.center,
                child: Text(
                  segments[i],
                  style: TextStyle(
                    fontFamily: FontFamily.parkinsans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1,
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

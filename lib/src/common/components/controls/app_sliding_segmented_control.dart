import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Sliding segmented control (Figma 962:6668) shared across the Shopping List
/// (List / Bought) and Allergen Tracker (Ongoing / Big 11) tabs.
///
/// A custom animated pill thumb (Cupertino's thumb radius is fixed and can't
/// go fully rounded). Track borderSoft, forest `greenDeep` thumb, stadium
/// radius, Parkinsans SemiBold 15/22 labels (active onGreen, inactive green).
class AppSlidingSegmentedControl extends StatelessWidget {
  const AppSlidingSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  }) : assert(segments.length >= 2, 'needs at least 2 segments');

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double _trackPadding = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth =
            (constraints.maxWidth - _trackPadding * 2) / segments.length;
        return Container(
          padding: const EdgeInsets.all(_trackPadding),
          decoration: BoxDecoration(
            color: AppColors.borderSoft,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.greenDeep,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < segments.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: _SegmentLabel(
                        label: segments[i],
                        active: selectedIndex == i,
                        width: segmentWidth,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.label,
    required this.active,
    required this.width,
  });

  final String label;
  final bool active;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FontFamily.parkinsans,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 22 / 15,
            color: active ? AppColors.onGreen : AppColors.green,
          ),
        ),
      ),
    );
  }
}

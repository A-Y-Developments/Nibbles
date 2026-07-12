import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';

/// Generic 'no results' empty state for the Recipe Library search
/// (Figma 971:8813 / 971:8828).
///
/// Centered butter-flower-glyph ([BrandFlower], 136 per Figma Group74 box) +
/// 16/700 title. Verbatim copy per Figma — smart apostrophe (U+2019), no
/// subtitle. Search query is NOT interpolated into the message.
///
/// Renders the same in both keyboard-up (971:8813) and keyboard-dismissed
/// (971:8828) variants — Scaffold's default `resizeToAvoidBottomInset` lets
/// the `Center` re-centre against the available height when the OS keyboard
/// is shown or hidden.
class RecipeSearchEmpty extends StatelessWidget {
  const RecipeSearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandFlower(size: 136),
                SizedBox(height: AppSizes.sm + 2),
                Text(
                  'We couldn’t find any recipes',
                  textAlign: TextAlign.center,
                  style: AppTypography.emptyStateTitle,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: AppDurations.fade)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: AppDurations.slide,
          curve: AppCurves.emphasized,
        );
  }
}

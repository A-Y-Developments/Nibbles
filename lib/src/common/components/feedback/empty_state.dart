import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Empty / zero-data state. Mirrors components-empty-state preview:
/// Quatrefoil mark + 16/700 title + caption sub + optional CTA pill.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaPressed,
    this.markSize = 96,
    super.key,
  });

  final String title;
  final String subtitle;

  /// Optional CTA pill label. When set with [onCtaPressed], a small pill button
  /// is rendered below the subtitle.
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandFlower(size: markSize),
        const SizedBox(height: AppSizes.sm + 2),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.fgStrong,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.fgFaint,
            ),
          ),
        ),
        if (ctaLabel != null) ...[
          const SizedBox(height: AppSizes.sp12),
          AppPillButton(
            label: ctaLabel!,
            onPressed: onCtaPressed,
            size: AppPillButtonSize.small,
            expand: false,
          ),
        ],
      ],
    );
  }
}

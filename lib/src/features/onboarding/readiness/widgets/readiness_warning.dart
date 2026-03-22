import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

class ReadinessWarning extends StatelessWidget {
  const ReadinessWarning({
    required this.onGoBack,
    required this.onContinue,
    super.key,
  });

  final VoidCallback onGoBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(26),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.warning),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.warning,
                      size: AppSizes.iconMd,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      'Not quite ready yet?',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'We recommend consulting your GP before starting solids.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Consulting a doctor or paediatrician before '
                    'introducing solids is best practice for all babies.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.subtext,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('I Understand, Continue'),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoBack,
              child: const Text('Go Back'),
            ),
          ),
          const SizedBox(height: AppSizes.pagePaddingV),
        ],
      ),
    );
  }
}

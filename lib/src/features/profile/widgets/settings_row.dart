import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Cream-surfaced action row used in the Settings list.
///
/// Mirrors the kit `.card` + `.box-shadow: var(--shadow-card)` pattern from
/// `design/ui_kits/nibbles_mobile/ProfileScreen.jsx`. Supports a `danger`
/// variant that tints the title + chevron with [AppColors.destructive].
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = danger ? AppColors.destructive : AppColors.fgStrong;
    final chevronColor = danger ? AppColors.destructive : AppColors.greenDeep;

    final radius = BorderRadius.circular(AppSizes.radiusXl);

    return Material(
      color: AppColors.cream,
      borderRadius: radius,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: radius,
          boxShadow: AppSizes.shadowCard,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md - 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: titleColor,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSizes.sp2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.fgFaint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppSizes.iconMd,
                  color: chevronColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

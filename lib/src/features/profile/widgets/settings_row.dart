import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/feedback/press_scale.dart';

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

    // Figma audit (node 1207:15365 etc.): list rows use radius 10 and p-12.
    final radius = BorderRadius.circular(AppSizes.radiusMd);

    return Semantics(
      button: true,
      label: title,
      value: subtitle,
      hint: danger ? 'Destructive action' : null,
      child: ExcludeSemantics(
        child: PressableScale(
          child: Material(
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
                  padding: const EdgeInsets.all(AppSizes.sp12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Headline/SemiBold — Parkinsans 600 15/22.
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                height: 22 / 15,
                                color: titleColor,
                              ),
                            ),
                            if (subtitle != null) ...[
                              // Body/Regular — Figtree 400 15/22.
                              Text(
                                subtitle!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ExcludeSemantics(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: AppSizes.iconMd,
                          color: chevronColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

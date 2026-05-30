import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Coral circular avatar + baby name + age caption + ghost Edit pill.
///
/// Mirrors `design/ui_kits/nibbles_mobile/ProfileScreen.jsx` — 120px coral
/// circle holding a cream baby silhouette, headline name, faint age caption,
/// 110-wide ghost Edit pill below.
class ProfileAvatarCard extends StatelessWidget {
  const ProfileAvatarCard({
    required this.name,
    required this.ageLabel,
    required this.onEdit,
    super.key,
  });

  final String name;
  final String ageLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.butterSoft,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md + 2,
        0,
        AppSizes.md + 2,
        AppSizes.lg,
      ),
      child: Column(
        children: [
          Container(
            width: AppSizes.avatarXl,
            height: AppSizes.avatarXl,
            decoration: const BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.child_care_rounded,
                size: 64,
                color: AppColors.cream,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.fgStrong,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            ageLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgFaint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            width: 110,
            child: AppPillButton(
              key: const Key('profile_edit_button'),
              label: 'Edit',
              onPressed: onEdit,
              variant: AppPillButtonVariant.ghost,
              size: AppPillButtonSize.small,
            ),
          ),
        ],
      ),
    );
  }
}

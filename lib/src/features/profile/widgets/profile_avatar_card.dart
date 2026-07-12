import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/avatar/baby_avatar.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Avatar / identity block on Profile (Figma node 1189:12440).
///
/// Layout (column, gap 24):
///  - 143x143 peach baby-circle avatar (`BabyAvatar`).
///  - Name (Title 1/Bold — Parkinsans 700 24 / lh 37) + age subtitle
///    (Body/Regular — Figtree 400 18), 4px gap between.
///  - 108x48 butter pill "Edit" (radius 24, Parkinsans SemiBold 15,
///    forestDarkn label).
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.lg,
      ),
      child: Column(
        children: [
          const BabyAvatar(),
          const SizedBox(height: AppSizes.lg),
          // Title 1/Bold — Parkinsans 700 24 / lh 37.
          Text(
            name,
            style: const TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 37 / 24,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          // Body/Regular — Figtree 400 18.
          Text(
            ageLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.text,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          // Edit pill — Figma node 1189:12428.
          Semantics(
            button: true,
            label: 'Edit',
            hint: 'Edit baby profile',
            child: SizedBox(
              width: 108,
              child: AppPillButton(
                key: const Key('profile_edit_button'),
                label: 'Edit',
                variant: AppPillButtonVariant.ghost,
                size: AppPillButtonSize.small,
                onPressed: onEdit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

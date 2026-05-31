import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Avatar / identity block on Profile (Figma node 1189:12440).
///
/// Layout (column, gap 24):
///  - 143x143 coral avatar circle (Nibble-primary-Salmon #f8a175).
///  - Name (Title 1/Bold — Parkinsans 700 22 / lh 34) + age subtitle
///    (Body/Regular — Figtree 400 15 / lh 22), 4px gap between.
///  - 108x48 butter pill "Edit" (radius 24, Parkinsans SemiBold 15,
///    forestDarkn label).
///
/// Asset note: the Figma file references an external Nibbles peach-circle
/// PNG (madam-app path) that is not bundled in this repo; the coral circle
/// + cream baby-face glyph is the agreed code approximation until the
/// asset ships (see audit `asset_urls.txt`).
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

  static const double _avatarDiameter = 143;

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
          ExcludeSemantics(
            child: Container(
              width: _avatarDiameter,
              height: _avatarDiameter,
              decoration: const BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.child_care_rounded,
                  size: 72,
                  color: AppColors.cream,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Title 1/Bold — Parkinsans 700 22 / lh 34.
          Text(
            name,
            style: const TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 34 / 22,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          // Body/Regular — Figtree 400 15 / lh 22.
          Text(
            ageLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.text,
              fontSize: 15,
              height: 22 / 15,
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

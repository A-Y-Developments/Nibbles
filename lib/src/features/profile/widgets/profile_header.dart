import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';

/// Butter-soft wash header for the Profile / Settings screen.
///
/// Mirrors `design/ui_kits/nibbles_mobile/ProfileScreen.jsx`:
/// background `butterSoft`, 32px ghost back chevron on the left, centered
/// "Settings" title (titleSmall 17/700), 32px right slot for layout symmetry.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.butterSoft,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md + 2,
        AppSizes.sm - 2,
        AppSizes.md + 2,
        AppSizes.lg,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.roundButtonSm,
            child: AppRoundButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack,
              tone: AppRoundButtonTone.ghost,
              size: AppRoundButtonSize.small,
              semanticLabel: 'Back',
            ),
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.fgStrong,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.roundButtonSm),
        ],
      ),
    );
  }
}

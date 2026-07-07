import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';

/// Profile / Settings screen header — Figma node 1189:10786.
///
/// Layout: a single row of (back chip → "Settings" title), title is
/// LEFT-aligned hugging the chip (no center). Sits on top of the screen's
/// shared butter-soft gradient (no per-widget background fill).
/// Title is Title 3/Bold — Parkinsans 700 17.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sp12,
        AppSizes.sm - 2,
        AppSizes.sp12,
        AppSizes.lg,
      ),
      child: Row(
        children: [
          AppRoundButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            tone: AppRoundButtonTone.ghost,
            size: AppRoundButtonSize.small,
            semanticLabel: 'Back',
          ),
          const SizedBox(width: AppSizes.sp2),
          Text(
            'Settings',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.fgStrong,
            ),
          ),
        ],
      ),
    );
  }
}

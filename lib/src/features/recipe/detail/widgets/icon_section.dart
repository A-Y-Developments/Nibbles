import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Section header with a leading butter-circle icon and a Parkinsans
/// title. Used by Ingredients, Method, and Utensils on the recipe detail
/// screen.
///
/// Layout: 28px circle (butter background, greenDeep icon) + title text.
class IconSectionHeader extends StatelessWidget {
  const IconSectionHeader({
    required this.icon,
    required this.title,
    super.key,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: AppSizes.tipGlyph,
          height: AppSizes.tipGlyph,
          decoration: const BoxDecoration(
            color: AppColors.butter,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: AppSizes.iconSm,
            color: AppColors.greenDeep,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
        ),
      ],
    );
  }
}

/// Composed section block — `IconSectionHeader` plus arbitrary [child] body.
/// Wraps the body in 12px vertical spacing and keeps the section left-aligned.
class IconSection extends StatelessWidget {
  const IconSection({
    required this.icon,
    required this.title,
    required this.child,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconSectionHeader(icon: icon, title: title),
        const SizedBox(height: AppSizes.sp12),
        child,
      ],
    );
  }
}

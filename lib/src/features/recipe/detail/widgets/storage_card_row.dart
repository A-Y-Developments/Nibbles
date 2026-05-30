import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Row of two salmon "Storage" / "Freezer" cards. If both notes are null the
/// row is suppressed entirely — caller should hide via the same null-check.
///
/// Either side can be null independently; this widget handles that by laying
/// out only the non-null sides side-by-side. When both are null an empty
/// [SizedBox] is returned (defence-in-depth — caller is expected to hide
/// the whole section).
class StorageCardRow extends StatelessWidget {
  const StorageCardRow({
    this.storageNote,
    this.freezerNote,
    super.key,
  });

  final String? storageNote;
  final String? freezerNote;

  @override
  Widget build(BuildContext context) {
    final storage = storageNote;
    final freezer = freezerNote;
    if (storage == null && freezer == null) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (storage != null)
          Expanded(
            child: _StorageCard(
              icon: Icons.kitchen_outlined,
              title: 'Storage',
              body: storage,
            ),
          ),
        if (storage != null && freezer != null)
          const SizedBox(width: AppSizes.sm),
        if (freezer != null)
          Expanded(
            child: _StorageCard(
              icon: Icons.ac_unit_outlined,
              title: 'Freezer',
              body: freezer,
            ),
          ),
      ],
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sp12,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: AppColors.coralDeep),
              const SizedBox(width: AppSizes.xs),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgDefault,
            ),
          ),
        ],
      ),
    );
  }
}

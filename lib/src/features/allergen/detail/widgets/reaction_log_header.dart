import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Section header — 'Reaction Log' title with a sage '+' button on the right.
///
/// Per spec 9 — tapping the '+' routes to the existing log sheet entry point.
class ReactionLogHeader extends StatelessWidget {
  const ReactionLogHeader({required this.onAddPressed, super.key});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text('Reaction Log', style: textTheme.titleMedium)),
        Semantics(
          button: true,
          label: 'Add reaction log',
          child: Material(
            color: AppColors.greenDeep,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onAddPressed,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: AppSizes.roundButtonSm,
                height: AppSizes.roundButtonSm,
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: AppSizes.iconMd,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

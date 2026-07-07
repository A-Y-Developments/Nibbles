import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Section header — 'Reaction Log' title with a sage '+' button on the right.
///
/// Per spec 9 — tapping the '+' routes to the existing log sheet entry point.
class ReactionLogHeader extends StatelessWidget {
  const ReactionLogHeader({
    required this.onAddPressed,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onAddPressed;

  /// When false (the allergen is finished — safe/flagged), the '+' is greyed
  /// out and non-interactive; logging is done, so start a new allergen instead.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text('Reaction Log', style: textTheme.titleMedium)),
        Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Semantics(
            button: true,
            enabled: enabled,
            label: 'Add reaction log',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onAddPressed : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Container(
                      width: AppSizes.roundButton,
                      height: AppSizes.roundButton,
                      decoration: const BoxDecoration(
                        color: AppColors.greenDeep,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
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
            ),
          ),
        ),
      ],
    );
  }
}

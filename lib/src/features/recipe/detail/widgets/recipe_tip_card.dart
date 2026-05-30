import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';

/// Tip card variant used on the recipe detail screen for "Texture Tip" and
/// "Why this meal".
///
/// Thin wrapper around the design-system [TipCard] that fixes a feature-
/// specific icon per tip kind. Hides itself when the body is null or empty so
/// callers can drop a single line per slot without ad-hoc null checks.
enum RecipeTipKind { textureTip, whyThisMeal }

class RecipeTipCard extends StatelessWidget {
  const RecipeTipCard({required this.kind, required this.body, super.key});

  final RecipeTipKind kind;
  final String? body;

  String get _title => switch (kind) {
    RecipeTipKind.textureTip => 'Texture Tip',
    RecipeTipKind.whyThisMeal => 'Why this meal',
  };

  String get _glyph => switch (kind) {
    RecipeTipKind.textureTip => 'T',
    RecipeTipKind.whyThisMeal => '?',
  };

  @override
  Widget build(BuildContext context) {
    final text = body;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: TipCard(title: _title, body: text, glyph: _glyph),
    );
  }
}

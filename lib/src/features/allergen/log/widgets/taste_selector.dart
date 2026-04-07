import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';

class TasteSelector extends StatelessWidget {
  const TasteSelector({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final EmojiTaste? selected;
  final ValueChanged<EmojiTaste> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TasteCard(
          emoji: '😍',
          label: 'Love it',
          selected: selected == EmojiTaste.love,
          onTap: () => onSelect(EmojiTaste.love),
        ),
        const SizedBox(width: AppSizes.sm),
        _TasteCard(
          emoji: '😐',
          label: 'Neutral',
          selected: selected == EmojiTaste.neutral,
          onTap: () => onSelect(EmojiTaste.neutral),
        ),
        const SizedBox(width: AppSizes.sm),
        _TasteCard(
          emoji: '😣',
          label: 'Dislike',
          selected: selected == EmojiTaste.dislike,
          onTap: () => onSelect(EmojiTaste.dislike),
        ),
      ],
    );
  }
}

class _TasteCard extends StatelessWidget {
  const _TasteCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.primary : AppColors.subtext,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

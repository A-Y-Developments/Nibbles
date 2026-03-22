import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// AL-04 → AL-05 multi-step bottom sheet.
///
/// Opened via [showAllergenLogSheet].
class AllergenLogSheet extends ConsumerStatefulWidget {
  const AllergenLogSheet({
    required this.babyId,
    required this.babyName,
    required this.allergenKey,
    required this.allergenName,
    required this.allergenEmoji,
    super.key,
  });

  final String babyId;
  final String babyName;
  final String allergenKey;
  final String allergenName;
  final String allergenEmoji;

  @override
  ConsumerState<AllergenLogSheet> createState() => _AllergenLogSheetState();
}

class _AllergenLogSheetState extends ConsumerState<AllergenLogSheet> {
  int _step = 0; // 0 = AL-04 taste, 1 = AL-05 reaction

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allergenLogControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allergenLogControllerProvider);

    // On successful no-reaction save, dismiss sheet.
    ref.listen(allergenLogControllerProvider, (_, next) {
      if (next.isSaved && next.hadReaction == false) {
        if (context.mounted) Navigator.of(context).pop(true);
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _step == 0
                ? _TasteStep(
                    key: const ValueKey('taste'),
                    babyName: widget.babyName,
                    allergenName: widget.allergenName,
                    allergenEmoji: widget.allergenEmoji,
                    onNext: () => setState(() => _step = 1),
                  )
                : _ReactionStep(
                    key: const ValueKey('reaction'),
                    babyName: widget.babyName,
                    isLoading: state.isLoading,
                    errorMessage:
                        state.isDuplicateLog ? state.errorMessage : null,
                    onSave: _handleReactionSave,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleReactionSave({required bool hadReaction}) async {
    ref
        .read(allergenLogControllerProvider.notifier)
        .setReaction(hadReaction: hadReaction);

    if (hadReaction) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      unawaited(
        context.pushNamed(
          AppRoute.reactionLog.name,
          extra: ReactionLogArgs(
            babyId: widget.babyId,
            allergenKey: widget.allergenKey,
            allergenName: widget.allergenName,
            allergenEmoji: widget.allergenEmoji,
          ),
        ),
      );
    } else {
      await ref
          .read(allergenLogControllerProvider.notifier)
          .saveLog(widget.babyId, widget.allergenKey);
    }
  }
}

// ---------------------------------------------------------------------------
// AL-04 — Taste Step
// ---------------------------------------------------------------------------

class _TasteStep extends ConsumerWidget {
  const _TasteStep({
    required this.babyName,
    required this.allergenName,
    required this.allergenEmoji,
    required this.onNext,
    super.key,
  });

  final String babyName;
  final String allergenName;
  final String allergenEmoji;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taste = ref.watch(
      allergenLogControllerProvider.select((s) => s.taste),
    );
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          'How did $babyName like $allergenName $allergenEmoji?',
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            _TasteCard(
              emoji: '😍',
              label: 'Love it',
              selected: taste == EmojiTaste.love,
              onTap: () => ref
                  .read(allergenLogControllerProvider.notifier)
                  .setTaste(EmojiTaste.love),
            ),
            const SizedBox(width: AppSizes.sm),
            _TasteCard(
              emoji: '😐',
              label: 'Neutral',
              selected: taste == EmojiTaste.neutral,
              onTap: () => ref
                  .read(allergenLogControllerProvider.notifier)
                  .setTaste(EmojiTaste.neutral),
            ),
            const SizedBox(width: AppSizes.sm),
            _TasteCard(
              emoji: '😣',
              label: 'Dislike',
              selected: taste == EmojiTaste.dislike,
              onTap: () => ref
                  .read(allergenLogControllerProvider.notifier)
                  .setTaste(EmojiTaste.dislike),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xl),
        FilledButton(
          key: const Key('taste_next_button'),
          onPressed: taste != null ? onNext : null,
          child: const Text('Next'),
        ),
        const SizedBox(height: AppSizes.md),
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

// ---------------------------------------------------------------------------
// AL-05 — Reaction Step
// ---------------------------------------------------------------------------

class _ReactionStep extends ConsumerWidget {
  const _ReactionStep({
    required this.babyName,
    required this.isLoading,
    required this.onSave,
    this.errorMessage,
    super.key,
  });

  final String babyName;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function({required bool hadReaction}) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadReaction = ref.watch(
      allergenLogControllerProvider.select((s) => s.hadReaction),
    );
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          'Did $babyName have any reaction?',
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xl),
        _ReactionToggleCard(
          icon: '✅',
          label: 'No Reaction',
          selected: !(hadReaction ?? true),
          selectedColor: AppColors.success,
          onTap: () => ref
              .read(allergenLogControllerProvider.notifier)
              .setReaction(hadReaction: false),
        ),
        const SizedBox(height: AppSizes.sm),
        _ReactionToggleCard(
          icon: '⚠️',
          label: 'Had a Reaction',
          selected: hadReaction ?? false,
          selectedColor: AppColors.warning,
          onTap: () => ref
              .read(allergenLogControllerProvider.notifier)
              .setReaction(hadReaction: true),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            errorMessage!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSizes.xl),
        FilledButton(
          key: const Key('reaction_save_button'),
          onPressed: (hadReaction != null && !isLoading)
              ? () => onSave(hadReaction: hadReaction)
              : null,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Text('Save'),
        ),
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}

class _ReactionToggleCard extends StatelessWidget {
  const _ReactionToggleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: selected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSizes.md),
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: selected ? selectedColor : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Args passed via GoRouter extra to ReactionLogScreen
// ---------------------------------------------------------------------------

class ReactionLogArgs {
  const ReactionLogArgs({
    required this.babyId,
    required this.allergenKey,
    required this.allergenName,
    required this.allergenEmoji,
  });

  final String babyId;
  final String allergenKey;
  final String allergenName;
  final String allergenEmoji;
}

// ---------------------------------------------------------------------------
// Helper to open the sheet
// ---------------------------------------------------------------------------

Future<bool?> showAllergenLogSheet(
  BuildContext context, {
  required String babyId,
  required String babyName,
  required String allergenKey,
  required String allergenName,
  required String allergenEmoji,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXl),
      ),
    ),
    builder: (_) => AllergenLogSheet(
      babyId: babyId,
      babyName: babyName,
      allergenKey: allergenKey,
      allergenName: allergenName,
      allergenEmoji: allergenEmoji,
    ),
  );
}

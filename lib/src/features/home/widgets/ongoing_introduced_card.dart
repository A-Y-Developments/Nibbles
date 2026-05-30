import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Home — Ongoing-introduced card (NIB-77, Figma 1242:10616).
///
/// Shows the first allergen in [kAllergenKeys] order whose status is
/// [AllergenStatus.inProgress]. Whole card taps push the allergen tracker.
/// When no allergen is in-progress the card renders [SizedBox.shrink] so the
/// home layout collapses naturally.
///
/// Note: log counts ('X/3 times' subhead) are intentionally omitted — the home
/// state only carries derived statuses, not per-allergen log counts. The
/// 3-segment progress bar therefore renders all 3 empty.
class OngoingIntroducedCard extends StatelessWidget {
  const OngoingIntroducedCard({
    required this.allergenStatuses,
    super.key,
  });

  final Map<String, AllergenStatus> allergenStatuses;

  String? get _ongoingKey {
    for (final key in kAllergenKeys) {
      if (allergenStatuses[key] == AllergenStatus.inProgress) return key;
    }
    return null;
  }

  String _displayName(String key) =>
      key.replaceAll('_', ' ').split(' ').map(_capitalize).join(' ');

  String _capitalize(String word) =>
      word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final key = _ongoingKey;
    if (key == null) return const SizedBox.shrink();

    final emoji = AllergenEmoji.get(key);
    final name = _displayName(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ONGOING INTRODUCED',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.fgFaint,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            onTap: () =>
                context.pushNamed(AppRoute.allergenTracker.name),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                boxShadow: AppSizes.shadowCard,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md - 2,
                vertical: AppSizes.sp12,
              ),
              child: Row(
                children: [
                  _CoralThumb(emoji: emoji),
                  const SizedBox(width: AppSizes.sp12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppTypography.emptyStateTitle,
                        ),
                        const SizedBox(height: AppSizes.sp2),
                        Text(
                          'Currently introducing',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.fgFaint,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        const _ProgressSegments(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  const Icon(
                    Icons.chevron_right,
                    size: AppSizes.iconMd,
                    color: AppColors.fgFaint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoralThumb extends StatelessWidget {
  const _CoralThumb({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.coral, AppColors.orange50],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 28, height: 1),
      ),
    );
  }
}

class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(3, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : AppSizes.xs),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.coralSoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}

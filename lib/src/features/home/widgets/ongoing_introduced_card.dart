import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Home — Ongoing-introduced card (NIB-77, Figma 1242:10616).
///
/// Shows the first allergen in [kAllergenKeys] order whose status is
/// [AllergenStatus.inProgress]. Whole card taps push the allergen tracker.
/// When no allergen is in-progress the card renders [SizedBox.shrink] so the
/// home layout collapses naturally.
///
/// Per the NIB-77 remediation audit (home-populated frame), the subhead
/// shows `"X/3 times "` (verbatim — trailing space preserved) and the
/// 3-segment progress bar lights up the first X segments in salmon
/// ([AppColors.coral]) with the remainder rendered in [AppColors.borderSoft].
/// [logCounts] is the clean-log count per allergen key sourced from
/// `HomeState.allergenLogCounts`; absent keys default to 0.
class OngoingIntroducedCard extends StatelessWidget {
  const OngoingIntroducedCard({
    required this.allergenStatuses,
    this.logCounts = const <String, int>{},
    super.key,
  });

  final Map<String, AllergenStatus> allergenStatuses;
  final Map<String, int> logCounts;

  /// Allergens are considered safe after 3 clean (no-reaction) logs — that
  /// 3 is the canonical target the segmented bar visualises.
  static const int _target = 3;

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
    final filled = (logCounts[key] ?? 0).clamp(0, _target);

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
            onTap: () {
              unawaited(
                Analytics.instance.logHomeOngoingAllergenTapped(
                  allergenKey: key,
                ),
              );
              context.pushNamed(AppRoute.allergenTracker.name);
            },
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
                          '$filled/$_target times ',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.fgFaint,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _ProgressSegments(filled: filled),
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
  const _ProgressSegments({required this.filled});

  /// Number of segments to render with the salmon fill (0..3).
  final int filled;

  static const int _segments = 3;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(_segments, (i) {
        final isFilled = i < filled;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : AppSizes.xs),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: isFilled ? AppColors.coral : AppColors.borderSoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}

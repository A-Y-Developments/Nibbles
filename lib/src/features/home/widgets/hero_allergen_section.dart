import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_allergen_card.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';

/// Allergen block inside the lime hero card. Switches on
/// [HomeAllergenHeroState]:
///
/// - `start` (or a missing key): a tall [StartAllergenButton].
/// - `ongoing`: "ONGOING ALLERGEN" overline + [OngoingAllergenCard].
/// - `finishedStartNext`: overline + [OngoingAllergenCard] with an inset
///   start button.
/// - `allDone`: nothing.
///
/// Navigation is delegated: [onStartTracker] opens the allergen tracker,
/// [onOpenDetail] opens the current allergen's detail.
class HeroAllergenSection extends StatelessWidget {
  const HeroAllergenSection({
    required this.heroState,
    required this.allergenKey,
    required this.displayName,
    required this.cleanCount,
    required this.onStartTracker,
    required this.onOpenDetail,
    super.key,
  });

  final HomeAllergenHeroState heroState;
  final String? allergenKey;
  final String displayName;
  final int cleanCount;
  final VoidCallback onStartTracker;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final key = allergenKey;

    if (heroState == HomeAllergenHeroState.allDone) {
      return const SizedBox.shrink();
    }

    if (heroState == HomeAllergenHeroState.start || key == null) {
      return StartAllergenButton(onPressed: onStartTracker);
    }

    final showStart = heroState == HomeAllergenHeroState.finishedStartNext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Text(
            'ONGOING ALLERGEN',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.greenDeep,
            ),
          ),
        ),
        OngoingAllergenCard(
          allergenKey: key,
          displayName: displayName,
          cleanCount: cleanCount,
          showStartButton: showStart,
          onTap: onOpenDetail,
          onStart: onStartTracker,
        ),
      ],
    );
  }
}

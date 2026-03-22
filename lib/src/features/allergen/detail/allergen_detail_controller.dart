import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_detail_controller.g.dart';

@riverpod
class AllergenDetailController extends _$AllergenDetailController {
  @override
  Future<AllergenDetailState> build(String allergenKey) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) {
      throw const UnknownException('No baby profile found.');
    }

    final result = await ref
        .read(allergenServiceProvider)
        .getAllergenBoardSummary(baby.id);
    return result.fold(
      onSuccess: (items) {
        final sorted = [...items]
          ..sort(
            (a, b) =>
                a.allergen.sequenceOrder.compareTo(b.allergen.sequenceOrder),
          );
        final currentIndex =
            sorted.indexWhere((i) => i.allergen.key == allergenKey);
        if (currentIndex == -1) {
          throw NotFoundException('Allergen "$allergenKey" not found.');
        }
        final next = currentIndex < sorted.length - 1
            ? sorted[currentIndex + 1].allergen
            : null;
        return AllergenDetailState(
          boardItem: sorted[currentIndex],
          babyId: baby.id,
          nextAllergen: next,
        );
      },
      onFailure: (AppException error) => throw error,
    );
  }

  /// Advances the program to the next allergen.
  ///
  /// Returns the next allergen key if the program is still ongoing,
  /// or `null` if the full program is now complete (navigate to AL-08).
  Future<Result<String?>> advanceToNext() async {
    final current = state.valueOrNull;
    if (current == null) {
      return const Result.failure(UnknownException());
    }

    final currentKey = current.boardItem.allergen.key;
    final nextKey = current.nextAllergen?.key;

    final result = await ref
        .read(allergenServiceProvider)
        .advanceToNextAllergen(current.babyId);
    if (result.isFailure) return Result.failure(result.errorOrNull!);

    unawaited(
      Analytics.instance.logAllergenAdvanced(
        fromKey: currentKey,
        toKey: nextKey ?? 'completed',
      ),
    );
    unawaited(
      Analytics.instance.logAllergenMarkedSafe(allergenKey: currentKey),
    );

    ref.invalidateSelf();
    return Result.success(nextKey);
  }
}

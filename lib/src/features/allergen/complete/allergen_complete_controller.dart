import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/complete/allergen_complete_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_complete_controller.g.dart';

@riverpod
class AllergenCompleteController extends _$AllergenCompleteController {
  @override
  Future<AllergenCompleteState> build() async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) {
      throw const UnknownException('No baby profile found.');
    }

    final result = await ref
        .read(allergenServiceProvider)
        .getAllergenBoardSummary(baby.id);
    return result.fold(
      onSuccess: (items) {
        final allergens = items.map((i) => i.allergen).toList()
          ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

        try {
          unawaited(Analytics.instance.logAllergenProgramCompleted());
        } on Object catch (_) {}

        return AllergenCompleteState(
          babyName: baby.name,
          babyId: baby.id,
          allergens: allergens,
        );
      },
      onFailure: (AppException error) => throw error,
    );
  }

  /// Sets the shown-once flag so AL-08 is never re-shown for this baby.
  void markShown() {
    final current = state.valueOrNull;
    if (current == null) return;
    ref
        .read(localFlagServiceProvider)
        .setProgramCompletionShown(current.babyId);
  }
}

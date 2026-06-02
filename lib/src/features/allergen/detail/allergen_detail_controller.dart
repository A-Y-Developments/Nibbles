import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
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
    final service = ref.read(allergenServiceProvider);

    final allergensResult = await service.getAllergens();
    _throwIfFailure(allergensResult);
    final allergen = allergensResult.dataOrNull!.firstWhere(
      (Allergen a) => a.key == allergenKey,
      orElse: () =>
          throw UnknownException('Allergen "$allergenKey" not found.'),
    );

    final logsResult = await service.getLogs(baby.id, allergenKey: allergenKey);
    _throwIfFailure(logsResult);
    final logs = logsResult.dataOrNull!;

    final status = service.deriveStatus(logs);

    DateTime? firstIntroduced;
    DateTime? lastGiven;
    if (logs.isNotEmpty) {
      var min = logs.first.logDate;
      var max = logs.first.logDate;
      for (final log in logs) {
        if (log.logDate.isBefore(min)) min = log.logDate;
        if (log.logDate.isAfter(max)) max = log.logDate;
      }
      firstIntroduced = min;
      lastGiven = max;
    }

    return AllergenDetailState(
      allergen: allergen,
      logs: logs,
      status: status,
      babyId: baby.id,
      babyName: baby.name,
      firstIntroduced: firstIntroduced,
      lastGiven: lastGiven,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void _throwIfFailure<T>(Result<T> result) {
    if (result.isFailure) {
      throw result.errorOrNull!;
    }
  }
}

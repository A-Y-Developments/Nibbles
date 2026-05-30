import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergen_log_detail_controller.g.dart';

/// Hydrates a single [AllergenLog] for the read-only detail screen.
///
/// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
/// architecture rule — services own repository access. The exposed log number
/// is derived from the log's position in the oldest-first sequence so it
/// matches the "Log N" labels rendered on the tracker and allergen detail.
@riverpod
class AllergenLogDetailController extends _$AllergenLogDetailController {
  @override
  Future<AllergenLogDetailState> build(
    String allergenKey,
    String logId,
  ) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) {
      throw StateError('No baby profile found.');
    }
    final service = ref.read(allergenServiceProvider);

    final allergensResult = await service.getAllergens();
    _throwIfFailure(allergensResult);
    final allergen = allergensResult.dataOrNull!.firstWhere(
      (Allergen a) => a.key == allergenKey,
      orElse: () => throw StateError('Allergen "$allergenKey" not found.'),
    );

    final logsResult = await service.getLogs(
      baby.id,
      allergenKey: allergenKey,
    );
    _throwIfFailure(logsResult);
    final logs = logsResult.dataOrNull!;

    final index = logs.indexWhere((AllergenLog l) => l.id == logId);
    if (index < 0) {
      throw StateError('Log "$logId" not found.');
    }

    return AllergenLogDetailState(
      allergen: allergen,
      log: logs[index],
      babyId: baby.id,
      logNumber: index + 1,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void _throwIfFailure<T>(Result<T> result) {
    if (result.isFailure) {
      throw StateError(result.errorOrNull!.message);
    }
  }
}

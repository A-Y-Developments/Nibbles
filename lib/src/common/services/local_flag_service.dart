import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app/constants/hive_box_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_flag_service.g.dart';

/// Wraps the [HiveBoxNames.localFlags] Hive box.
///
/// Read operations are synchronous — the box is opened before [runApp].
/// Write operations are fire-and-forget (Hive writes are async but callers
/// do not need to await them for flag semantics).
class LocalFlagService {
  LocalFlagService(this._box);

  final Box<dynamic> _box;

  // ---------------------------------------------------------------------------
  // App launch flag
  // ---------------------------------------------------------------------------

  /// Returns [true] if the app has been launched at least once.
  bool hasLaunched() => _box.get('app_has_launched', defaultValue: false) as bool;

  /// Marks the app as having been launched.
  void setHasLaunched() => _box.put('app_has_launched', true);

  // ---------------------------------------------------------------------------
  // Per-baby allergen program completion flag
  // ---------------------------------------------------------------------------

  /// Returns [true] if the completion screen has already been shown for [babyId].
  bool isProgramCompletionShown(String babyId) =>
      _box.get('program_completion_shown_$babyId', defaultValue: false) as bool;

  /// Marks the completion screen as shown for [babyId].
  void setProgramCompletionShown(String babyId) =>
      _box.put('program_completion_shown_$babyId', true);
}

@riverpod
LocalFlagService localFlagService(LocalFlagServiceRef ref) {
  return LocalFlagService(Hive.box<dynamic>(HiveBoxNames.localFlags));
}

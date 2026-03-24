import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app/constants/hive_box_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_service.g.dart';

/// Provides typed access to the Hive boxes used for read-through caching.
///
/// All boxes must be opened before runApp (done in bootstrap).
/// This service is purely a thin wrapper — caching logic lives in repositories.
class HiveService {
  /// Box storing serialised Recipe JSON strings.
  Box<String> get recipesBox => Hive.box<String>(HiveBoxNames.recipes);

  /// Box storing serialised Allergen JSON strings.
  Box<String> get allergensBox => Hive.box<String>(HiveBoxNames.allergens);
}

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package // *Ref types deprecated in riverpod 3.0; upgrade deferred
HiveService hiveService(HiveServiceRef ref) {
  return HiveService();
}

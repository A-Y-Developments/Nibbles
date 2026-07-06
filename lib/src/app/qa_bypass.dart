import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/app/constants/hive_box_names.dart';
import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/repositories/baby_profile_repository.dart';
import 'package:nibbles/src/common/data/repositories/meal_plan_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Compile-time QA bypass switch.
///
/// When passed via `--dart-define=NIBBLES_QA_BYPASS=true`, the app boots
/// straight into `/home` without real auth, a real Supabase session, or a
/// real baby record. Used by the visual-gate render phase in the build
/// pipeline. When the flag is false (default), everything below is inert and
/// production behaviour is unchanged.
const bool kQaBypass = bool.fromEnvironment('NIBBLES_QA_BYPASS');

/// Synthetic baby surfaced by [_QaBabyProfileRepository] so screens that need
/// a baby record (Home, Profile, Profile Edit) render without a Supabase row.
Baby _syntheticBaby() {
  final now = DateTime.now();
  // 6 months ago, day-anchored.
  final dob = DateTime(now.year, now.month - 6, now.day);
  return Baby(
    id: 'qa-baby-id',
    userId: 'qa-user-id',
    name: 'QA Tester',
    dateOfBirth: dob,
    gender: Gender.preferNotToSay,
    onboardingCompleted: true,
  );
}

/// Pre-populates the four onboarding flags in the `local_flags` Hive box so
/// the GoRouter redirect chain lets the user reach `/home` (and any sub-route)
/// without authenticating or running onboarding.
///
/// Must be called AFTER `Hive.openBox<dynamic>('local_flags')` and BEFORE
/// `runApp`. No-op when [kQaBypass] is false.
Future<void> seedQaLocalFlags() async {
  if (!kQaBypass) return;
  final box = Hive.box<dynamic>(HiveBoxNames.localFlags);
  await box.putAll(<String, dynamic>{
    'app_has_launched': true,
    'onboarding_readiness_done': true,
    'onboarding_baby_setup_done': true,
    'onboarding_done': true,
  });
}

/// ProviderScope overrides that swap the four Supabase-backed repositories
/// for synthetic in-memory fakes. Returns an empty list when [kQaBypass] is
/// false so the no-flag path stays completely inert.
///
/// The override seam is the Repository layer (matches the project's "Supabase
/// only in repos" rule). Real `AuthService`, `BabyProfileService`,
/// `AllergenService`, and `MealPlanService` logic flows on top unchanged.
List<Override> qaBypassOverrides() {
  if (!kQaBypass) return const [];
  return [
    authRepositoryProvider.overrideWithValue(const _QaAuthRepository()),
    babyProfileRepositoryProvider.overrideWithValue(_QaBabyProfileRepository()),
    allergenRepositoryProvider.overrideWithValue(const _QaAllergenRepository()),
    mealPlanRepositoryProvider.overrideWithValue(const _QaMealPlanRepository()),
  ];
}

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class _QaAuthRepository implements AuthRepository {
  const _QaAuthRepository();

  @override
  bool get isLoggedIn => true;

  @override
  String? get currentUserEmail => 'qa@nibbles.test';

  /// MUST be an empty stream that never emits. `AuthService.build` listens
  /// here and flips `state = authState.session != null` on every emission —
  /// an emission with a null session would route the user to `/auth/login`.
  @override
  Stream<AuthState> get authStateStream => const Stream.empty();

  @override
  Future<Result<void>> signUp(String email, String password) async =>
      const Result.success(null);

  @override
  Future<Result<void>> signIn(String email, String password) async =>
      const Result.success(null);

  @override
  Future<Result<bool>> signInWithGoogle() async => const Result.success(true);

  @override
  Future<Result<bool>> signInWithApple() async => const Result.success(true);

  @override
  Future<Result<void>> signOut() async => const Result.success(null);

  @override
  Future<Result<void>> resetPassword(String email) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updatePassword(String newPassword) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateEmail(String newEmail) async =>
      const Result.success(null);
}

class _QaBabyProfileRepository implements BabyProfileRepository {
  _QaBabyProfileRepository();

  late final Baby _baby = _syntheticBaby();

  @override
  Future<Result<Baby>> createBaby(
    String name,
    DateTime dob, [
    Gender gender = Gender.preferNotToSay,
    List<bool> readinessSigns = const [],
  ]) async => Result.success(_baby);

  @override
  Future<Baby?> getBaby() async => _baby;

  @override
  Future<Result<Baby>> updateBaby(
    String babyId,
    String name,
    DateTime dob,
    Gender gender,
  ) async => Result.success(_baby);

  @override
  Future<Result<void>> createAllergenProgramState(String babyId) async =>
      const Result.success(null);

  @override
  Future<bool> isOnboardingCompleted() async => true;
}

class _QaAllergenRepository implements AllergenRepository {
  const _QaAllergenRepository();

  @override
  Future<Result<List<Allergen>>> getAllergens({bool refresh = false}) async =>
      const Result.success(<Allergen>[]);

  @override
  Future<Result<AllergenProgramState>> getProgramState(String babyId) async =>
      const Result.failure(UnknownException('QA bypass: no program state.'));

  @override
  Future<Result<void>> setSelectedAllergen(
    String babyId,
    String? allergenKey,
  ) async => const Result.success(null);

  @override
  Future<Result<List<AllergenLog>>> getLogs(
    String babyId, {
    String? allergenKey,
  }) async => const Result.success(<AllergenLog>[]);

  @override
  Future<Result<AllergenLog>> saveLog(AllergenLog log) async =>
      Result.success(log);

  @override
  Future<Result<AllergenLog>> updateLog(AllergenLog log) async =>
      Result.success(log);

  @override
  Future<Result<void>> deleteLog(String logId) async =>
      const Result.success(null);

  @override
  Future<Result<ReactionDetail>> saveReactionDetail(
    ReactionDetail detail,
  ) async => Result.success(detail);

  @override
  Future<Result<void>> deleteReactionDetail(String logId) async =>
      const Result.success(null);

  @override
  Future<Result<void>> advanceProgramState(
    String babyId,
    String nextAllergenKey,
    int nextSequenceOrder,
  ) async => const Result.success(null);

  @override
  Future<Result<void>> completeProgramState(String babyId) async =>
      const Result.success(null);

  @override
  Future<Result<ReactionDetail?>> getReactionDetail(String logId) async =>
      const Result.success(null);
}

class _QaMealPlanRepository implements MealPlanRepository {
  const _QaMealPlanRepository();

  @override
  Future<Result<List<MealPlanEntry>>> getWeekMeals(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  ) async => const Result.success(<MealPlanEntry>[]);

  @override
  Future<Result<List<MealPlanEntry>>> getEntriesInRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async => const Result.success(<MealPlanEntry>[]);

  @override
  Future<Result<List<MealPlanEntry>>> getAllEntries(String babyId) async =>
      const Result.success(<MealPlanEntry>[]);

  @override
  Future<Result<List<MealPlanEntry>>> getEntriesForPlan(String planId) async =>
      const Result.success(<MealPlanEntry>[]);

  @override
  Future<Result<MealPlanEntry>> assignRecipe(
    String babyId,
    String recipeId,
    DateTime planDate,
    TimeOfDay? mealTime,
  ) async => const Result.failure(UnknownException('QA bypass: noop.'));

  @override
  Future<Result<List<MealPlanEntry>>> appendBulk(
    List<MealPlanEntryInsert> entries,
  ) async => const Result.success(<MealPlanEntry>[]);

  @override
  Future<Result<void>> clearWeek(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  ) async => const Result.success(null);

  @override
  Future<Result<void>> deleteRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async => const Result.success(null);

  @override
  Future<Result<void>> removeEntry(String entryId) async =>
      const Result.success(null);

  @override
  Future<Result<void>> clearDay(String babyId, DateTime date) async =>
      const Result.success(null);

  @override
  Future<Result<MealPlan?>> getActivePlan(String babyId) async =>
      const Result.success(null);

  @override
  Future<Result<MealPlan>> createPlan(
    String babyId,
    DateTime start,
    DateTime end,
  ) async => const Result.failure(UnknownException('QA bypass: noop.'));

  @override
  Future<Result<void>> deletePlan(String planId) async =>
      const Result.success(null);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeControllerHash() => r'608a99151b6d36badce16c88599704a9fb32d2e4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$HomeController
    extends BuildlessAutoDisposeAsyncNotifier<HomeState> {
  late final String babyId;

  FutureOr<HomeState> build(String babyId);
}

/// Home redesign controller. Fetches the FULL dataset once so per-day slices
/// (see `homeDayViewProvider`) are pure client-side derivations.
///
/// Parallel-fetches:
///  1. Baby profile (greeting + age for guidance).
///  2. Allergen logs (status derivation + clean counts).
///  3. Program state (the "Start Introduce" selection overlay).
///  4. The current/active allergen (hero allergen widget).
///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
///
/// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
/// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
/// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
/// failures throw and surface as `AsyncValue.error`. A failed current-allergen
/// or program-state read degrades gracefully (no hero key / no overlay).
///
/// Copied from [HomeController].
@ProviderFor(HomeController)
const homeControllerProvider = HomeControllerFamily();

/// Home redesign controller. Fetches the FULL dataset once so per-day slices
/// (see `homeDayViewProvider`) are pure client-side derivations.
///
/// Parallel-fetches:
///  1. Baby profile (greeting + age for guidance).
///  2. Allergen logs (status derivation + clean counts).
///  3. Program state (the "Start Introduce" selection overlay).
///  4. The current/active allergen (hero allergen widget).
///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
///
/// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
/// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
/// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
/// failures throw and surface as `AsyncValue.error`. A failed current-allergen
/// or program-state read degrades gracefully (no hero key / no overlay).
///
/// Copied from [HomeController].
class HomeControllerFamily extends Family<AsyncValue<HomeState>> {
  /// Home redesign controller. Fetches the FULL dataset once so per-day slices
  /// (see `homeDayViewProvider`) are pure client-side derivations.
  ///
  /// Parallel-fetches:
  ///  1. Baby profile (greeting + age for guidance).
  ///  2. Allergen logs (status derivation + clean counts).
  ///  3. Program state (the "Start Introduce" selection overlay).
  ///  4. The current/active allergen (hero allergen widget).
  ///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
  ///
  /// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
  /// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
  /// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
  /// failures throw and surface as `AsyncValue.error`. A failed current-allergen
  /// or program-state read degrades gracefully (no hero key / no overlay).
  ///
  /// Copied from [HomeController].
  const HomeControllerFamily();

  /// Home redesign controller. Fetches the FULL dataset once so per-day slices
  /// (see `homeDayViewProvider`) are pure client-side derivations.
  ///
  /// Parallel-fetches:
  ///  1. Baby profile (greeting + age for guidance).
  ///  2. Allergen logs (status derivation + clean counts).
  ///  3. Program state (the "Start Introduce" selection overlay).
  ///  4. The current/active allergen (hero allergen widget).
  ///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
  ///
  /// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
  /// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
  /// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
  /// failures throw and surface as `AsyncValue.error`. A failed current-allergen
  /// or program-state read degrades gracefully (no hero key / no overlay).
  ///
  /// Copied from [HomeController].
  HomeControllerProvider call(String babyId) {
    return HomeControllerProvider(babyId);
  }

  @override
  HomeControllerProvider getProviderOverride(
    covariant HomeControllerProvider provider,
  ) {
    return call(provider.babyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'homeControllerProvider';
}

/// Home redesign controller. Fetches the FULL dataset once so per-day slices
/// (see `homeDayViewProvider`) are pure client-side derivations.
///
/// Parallel-fetches:
///  1. Baby profile (greeting + age for guidance).
///  2. Allergen logs (status derivation + clean counts).
///  3. Program state (the "Start Introduce" selection overlay).
///  4. The current/active allergen (hero allergen widget).
///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
///
/// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
/// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
/// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
/// failures throw and surface as `AsyncValue.error`. A failed current-allergen
/// or program-state read degrades gracefully (no hero key / no overlay).
///
/// Copied from [HomeController].
class HomeControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<HomeController, HomeState> {
  /// Home redesign controller. Fetches the FULL dataset once so per-day slices
  /// (see `homeDayViewProvider`) are pure client-side derivations.
  ///
  /// Parallel-fetches:
  ///  1. Baby profile (greeting + age for guidance).
  ///  2. Allergen logs (status derivation + clean counts).
  ///  3. Program state (the "Start Introduce" selection overlay).
  ///  4. The current/active allergen (hero allergen widget).
  ///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
  ///
  /// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
  /// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
  /// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
  /// failures throw and surface as `AsyncValue.error`. A failed current-allergen
  /// or program-state read degrades gracefully (no hero key / no overlay).
  ///
  /// Copied from [HomeController].
  HomeControllerProvider(String babyId)
    : this._internal(
        () => HomeController()..babyId = babyId,
        from: homeControllerProvider,
        name: r'homeControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$homeControllerHash,
        dependencies: HomeControllerFamily._dependencies,
        allTransitiveDependencies:
            HomeControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  HomeControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.babyId,
  }) : super.internal();

  final String babyId;

  @override
  FutureOr<HomeState> runNotifierBuild(covariant HomeController notifier) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(HomeController Function() create) {
    return ProviderOverride(
      origin: this,
      override: HomeControllerProvider._internal(
        () => create()..babyId = babyId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        babyId: babyId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<HomeController, HomeState>
  createElement() {
    return _HomeControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeControllerProvider && other.babyId == babyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, babyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HomeControllerRef on AutoDisposeAsyncNotifierProviderRef<HomeState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _HomeControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HomeController, HomeState>
    with HomeControllerRef {
  _HomeControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as HomeControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

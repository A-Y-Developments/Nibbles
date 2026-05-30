// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen_tracker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allergenTrackerControllerHash() =>
    r'1500b3df0eba3539b564a0212d62f6eeb0d6ade4';

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

abstract class _$AllergenTrackerController
    extends BuildlessAutoDisposeAsyncNotifier<AllergenTrackerState> {
  late final String babyId;

  FutureOr<AllergenTrackerState> build(String babyId);
}

/// Loads the data backing the redesigned Allergen Tracker board.
///
/// Composes three reads in parallel:
///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
///    (NIB-126). Drives the ring, stat columns and per-card badges.
///  - `getAllergens()`              — name + emoji + display order.
///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
///    the per-card 0/3 progress.
///
/// The legacy `getAllergenBoardSummary` + `getProgramState` +
/// `advanceToNextAllergen` flow is intentionally not used here — the
/// locked sequence is retired (NIB-120).
///
/// Copied from [AllergenTrackerController].
@ProviderFor(AllergenTrackerController)
const allergenTrackerControllerProvider = AllergenTrackerControllerFamily();

/// Loads the data backing the redesigned Allergen Tracker board.
///
/// Composes three reads in parallel:
///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
///    (NIB-126). Drives the ring, stat columns and per-card badges.
///  - `getAllergens()`              — name + emoji + display order.
///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
///    the per-card 0/3 progress.
///
/// The legacy `getAllergenBoardSummary` + `getProgramState` +
/// `advanceToNextAllergen` flow is intentionally not used here — the
/// locked sequence is retired (NIB-120).
///
/// Copied from [AllergenTrackerController].
class AllergenTrackerControllerFamily
    extends Family<AsyncValue<AllergenTrackerState>> {
  /// Loads the data backing the redesigned Allergen Tracker board.
  ///
  /// Composes three reads in parallel:
  ///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
  ///    (NIB-126). Drives the ring, stat columns and per-card badges.
  ///  - `getAllergens()`              — name + emoji + display order.
  ///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
  ///    the per-card 0/3 progress.
  ///
  /// The legacy `getAllergenBoardSummary` + `getProgramState` +
  /// `advanceToNextAllergen` flow is intentionally not used here — the
  /// locked sequence is retired (NIB-120).
  ///
  /// Copied from [AllergenTrackerController].
  const AllergenTrackerControllerFamily();

  /// Loads the data backing the redesigned Allergen Tracker board.
  ///
  /// Composes three reads in parallel:
  ///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
  ///    (NIB-126). Drives the ring, stat columns and per-card badges.
  ///  - `getAllergens()`              — name + emoji + display order.
  ///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
  ///    the per-card 0/3 progress.
  ///
  /// The legacy `getAllergenBoardSummary` + `getProgramState` +
  /// `advanceToNextAllergen` flow is intentionally not used here — the
  /// locked sequence is retired (NIB-120).
  ///
  /// Copied from [AllergenTrackerController].
  AllergenTrackerControllerProvider call(String babyId) {
    return AllergenTrackerControllerProvider(babyId);
  }

  @override
  AllergenTrackerControllerProvider getProviderOverride(
    covariant AllergenTrackerControllerProvider provider,
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
  String? get name => r'allergenTrackerControllerProvider';
}

/// Loads the data backing the redesigned Allergen Tracker board.
///
/// Composes three reads in parallel:
///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
///    (NIB-126). Drives the ring, stat columns and per-card badges.
///  - `getAllergens()`              — name + emoji + display order.
///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
///    the per-card 0/3 progress.
///
/// The legacy `getAllergenBoardSummary` + `getProgramState` +
/// `advanceToNextAllergen` flow is intentionally not used here — the
/// locked sequence is retired (NIB-120).
///
/// Copied from [AllergenTrackerController].
class AllergenTrackerControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AllergenTrackerController,
          AllergenTrackerState
        > {
  /// Loads the data backing the redesigned Allergen Tracker board.
  ///
  /// Composes three reads in parallel:
  ///  - `getAllergenStatuses(babyId)` — the authoritative per-allergen status
  ///    (NIB-126). Drives the ring, stat columns and per-card badges.
  ///  - `getAllergens()`              — name + emoji + display order.
  ///  - `getLogs(babyId)`             — raw logs for the Reaction Log list and
  ///    the per-card 0/3 progress.
  ///
  /// The legacy `getAllergenBoardSummary` + `getProgramState` +
  /// `advanceToNextAllergen` flow is intentionally not used here — the
  /// locked sequence is retired (NIB-120).
  ///
  /// Copied from [AllergenTrackerController].
  AllergenTrackerControllerProvider(String babyId)
    : this._internal(
        () => AllergenTrackerController()..babyId = babyId,
        from: allergenTrackerControllerProvider,
        name: r'allergenTrackerControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allergenTrackerControllerHash,
        dependencies: AllergenTrackerControllerFamily._dependencies,
        allTransitiveDependencies:
            AllergenTrackerControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  AllergenTrackerControllerProvider._internal(
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
  FutureOr<AllergenTrackerState> runNotifierBuild(
    covariant AllergenTrackerController notifier,
  ) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(AllergenTrackerController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllergenTrackerControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<
    AllergenTrackerController,
    AllergenTrackerState
  >
  createElement() {
    return _AllergenTrackerControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllergenTrackerControllerProvider && other.babyId == babyId;
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
mixin AllergenTrackerControllerRef
    on AutoDisposeAsyncNotifierProviderRef<AllergenTrackerState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _AllergenTrackerControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AllergenTrackerController,
          AllergenTrackerState
        >
    with AllergenTrackerControllerRef {
  _AllergenTrackerControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as AllergenTrackerControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

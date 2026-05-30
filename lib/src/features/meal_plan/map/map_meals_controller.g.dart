// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_meals_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mealPrepCrashRecorderHash() =>
    r'61917b9a106232580c8e34736777bb7e03961138';

/// Provider for the [MealPrepCrashRecorderFn]. Tests override this to capture
/// the recorded payload without hitting Crashlytics.
///
/// Copied from [mealPrepCrashRecorder].
@ProviderFor(mealPrepCrashRecorder)
final mealPrepCrashRecorderProvider =
    Provider<MealPrepCrashRecorderFn>.internal(
      mealPrepCrashRecorder,
      name: r'mealPrepCrashRecorderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mealPrepCrashRecorderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MealPrepCrashRecorderRef = ProviderRef<MealPrepCrashRecorderFn>;
String _$mapMealsControllerHash() =>
    r'3bd04cb23a21215baf69a349c8514a2adea03309';

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

abstract class _$MapMealsController
    extends BuildlessAutoDisposeNotifier<MapMealsState> {
  late final MapMealsArgs args;

  MapMealsState build(MapMealsArgs args);
}

/// Drives the NIB-95 Map Meals Plan screen.
///
/// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
/// the currently selected day chip, and the in-progress recipe→day
/// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
/// (APPEND only — no replace semantics per NIB-120).
///
/// Copied from [MapMealsController].
@ProviderFor(MapMealsController)
const mapMealsControllerProvider = MapMealsControllerFamily();

/// Drives the NIB-95 Map Meals Plan screen.
///
/// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
/// the currently selected day chip, and the in-progress recipe→day
/// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
/// (APPEND only — no replace semantics per NIB-120).
///
/// Copied from [MapMealsController].
class MapMealsControllerFamily extends Family<MapMealsState> {
  /// Drives the NIB-95 Map Meals Plan screen.
  ///
  /// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
  /// the currently selected day chip, and the in-progress recipe→day
  /// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
  /// (APPEND only — no replace semantics per NIB-120).
  ///
  /// Copied from [MapMealsController].
  const MapMealsControllerFamily();

  /// Drives the NIB-95 Map Meals Plan screen.
  ///
  /// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
  /// the currently selected day chip, and the in-progress recipe→day
  /// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
  /// (APPEND only — no replace semantics per NIB-120).
  ///
  /// Copied from [MapMealsController].
  MapMealsControllerProvider call(MapMealsArgs args) {
    return MapMealsControllerProvider(args);
  }

  @override
  MapMealsControllerProvider getProviderOverride(
    covariant MapMealsControllerProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mapMealsControllerProvider';
}

/// Drives the NIB-95 Map Meals Plan screen.
///
/// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
/// the currently selected day chip, and the in-progress recipe→day
/// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
/// (APPEND only — no replace semantics per NIB-120).
///
/// Copied from [MapMealsController].
class MapMealsControllerProvider
    extends AutoDisposeNotifierProviderImpl<MapMealsController, MapMealsState> {
  /// Drives the NIB-95 Map Meals Plan screen.
  ///
  /// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
  /// the currently selected day chip, and the in-progress recipe→day
  /// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
  /// (APPEND only — no replace semantics per NIB-120).
  ///
  /// Copied from [MapMealsController].
  MapMealsControllerProvider(MapMealsArgs args)
    : this._internal(
        () => MapMealsController()..args = args,
        from: mapMealsControllerProvider,
        name: r'mapMealsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mapMealsControllerHash,
        dependencies: MapMealsControllerFamily._dependencies,
        allTransitiveDependencies:
            MapMealsControllerFamily._allTransitiveDependencies,
        args: args,
      );

  MapMealsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final MapMealsArgs args;

  @override
  MapMealsState runNotifierBuild(covariant MapMealsController notifier) {
    return notifier.build(args);
  }

  @override
  Override overrideWith(MapMealsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MapMealsControllerProvider._internal(
        () => create()..args = args,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MapMealsController, MapMealsState>
  createElement() {
    return _MapMealsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MapMealsControllerProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MapMealsControllerRef on AutoDisposeNotifierProviderRef<MapMealsState> {
  /// The parameter `args` of this provider.
  MapMealsArgs get args;
}

class _MapMealsControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<MapMealsController, MapMealsState>
    with MapMealsControllerRef {
  _MapMealsControllerProviderElement(super.provider);

  @override
  MapMealsArgs get args => (origin as MapMealsControllerProvider).args;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

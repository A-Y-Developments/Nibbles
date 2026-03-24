// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mealPlanControllerHash() =>
    r'c9c6f94b859ce94fcb466e3f83250fa7b259c68b';

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

abstract class _$MealPlanController
    extends BuildlessAutoDisposeAsyncNotifier<MealPlanState> {
  late final String babyId;

  FutureOr<MealPlanState> build(String babyId);
}

/// See also [MealPlanController].
@ProviderFor(MealPlanController)
const mealPlanControllerProvider = MealPlanControllerFamily();

/// See also [MealPlanController].
class MealPlanControllerFamily extends Family<AsyncValue<MealPlanState>> {
  /// See also [MealPlanController].
  const MealPlanControllerFamily();

  /// See also [MealPlanController].
  MealPlanControllerProvider call(String babyId) {
    return MealPlanControllerProvider(babyId);
  }

  @override
  MealPlanControllerProvider getProviderOverride(
    covariant MealPlanControllerProvider provider,
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
  String? get name => r'mealPlanControllerProvider';
}

/// See also [MealPlanController].
class MealPlanControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MealPlanController,
          MealPlanState
        > {
  /// See also [MealPlanController].
  MealPlanControllerProvider(String babyId)
    : this._internal(
        () => MealPlanController()..babyId = babyId,
        from: mealPlanControllerProvider,
        name: r'mealPlanControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mealPlanControllerHash,
        dependencies: MealPlanControllerFamily._dependencies,
        allTransitiveDependencies:
            MealPlanControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  MealPlanControllerProvider._internal(
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
  FutureOr<MealPlanState> runNotifierBuild(
    covariant MealPlanController notifier,
  ) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(MealPlanController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MealPlanControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MealPlanController, MealPlanState>
  createElement() {
    return _MealPlanControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealPlanControllerProvider && other.babyId == babyId;
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
mixin MealPlanControllerRef
    on AutoDisposeAsyncNotifierProviderRef<MealPlanState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _MealPlanControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MealPlanController,
          MealPlanState
        >
    with MealPlanControllerRef {
  _MealPlanControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as MealPlanControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeDetailControllerHash() =>
    r'a923f19625fd19a4dec3d1decc0224460d006d49';

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

abstract class _$RecipeDetailController
    extends BuildlessAutoDisposeAsyncNotifier<RecipeDetailState> {
  late final String babyId;
  late final String recipeId;

  FutureOr<RecipeDetailState> build(String babyId, String recipeId);
}

/// See also [RecipeDetailController].
@ProviderFor(RecipeDetailController)
const recipeDetailControllerProvider = RecipeDetailControllerFamily();

/// See also [RecipeDetailController].
class RecipeDetailControllerFamily
    extends Family<AsyncValue<RecipeDetailState>> {
  /// See also [RecipeDetailController].
  const RecipeDetailControllerFamily();

  /// See also [RecipeDetailController].
  RecipeDetailControllerProvider call(String babyId, String recipeId) {
    return RecipeDetailControllerProvider(babyId, recipeId);
  }

  @override
  RecipeDetailControllerProvider getProviderOverride(
    covariant RecipeDetailControllerProvider provider,
  ) {
    return call(provider.babyId, provider.recipeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipeDetailControllerProvider';
}

/// See also [RecipeDetailController].
class RecipeDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          RecipeDetailController,
          RecipeDetailState
        > {
  /// See also [RecipeDetailController].
  RecipeDetailControllerProvider(String babyId, String recipeId)
    : this._internal(
        () => RecipeDetailController()
          ..babyId = babyId
          ..recipeId = recipeId,
        from: recipeDetailControllerProvider,
        name: r'recipeDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipeDetailControllerHash,
        dependencies: RecipeDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            RecipeDetailControllerFamily._allTransitiveDependencies,
        babyId: babyId,
        recipeId: recipeId,
      );

  RecipeDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.babyId,
    required this.recipeId,
  }) : super.internal();

  final String babyId;
  final String recipeId;

  @override
  FutureOr<RecipeDetailState> runNotifierBuild(
    covariant RecipeDetailController notifier,
  ) {
    return notifier.build(babyId, recipeId);
  }

  @override
  Override overrideWith(RecipeDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecipeDetailControllerProvider._internal(
        () => create()
          ..babyId = babyId
          ..recipeId = recipeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        babyId: babyId,
        recipeId: recipeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    RecipeDetailController,
    RecipeDetailState
  >
  createElement() {
    return _RecipeDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeDetailControllerProvider &&
        other.babyId == babyId &&
        other.recipeId == recipeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, babyId.hashCode);
    hash = _SystemHash.combine(hash, recipeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipeDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<RecipeDetailState> {
  /// The parameter `babyId` of this provider.
  String get babyId;

  /// The parameter `recipeId` of this provider.
  String get recipeId;
}

class _RecipeDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          RecipeDetailController,
          RecipeDetailState
        >
    with RecipeDetailControllerRef {
  _RecipeDetailControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as RecipeDetailControllerProvider).babyId;
  @override
  String get recipeId => (origin as RecipeDetailControllerProvider).recipeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

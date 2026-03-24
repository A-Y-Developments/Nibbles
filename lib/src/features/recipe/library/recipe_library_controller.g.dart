// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeLibraryControllerHash() =>
    r'ebad0ec9e1eac7a4d8dc58cd5d1d2a6cd25656d4';

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

abstract class _$RecipeLibraryController
    extends BuildlessAutoDisposeAsyncNotifier<RecipeLibraryState> {
  late final String babyId;

  FutureOr<RecipeLibraryState> build(String babyId);
}

/// See also [RecipeLibraryController].
@ProviderFor(RecipeLibraryController)
const recipeLibraryControllerProvider = RecipeLibraryControllerFamily();

/// See also [RecipeLibraryController].
class RecipeLibraryControllerFamily
    extends Family<AsyncValue<RecipeLibraryState>> {
  /// See also [RecipeLibraryController].
  const RecipeLibraryControllerFamily();

  /// See also [RecipeLibraryController].
  RecipeLibraryControllerProvider call(String babyId) {
    return RecipeLibraryControllerProvider(babyId);
  }

  @override
  RecipeLibraryControllerProvider getProviderOverride(
    covariant RecipeLibraryControllerProvider provider,
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
  String? get name => r'recipeLibraryControllerProvider';
}

/// See also [RecipeLibraryController].
class RecipeLibraryControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          RecipeLibraryController,
          RecipeLibraryState
        > {
  /// See also [RecipeLibraryController].
  RecipeLibraryControllerProvider(String babyId)
    : this._internal(
        () => RecipeLibraryController()..babyId = babyId,
        from: recipeLibraryControllerProvider,
        name: r'recipeLibraryControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipeLibraryControllerHash,
        dependencies: RecipeLibraryControllerFamily._dependencies,
        allTransitiveDependencies:
            RecipeLibraryControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  RecipeLibraryControllerProvider._internal(
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
  FutureOr<RecipeLibraryState> runNotifierBuild(
    covariant RecipeLibraryController notifier,
  ) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(RecipeLibraryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecipeLibraryControllerProvider._internal(
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
    RecipeLibraryController,
    RecipeLibraryState
  >
  createElement() {
    return _RecipeLibraryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeLibraryControllerProvider && other.babyId == babyId;
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
mixin RecipeLibraryControllerRef
    on AutoDisposeAsyncNotifierProviderRef<RecipeLibraryState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _RecipeLibraryControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          RecipeLibraryController,
          RecipeLibraryState
        >
    with RecipeLibraryControllerRef {
  _RecipeLibraryControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as RecipeLibraryControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeLibraryControllerHash() =>
    r'f1d4e66df0fe4a1d0f08daa4e7bf0d382402ca99';

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

/// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
///
/// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
/// category grouping, [AllergenService.getAllergenStatuses] for the
/// ongoing-allergen recommendation header, and
/// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
/// The first-launch 'Read Guide' banner state is read synchronously from
/// [LocalFlagService.isStartingGuideSeen].
///
/// Copied from [RecipeLibraryController].
@ProviderFor(RecipeLibraryController)
const recipeLibraryControllerProvider = RecipeLibraryControllerFamily();

/// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
///
/// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
/// category grouping, [AllergenService.getAllergenStatuses] for the
/// ongoing-allergen recommendation header, and
/// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
/// The first-launch 'Read Guide' banner state is read synchronously from
/// [LocalFlagService.isStartingGuideSeen].
///
/// Copied from [RecipeLibraryController].
class RecipeLibraryControllerFamily
    extends Family<AsyncValue<RecipeLibraryState>> {
  /// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
  ///
  /// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
  /// category grouping, [AllergenService.getAllergenStatuses] for the
  /// ongoing-allergen recommendation header, and
  /// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
  /// The first-launch 'Read Guide' banner state is read synchronously from
  /// [LocalFlagService.isStartingGuideSeen].
  ///
  /// Copied from [RecipeLibraryController].
  const RecipeLibraryControllerFamily();

  /// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
  ///
  /// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
  /// category grouping, [AllergenService.getAllergenStatuses] for the
  /// ongoing-allergen recommendation header, and
  /// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
  /// The first-launch 'Read Guide' banner state is read synchronously from
  /// [LocalFlagService.isStartingGuideSeen].
  ///
  /// Copied from [RecipeLibraryController].
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

/// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
///
/// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
/// category grouping, [AllergenService.getAllergenStatuses] for the
/// ongoing-allergen recommendation header, and
/// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
/// The first-launch 'Read Guide' banner state is read synchronously from
/// [LocalFlagService.isStartingGuideSeen].
///
/// Copied from [RecipeLibraryController].
class RecipeLibraryControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          RecipeLibraryController,
          RecipeLibraryState
        > {
  /// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
  ///
  /// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
  /// category grouping, [AllergenService.getAllergenStatuses] for the
  /// ongoing-allergen recommendation header, and
  /// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
  /// The first-launch 'Read Guide' banner state is read synchronously from
  /// [LocalFlagService.isStartingGuideSeen].
  ///
  /// Copied from [RecipeLibraryController].
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allergenDetailControllerHash() =>
    r'419bc2ea1dcae45c9ddb8a436ae85181ee3c2c00';

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

abstract class _$AllergenDetailController
    extends BuildlessAutoDisposeAsyncNotifier<AllergenDetailState> {
  late final String allergenKey;

  FutureOr<AllergenDetailState> build(String allergenKey);
}

/// See also [AllergenDetailController].
@ProviderFor(AllergenDetailController)
const allergenDetailControllerProvider = AllergenDetailControllerFamily();

/// See also [AllergenDetailController].
class AllergenDetailControllerFamily
    extends Family<AsyncValue<AllergenDetailState>> {
  /// See also [AllergenDetailController].
  const AllergenDetailControllerFamily();

  /// See also [AllergenDetailController].
  AllergenDetailControllerProvider call(String allergenKey) {
    return AllergenDetailControllerProvider(allergenKey);
  }

  @override
  AllergenDetailControllerProvider getProviderOverride(
    covariant AllergenDetailControllerProvider provider,
  ) {
    return call(provider.allergenKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allergenDetailControllerProvider';
}

/// See also [AllergenDetailController].
class AllergenDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AllergenDetailController,
          AllergenDetailState
        > {
  /// See also [AllergenDetailController].
  AllergenDetailControllerProvider(String allergenKey)
    : this._internal(
        () => AllergenDetailController()..allergenKey = allergenKey,
        from: allergenDetailControllerProvider,
        name: r'allergenDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allergenDetailControllerHash,
        dependencies: AllergenDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AllergenDetailControllerFamily._allTransitiveDependencies,
        allergenKey: allergenKey,
      );

  AllergenDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.allergenKey,
  }) : super.internal();

  final String allergenKey;

  @override
  FutureOr<AllergenDetailState> runNotifierBuild(
    covariant AllergenDetailController notifier,
  ) {
    return notifier.build(allergenKey);
  }

  @override
  Override overrideWith(AllergenDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllergenDetailControllerProvider._internal(
        () => create()..allergenKey = allergenKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        allergenKey: allergenKey,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    AllergenDetailController,
    AllergenDetailState
  >
  createElement() {
    return _AllergenDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllergenDetailControllerProvider &&
        other.allergenKey == allergenKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, allergenKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllergenDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<AllergenDetailState> {
  /// The parameter `allergenKey` of this provider.
  String get allergenKey;
}

class _AllergenDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AllergenDetailController,
          AllergenDetailState
        >
    with AllergenDetailControllerRef {
  _AllergenDetailControllerProviderElement(super.provider);

  @override
  String get allergenKey =>
      (origin as AllergenDetailControllerProvider).allergenKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

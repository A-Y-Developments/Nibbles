// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingListControllerHash() =>
    r'5a8d0c193221d8b4281991951a919f13ab35c5e1';

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

abstract class _$ShoppingListController
    extends BuildlessAutoDisposeAsyncNotifier<ShoppingListState> {
  late final String babyId;

  FutureOr<ShoppingListState> build(String babyId);
}

/// See also [ShoppingListController].
@ProviderFor(ShoppingListController)
const shoppingListControllerProvider = ShoppingListControllerFamily();

/// See also [ShoppingListController].
class ShoppingListControllerFamily
    extends Family<AsyncValue<ShoppingListState>> {
  /// See also [ShoppingListController].
  const ShoppingListControllerFamily();

  /// See also [ShoppingListController].
  ShoppingListControllerProvider call(String babyId) {
    return ShoppingListControllerProvider(babyId);
  }

  @override
  ShoppingListControllerProvider getProviderOverride(
    covariant ShoppingListControllerProvider provider,
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
  String? get name => r'shoppingListControllerProvider';
}

/// See also [ShoppingListController].
class ShoppingListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ShoppingListController,
          ShoppingListState
        > {
  /// See also [ShoppingListController].
  ShoppingListControllerProvider(String babyId)
    : this._internal(
        () => ShoppingListController()..babyId = babyId,
        from: shoppingListControllerProvider,
        name: r'shoppingListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shoppingListControllerHash,
        dependencies: ShoppingListControllerFamily._dependencies,
        allTransitiveDependencies:
            ShoppingListControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  ShoppingListControllerProvider._internal(
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
  FutureOr<ShoppingListState> runNotifierBuild(
    covariant ShoppingListController notifier,
  ) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(ShoppingListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListControllerProvider._internal(
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
    ShoppingListController,
    ShoppingListState
  >
  createElement() {
    return _ShoppingListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListControllerProvider && other.babyId == babyId;
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
mixin ShoppingListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ShoppingListState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _ShoppingListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ShoppingListController,
          ShoppingListState
        >
    with ShoppingListControllerRef {
  _ShoppingListControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as ShoppingListControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_day_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeDayViewHash() => r'fae18ee1329eb282551005a9caa34b8e8faa0a7f';

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

/// Derived view for the selected day. Watches the controller (full dataset)
/// and the selected date, then slices client-side. Returns an empty view
/// (still flagging `isToday`) while the controller is loading or errored.
///
/// Copied from [homeDayView].
@ProviderFor(homeDayView)
const homeDayViewProvider = HomeDayViewFamily();

/// Derived view for the selected day. Watches the controller (full dataset)
/// and the selected date, then slices client-side. Returns an empty view
/// (still flagging `isToday`) while the controller is loading or errored.
///
/// Copied from [homeDayView].
class HomeDayViewFamily extends Family<HomeDayView> {
  /// Derived view for the selected day. Watches the controller (full dataset)
  /// and the selected date, then slices client-side. Returns an empty view
  /// (still flagging `isToday`) while the controller is loading or errored.
  ///
  /// Copied from [homeDayView].
  const HomeDayViewFamily();

  /// Derived view for the selected day. Watches the controller (full dataset)
  /// and the selected date, then slices client-side. Returns an empty view
  /// (still flagging `isToday`) while the controller is loading or errored.
  ///
  /// Copied from [homeDayView].
  HomeDayViewProvider call(String babyId) {
    return HomeDayViewProvider(babyId);
  }

  @override
  HomeDayViewProvider getProviderOverride(
    covariant HomeDayViewProvider provider,
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
  String? get name => r'homeDayViewProvider';
}

/// Derived view for the selected day. Watches the controller (full dataset)
/// and the selected date, then slices client-side. Returns an empty view
/// (still flagging `isToday`) while the controller is loading or errored.
///
/// Copied from [homeDayView].
class HomeDayViewProvider extends AutoDisposeProvider<HomeDayView> {
  /// Derived view for the selected day. Watches the controller (full dataset)
  /// and the selected date, then slices client-side. Returns an empty view
  /// (still flagging `isToday`) while the controller is loading or errored.
  ///
  /// Copied from [homeDayView].
  HomeDayViewProvider(String babyId)
    : this._internal(
        (ref) => homeDayView(ref as HomeDayViewRef, babyId),
        from: homeDayViewProvider,
        name: r'homeDayViewProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$homeDayViewHash,
        dependencies: HomeDayViewFamily._dependencies,
        allTransitiveDependencies: HomeDayViewFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  HomeDayViewProvider._internal(
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
  Override overrideWith(HomeDayView Function(HomeDayViewRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: HomeDayViewProvider._internal(
        (ref) => create(ref as HomeDayViewRef),
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
  AutoDisposeProviderElement<HomeDayView> createElement() {
    return _HomeDayViewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeDayViewProvider && other.babyId == babyId;
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
mixin HomeDayViewRef on AutoDisposeProviderRef<HomeDayView> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _HomeDayViewProviderElement
    extends AutoDisposeProviderElement<HomeDayView>
    with HomeDayViewRef {
  _HomeDayViewProviderElement(super.provider);

  @override
  String get babyId => (origin as HomeDayViewProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

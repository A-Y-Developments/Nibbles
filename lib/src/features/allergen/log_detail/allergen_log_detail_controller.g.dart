// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen_log_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allergenLogDetailControllerHash() =>
    r'8410980c8c8cc54c7280bf300058880f1b85358d';

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

abstract class _$AllergenLogDetailController
    extends BuildlessAutoDisposeAsyncNotifier<AllergenLogDetailState> {
  late final String allergenKey;
  late final String logId;

  FutureOr<AllergenLogDetailState> build(String allergenKey, String logId);
}

/// Hydrates a single [AllergenLog] for the read-only detail screen.
///
/// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
/// architecture rule — services own repository access. The exposed log number
/// is derived from the log's position in the oldest-first sequence so it
/// matches the "Log N" labels rendered on the tracker and allergen detail.
///
/// Copied from [AllergenLogDetailController].
@ProviderFor(AllergenLogDetailController)
const allergenLogDetailControllerProvider = AllergenLogDetailControllerFamily();

/// Hydrates a single [AllergenLog] for the read-only detail screen.
///
/// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
/// architecture rule — services own repository access. The exposed log number
/// is derived from the log's position in the oldest-first sequence so it
/// matches the "Log N" labels rendered on the tracker and allergen detail.
///
/// Copied from [AllergenLogDetailController].
class AllergenLogDetailControllerFamily
    extends Family<AsyncValue<AllergenLogDetailState>> {
  /// Hydrates a single [AllergenLog] for the read-only detail screen.
  ///
  /// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
  /// architecture rule — services own repository access. The exposed log number
  /// is derived from the log's position in the oldest-first sequence so it
  /// matches the "Log N" labels rendered on the tracker and allergen detail.
  ///
  /// Copied from [AllergenLogDetailController].
  const AllergenLogDetailControllerFamily();

  /// Hydrates a single [AllergenLog] for the read-only detail screen.
  ///
  /// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
  /// architecture rule — services own repository access. The exposed log number
  /// is derived from the log's position in the oldest-first sequence so it
  /// matches the "Log N" labels rendered on the tracker and allergen detail.
  ///
  /// Copied from [AllergenLogDetailController].
  AllergenLogDetailControllerProvider call(String allergenKey, String logId) {
    return AllergenLogDetailControllerProvider(allergenKey, logId);
  }

  @override
  AllergenLogDetailControllerProvider getProviderOverride(
    covariant AllergenLogDetailControllerProvider provider,
  ) {
    return call(provider.allergenKey, provider.logId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allergenLogDetailControllerProvider';
}

/// Hydrates a single [AllergenLog] for the read-only detail screen.
///
/// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
/// architecture rule — services own repository access. The exposed log number
/// is derived from the log's position in the oldest-first sequence so it
/// matches the "Log N" labels rendered on the tracker and allergen detail.
///
/// Copied from [AllergenLogDetailController].
class AllergenLogDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AllergenLogDetailController,
          AllergenLogDetailState
        > {
  /// Hydrates a single [AllergenLog] for the read-only detail screen.
  ///
  /// Goes through [AllergenService.getLogs] (filtered by allergen key) per the
  /// architecture rule — services own repository access. The exposed log number
  /// is derived from the log's position in the oldest-first sequence so it
  /// matches the "Log N" labels rendered on the tracker and allergen detail.
  ///
  /// Copied from [AllergenLogDetailController].
  AllergenLogDetailControllerProvider(String allergenKey, String logId)
    : this._internal(
        () => AllergenLogDetailController()
          ..allergenKey = allergenKey
          ..logId = logId,
        from: allergenLogDetailControllerProvider,
        name: r'allergenLogDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allergenLogDetailControllerHash,
        dependencies: AllergenLogDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AllergenLogDetailControllerFamily._allTransitiveDependencies,
        allergenKey: allergenKey,
        logId: logId,
      );

  AllergenLogDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.allergenKey,
    required this.logId,
  }) : super.internal();

  final String allergenKey;
  final String logId;

  @override
  FutureOr<AllergenLogDetailState> runNotifierBuild(
    covariant AllergenLogDetailController notifier,
  ) {
    return notifier.build(allergenKey, logId);
  }

  @override
  Override overrideWith(AllergenLogDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllergenLogDetailControllerProvider._internal(
        () => create()
          ..allergenKey = allergenKey
          ..logId = logId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        allergenKey: allergenKey,
        logId: logId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    AllergenLogDetailController,
    AllergenLogDetailState
  >
  createElement() {
    return _AllergenLogDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllergenLogDetailControllerProvider &&
        other.allergenKey == allergenKey &&
        other.logId == logId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, allergenKey.hashCode);
    hash = _SystemHash.combine(hash, logId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllergenLogDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<AllergenLogDetailState> {
  /// The parameter `allergenKey` of this provider.
  String get allergenKey;

  /// The parameter `logId` of this provider.
  String get logId;
}

class _AllergenLogDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AllergenLogDetailController,
          AllergenLogDetailState
        >
    with AllergenLogDetailControllerRef {
  _AllergenLogDetailControllerProviderElement(super.provider);

  @override
  String get allergenKey =>
      (origin as AllergenLogDetailControllerProvider).allergenKey;
  @override
  String get logId => (origin as AllergenLogDetailControllerProvider).logId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

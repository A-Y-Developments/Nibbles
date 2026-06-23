// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileControllerHash() => r'2e958fc61448985e4cd0be67908720ed8dd2d656';

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

abstract class _$ProfileController
    extends BuildlessAutoDisposeAsyncNotifier<ProfileState> {
  late final String babyId;

  FutureOr<ProfileState> build(String babyId);
}

/// `babyId` is retained on the family for back-compat with
/// `profile_edit_screen.dart` which still calls
/// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
/// is not consumed here — `BabyProfileService.getBaby()` resolves the active
/// baby from the auth session.
///
/// Copied from [ProfileController].
@ProviderFor(ProfileController)
const profileControllerProvider = ProfileControllerFamily();

/// `babyId` is retained on the family for back-compat with
/// `profile_edit_screen.dart` which still calls
/// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
/// is not consumed here — `BabyProfileService.getBaby()` resolves the active
/// baby from the auth session.
///
/// Copied from [ProfileController].
class ProfileControllerFamily extends Family<AsyncValue<ProfileState>> {
  /// `babyId` is retained on the family for back-compat with
  /// `profile_edit_screen.dart` which still calls
  /// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
  /// is not consumed here — `BabyProfileService.getBaby()` resolves the active
  /// baby from the auth session.
  ///
  /// Copied from [ProfileController].
  const ProfileControllerFamily();

  /// `babyId` is retained on the family for back-compat with
  /// `profile_edit_screen.dart` which still calls
  /// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
  /// is not consumed here — `BabyProfileService.getBaby()` resolves the active
  /// baby from the auth session.
  ///
  /// Copied from [ProfileController].
  ProfileControllerProvider call(String babyId) {
    return ProfileControllerProvider(babyId);
  }

  @override
  ProfileControllerProvider getProviderOverride(
    covariant ProfileControllerProvider provider,
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
  String? get name => r'profileControllerProvider';
}

/// `babyId` is retained on the family for back-compat with
/// `profile_edit_screen.dart` which still calls
/// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
/// is not consumed here — `BabyProfileService.getBaby()` resolves the active
/// baby from the auth session.
///
/// Copied from [ProfileController].
class ProfileControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ProfileController, ProfileState> {
  /// `babyId` is retained on the family for back-compat with
  /// `profile_edit_screen.dart` which still calls
  /// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
  /// is not consumed here — `BabyProfileService.getBaby()` resolves the active
  /// baby from the auth session.
  ///
  /// Copied from [ProfileController].
  ProfileControllerProvider(String babyId)
    : this._internal(
        () => ProfileController()..babyId = babyId,
        from: profileControllerProvider,
        name: r'profileControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileControllerHash,
        dependencies: ProfileControllerFamily._dependencies,
        allTransitiveDependencies:
            ProfileControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  ProfileControllerProvider._internal(
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
  FutureOr<ProfileState> runNotifierBuild(
    covariant ProfileController notifier,
  ) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(ProfileController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ProfileController, ProfileState>
  createElement() {
    return _ProfileControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileControllerProvider && other.babyId == babyId;
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
mixin ProfileControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ProfileState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _ProfileControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ProfileController, ProfileState>
    with ProfileControllerRef {
  _ProfileControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as ProfileControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

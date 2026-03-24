// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileEditControllerHash() =>
    r'0ae3367bf7ac30979b16bec7a948523adc308868';

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

abstract class _$ProfileEditController
    extends BuildlessAutoDisposeAsyncNotifier<ProfileEditState> {
  late final String babyId;

  FutureOr<ProfileEditState> build(String babyId);
}

/// See also [ProfileEditController].
@ProviderFor(ProfileEditController)
const profileEditControllerProvider = ProfileEditControllerFamily();

/// See also [ProfileEditController].
class ProfileEditControllerFamily extends Family<AsyncValue<ProfileEditState>> {
  /// See also [ProfileEditController].
  const ProfileEditControllerFamily();

  /// See also [ProfileEditController].
  ProfileEditControllerProvider call(String babyId) {
    return ProfileEditControllerProvider(babyId);
  }

  @override
  ProfileEditControllerProvider getProviderOverride(
    covariant ProfileEditControllerProvider provider,
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
  String? get name => r'profileEditControllerProvider';
}

/// See also [ProfileEditController].
class ProfileEditControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ProfileEditController,
          ProfileEditState
        > {
  /// See also [ProfileEditController].
  ProfileEditControllerProvider(String babyId)
    : this._internal(
        () => ProfileEditController()..babyId = babyId,
        from: profileEditControllerProvider,
        name: r'profileEditControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileEditControllerHash,
        dependencies: ProfileEditControllerFamily._dependencies,
        allTransitiveDependencies:
            ProfileEditControllerFamily._allTransitiveDependencies,
        babyId: babyId,
      );

  ProfileEditControllerProvider._internal(
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
  FutureOr<ProfileEditState> runNotifierBuild(
    covariant ProfileEditController notifier,
  ) {
    return notifier.build(babyId);
  }

  @override
  Override overrideWith(ProfileEditController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileEditControllerProvider._internal(
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
    ProfileEditController,
    ProfileEditState
  >
  createElement() {
    return _ProfileEditControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileEditControllerProvider && other.babyId == babyId;
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
mixin ProfileEditControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ProfileEditState> {
  /// The parameter `babyId` of this provider.
  String get babyId;
}

class _ProfileEditControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ProfileEditController,
          ProfileEditState
        >
    with ProfileEditControllerRef {
  _ProfileEditControllerProviderElement(super.provider);

  @override
  String get babyId => (origin as ProfileEditControllerProvider).babyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

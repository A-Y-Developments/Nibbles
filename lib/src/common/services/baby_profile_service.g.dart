// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_profile_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$babyProfileServiceHash() =>
    r'e9648e03043575a4633f6a3ce40fadddd8471e03';

/// See also [babyProfileService].
@ProviderFor(babyProfileService)
final babyProfileServiceProvider = Provider<BabyProfileService>.internal(
  babyProfileService,
  name: r'babyProfileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$babyProfileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BabyProfileServiceRef = ProviderRef<BabyProfileService>;
String _$currentBabyIdHash() => r'30ac604b84e5b988e3b453a1084b51133570f9c3';

/// Fetches the current baby's id. Returns null if no baby exists yet.
///
/// Copied from [currentBabyId].
@ProviderFor(currentBabyId)
final currentBabyIdProvider = AutoDisposeFutureProvider<String?>.internal(
  currentBabyId,
  name: r'currentBabyIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBabyIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBabyIdRef = AutoDisposeFutureProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

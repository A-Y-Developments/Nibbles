// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen_log_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allergenLogControllerHash() =>
    r'f77ec517be3bf35a1ae615e256dfcc69de157507';

/// Controller backing the redesigned full-screen Allergen Log capture screen
/// (NIB-127).
///
/// Shared between CREATE (new log) and EDIT (existing log) modes. EDIT mode
/// hydrates state from an existing log via [hydrateFromLog]; submit dispatches
/// to either [AllergenService.saveAllergenLog] or
/// [AllergenService.updateAllergenLog].
///
/// Copied from [AllergenLogController].
@ProviderFor(AllergenLogController)
final allergenLogControllerProvider =
    NotifierProvider<AllergenLogController, AllergenLogState>.internal(
      AllergenLogController.new,
      name: r'allergenLogControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allergenLogControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllergenLogController = Notifier<AllergenLogState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

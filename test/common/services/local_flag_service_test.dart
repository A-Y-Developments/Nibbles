import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';

void main() {
  late Box<dynamic> box;
  late LocalFlagService sut;

  setUpAll(() {
    Hive.init('.dart_tool/test_hive_local_flag_service');
  });

  setUp(() async {
    // Unique box per test to avoid cross-test bleed when tests run in parallel.
    final name = 'local_flags_${DateTime.now().microsecondsSinceEpoch}';
    box = await Hive.openBox<dynamic>(name);
    sut = LocalFlagService(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('LocalFlagService.clearAll', () {
    test('wipes every key in the local_flags box', () async {
      sut
        ..setHasLaunched()
        ..setOnboardingReadinessDone()
        ..setOnboardingBabySetupDone()
        ..setOnboardingDone()
        ..setProgramCompletionShown('baby-001');
      await sut.markStartingGuideSeen();
      await sut.setAccountDeleted();

      // Sanity — the box really did have entries.
      expect(box.length, greaterThan(0));

      await sut.clearAll();

      expect(box.length, 0);
      expect(sut.hasLaunched(), isFalse);
      expect(sut.isOnboardingReadinessDone(), isFalse);
      expect(sut.isOnboardingBabySetupDone(), isFalse);
      expect(sut.isOnboardingDone(), isFalse);
      expect(sut.isProgramCompletionShown('baby-001'), isFalse);
      expect(sut.isStartingGuideSeen(), isFalse);
      expect(sut.isAccountDeleted(), isFalse);
    });
  });

  group('LocalFlagService.account_deleted flag', () {
    test('defaults to false and flips to true via setAccountDeleted', () async {
      expect(sut.isAccountDeleted(), isFalse);

      await sut.setAccountDeleted();

      expect(sut.isAccountDeleted(), isTrue);
    });
  });

  group('LocalFlagService.resetOnboardingProgress', () {
    test('clears all three onboarding flags', () {
      sut
        ..setOnboardingReadinessDone()
        ..setOnboardingBabySetupDone()
        ..setOnboardingDone();
      expect(sut.isOnboardingReadinessDone(), isTrue);
      expect(sut.isOnboardingBabySetupDone(), isTrue);
      expect(sut.isOnboardingDone(), isTrue);

      sut.resetOnboardingProgress();

      expect(sut.isOnboardingReadinessDone(), isFalse);
      expect(sut.isOnboardingBabySetupDone(), isFalse);
      expect(sut.isOnboardingDone(), isFalse);
    });

    test('does not affect unrelated flags', () {
      sut
        ..setHasLaunched()
        ..setOnboardingReadinessDone()
        ..resetOnboardingProgress();

      expect(sut.hasLaunched(), isTrue);
    });
  });

  group('LocalFlagService.markProgramCompletionShown', () {
    test('awaitable variant flips the per-baby flag durably', () async {
      const babyId = 'baby-abc';
      expect(sut.isProgramCompletionShown(babyId), isFalse);

      await sut.markProgramCompletionShown(babyId);

      expect(sut.isProgramCompletionShown(babyId), isTrue);
    });

    test('scoped to babyId — other babies remain unaffected', () async {
      await sut.markProgramCompletionShown('baby-1');

      expect(sut.isProgramCompletionShown('baby-1'), isTrue);
      expect(sut.isProgramCompletionShown('baby-2'), isFalse);
    });
  });
}

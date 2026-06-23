// NIB-99: Rewrites the (previously skipped post-NIB-52) Profile screen suite
// against the new Settings layout — ProfileHeader / ProfileAvatarCard /
// PremiumTeaserCard / 4 SettingsRow widgets, with the dialog-based sign-out
// flow and a delete-account modal bottom sheet.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_controller.dart';
import 'package:nibbles/src/features/profile/profile_controller.dart';
import 'package:nibbles/src/features/profile/profile_screen.dart';
import 'package:nibbles/src/features/profile/profile_state.dart';
import 'package:nibbles/src/features/profile/widgets/premium_teaser_card.dart';
import 'package:nibbles/src/features/profile/widgets/profile_avatar_card.dart';
import 'package:nibbles/src/features/profile/widgets/profile_header.dart';
import 'package:nibbles/src/features/profile/widgets/settings_row.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../support/fake_analytics.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// Test seam — bypasses the real `AuthService.signOut`'s `Purchases.logOut()`
/// call, which never resolves in the widget-test ticker.
class _FakeAuthService extends AuthService {
  int signOutCalls = 0;

  @override
  bool build() => true;

  @override
  Stream<AuthState> get authStateStream => const Stream<AuthState>.empty();

  @override
  Future<Result<void>> signOut() async {
    signOutCalls += 1;
    state = false;
    return const Result.success(null);
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  // Use a recent DOB so the age label renders a plausible "<n> months <m> days"
  // (the screen formats off `DateTime.now()`).
  dateOfBirth: DateTime(2026, 3),
  gender: Gender.female,
  onboardingCompleted: true,
);

ProfileState _populatedState() =>
    ProfileState(baby: _fakeBaby, subscriptionLabel: 'No Subscription');

// ---------------------------------------------------------------------------
// Fake ProfileController — returns a fixed state so the test doesn't depend on
// the real notifier's baby-profile service read inside build().
// ---------------------------------------------------------------------------

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._initial);

  final AsyncValue<ProfileState> _initial;

  @override
  Future<ProfileState> build(String babyId) async {
    // Mirror the AsyncNotifier contract via the initial AsyncValue. Tests
    // override per-state (data/loading/error) to assert each branch of
    // `_ProfileBody`.
    return _initial.when(
      data: (state) => state,
      loading: () => Completer<ProfileState>().future, // never resolves
      error: Future<ProfileState>.error,
    );
  }
}

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

const _editStubKey = Key('stub_profile_edit');
const _feedbackStubKey = Key('stub_profile_feedback');
const _manageSubscriptionStubKey = Key('stub_manage_subscription');

GoRouter _router() => GoRouter(
  initialLocation: '/home/profile',
  routes: [
    GoRoute(
      path: '/home/profile',
      name: AppRoute.profile.name,
      builder: (_, __) => const ProfileScreen(),
    ),
    // Stub destinations: keep nav assertable without booting the real
    // ProfileEdit / Feedback / ManageSubscription subtrees (which would
    // try to read providers we don't mock here).
    GoRoute(
      path: '/home/profile/edit',
      name: AppRoute.profileEdit.name,
      builder: (_, __) => const Scaffold(
        key: _editStubKey,
        body: Center(child: Text('EDIT STUB')),
      ),
    ),
    GoRoute(
      path: '/home/profile/feedback',
      name: AppRoute.profileFeedback.name,
      builder: (_, __) => const Scaffold(
        key: _feedbackStubKey,
        body: Center(child: Text('FEEDBACK STUB')),
      ),
    ),
    GoRoute(
      path: '/subscription/manage',
      name: AppRoute.manageSubscription.name,
      builder: (_, __) => const Scaffold(
        key: _manageSubscriptionStubKey,
        body: Center(child: Text('MANAGE SUBSCRIPTION STUB')),
      ),
    ),
  ],
);

Widget _wrap(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(routerConfig: _router()),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockBabyProfileService mockBabyService;
  late _MockAuthRepository mockAuthRepo;
  late _MockAccountRepository mockAccountRepo;
  late _MockLocalFlagService mockFlags;
  late _FakeAuthService fakeAuthService;
  late FakeAnalytics fakeAnalytics;

  setUp(() {
    mockBabyService = _MockBabyProfileService();
    mockAuthRepo = _MockAuthRepository();
    mockAccountRepo = _MockAccountRepository();
    mockFlags = _MockLocalFlagService();
    fakeAuthService = _FakeAuthService();
    fakeAnalytics = FakeAnalytics();

    // AuthService.build() consults isLoggedIn + subscribes to the stream.
    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(
      () => mockAuthRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAuthRepo.signOut(),
    ).thenAnswer((_) async => const Result.success(null));
    when(mockFlags.clearAll).thenAnswer((_) async {});
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
  });

  List<Override> buildOverrides({
    required AsyncValue<ProfileState> profileState,
  }) => [
    babyProfileServiceProvider.overrideWithValue(mockBabyService),
    authRepositoryProvider.overrideWithValue(mockAuthRepo),
    authServiceProvider.overrideWith(() => fakeAuthService),
    accountRepositoryProvider.overrideWithValue(mockAccountRepo),
    localFlagServiceProvider.overrideWithValue(mockFlags),
    analyticsProvider.overrideWithValue(fakeAnalytics),
    // Bypass `Supabase.instance.client.auth.currentUser?.email` inside the
    // real controller build().
    currentBabyIdProvider.overrideWith((ref) async => _babyId),
    profileControllerProvider(
      _babyId,
    ).overrideWith(() => _FakeProfileController(profileState)),
    // Capturing recorder is not asserted here — controller tests own that
    // coverage. Stub a no-op so the modal sheet's controller can boot.
    deleteAccountCrashRecorderProvider.overrideWithValue(
      (_, __, {String? reason, List<String>? information}) async {},
    ),
  ];

  // -------------------------------------------------------------------------
  // Populated state
  // -------------------------------------------------------------------------

  testWidgets(
    'populated state: renders header, avatar, premium teaser and 4 rows',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(buildOverrides(profileState: AsyncData(_populatedState()))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.byType(ProfileAvatarCard), findsOneWidget);
      expect(find.byType(PremiumTeaserCard), findsOneWidget);
      expect(find.byType(SettingsRow), findsNWidgets(4));

      // Spot-check the 4 row titles + the baby name on the avatar card.
      expect(find.text('Manage Subscription'), findsOneWidget);
      expect(find.text('Give Feedback'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
      expect(find.text('Lily'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // Loading state — never-resolving build()
  // -------------------------------------------------------------------------

  testWidgets('loading state: renders CircularProgressIndicator spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(buildOverrides(profileState: const AsyncLoading())),
    );
    // Single pump — the spinner animates indefinitely so pumpAndSettle
    // would block.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Error state — error placeholder + retry CTA
  // -------------------------------------------------------------------------

  testWidgets('error state: renders placeholder message + Try Again CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        buildOverrides(
          profileState: const AsyncError<ProfileState>(
            ServerException('boom'),
            StackTrace.empty,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Row tap — Manage Subscription
  // -------------------------------------------------------------------------

  testWidgets("tapping 'Manage Subscription' pushes /subscription/manage", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(buildOverrides(profileState: AsyncData(_populatedState()))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_manage_subscription_row')));
    await tester.pumpAndSettle();

    expect(find.byKey(_manageSubscriptionStubKey), findsOneWidget);
    expect(find.text('MANAGE SUBSCRIPTION STUB'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Row tap — Give Feedback
  // -------------------------------------------------------------------------

  testWidgets("tapping 'Give Feedback' pushes /home/profile/feedback", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(buildOverrides(profileState: AsyncData(_populatedState()))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_feedback_row')));
    await tester.pumpAndSettle();

    expect(find.byKey(_feedbackStubKey), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Row tap — Sign out (confirmation + signOut + analytics)
  // -------------------------------------------------------------------------

  // TODO(adithya): GoRouter auth-redirect rebuild hangs the test pump loop
  // on confirm; unblock when the test harness stubs the redirect.
  testWidgets(
    "tapping 'Sign out' shows confirm dialog; confirm fires signOut + "
    'logLogout',
    skip: true,
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(buildOverrides(profileState: AsyncData(_populatedState()))),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_sign_out_button')));
      await tester.pumpAndSettle();

      // Confirmation dialog is up.
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      // Pump one frame — pumpAndSettle would block on the GoRouter auth
      // redirect rebuild, which isn't stubbed in the test harness.
      await tester.pump();

      // Drain fire-and-forget analytics call.
      await Future<void>.delayed(Duration.zero);

      expect(fakeAuthService.signOutCalls, 1);
      expect(fakeAnalytics.eventNames, contains('logout'));
    },
  );

  testWidgets(
    "tapping 'Sign out' then 'No' keeps the user on the profile screen",
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(buildOverrides(profileState: AsyncData(_populatedState()))),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_sign_out_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(fakeAuthService.signOutCalls, 0);
      expect(find.text('Are you sure you want to sign out?'), findsNothing);
      expect(find.byKey(const Key('profile_sign_out_button')), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // Row tap — Delete account (opens the overlay sheet)
  // -------------------------------------------------------------------------

  testWidgets("tapping 'Delete account' opens the delete-account overlay", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(buildOverrides(profileState: AsyncData(_populatedState()))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_delete_account_row')));
    await tester.pumpAndSettle();

    // Overlay rendered: heading + at least one reason row.
    expect(
      find.text('Tell us why you want to delete your account'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('delete_reason_0')), findsOneWidget);
  });
}

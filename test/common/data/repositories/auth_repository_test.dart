import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class _FakeUserAttributes extends Fake implements UserAttributes {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// The plugin exposes no public ctor for [GoogleSignInAccount], so we
/// implement the interface with just the surface the repo touches:
/// `authentication.idToken`. The repo never goes through the real
/// authorize client — that's injected separately via `googleAuthorize`.
class _FakeGoogleAccount implements GoogleSignInAccount {
  _FakeGoogleAccount(this._idToken);

  final String _idToken;

  @override
  GoogleSignInAuthentication get authentication =>
      GoogleSignInAuthentication(idToken: _idToken);

  @override
  GoogleSignInAuthorizationClient get authorizationClient =>
      throw UnimplementedError(
        'Not used — repo injects authorize fn directly.',
      );

  @override
  String get displayName => 'Test User';

  @override
  String get email => 'test@example.com';

  @override
  String get id => 'google-uid';

  @override
  String? get photoUrl => null;
}

AuthorizationCredentialAppleID _makeAppleCredential({String? identityToken}) {
  return AuthorizationCredentialAppleID(
    userIdentifier: 'apple-uid',
    givenName: 'Test',
    familyName: 'User',
    authorizationCode: 'auth-code',
    email: 'test@example.com',
    identityToken: identityToken,
    state: null,
  );
}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUpAll(() {
    registerFallbackValue(_FakeUserAttributes());
    registerFallbackValue(OAuthProvider.google);
    FlavorConfig.init(
      flavor: Flavor.dev,
      supabaseUrl: 'https://test.supabase.co',
      supabaseAnonKey: 'anon-key',
      revenueCatAppleKey: 'rc-apple',
      revenueCatGoogleKey: 'rc-google',
      firebaseAndroidApiKey: 'firebase-android-key',
      firebaseAndroidAppId: '1:000:android:000',
      firebaseIosApiKey: 'firebase-ios-key',
      firebaseIosAppId: '1:000:ios:000',
      firebaseMessagingSenderId: '000000000',
      firebaseProjectId: 'nibbles-test',
      firebaseStorageBucket: 'nibbles-test.appspot.com',
      firebaseIosBundleId: 'com.aydev.nibbles.dev',
    );
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    // NB: `generateRawNonce` is an extension on GoTrueClient and therefore
    // cannot be stubbed by mocktail. The repo accepts `generateRawNonce` as
    // an injectable to bypass it in tests.
  });

  AuthRepositoryImpl buildSut({
    GoogleAuthenticateFn? googleAuthenticate,
    GoogleAuthorizeFn? googleAuthorize,
    AppleCredentialFn? appleCredential,
    String? Function()? generateRawNonce,
    AuthCrashRecorderFn? crashRecorder,
  }) {
    return AuthRepositoryImpl(
      supabaseClient: mockClient,
      // No-op the one-shot Google init so tests don't touch the platform.
      googleInitialize: () async {},
      googleAuthenticate: googleAuthenticate,
      googleAuthorize: googleAuthorize,
      appleCredential: appleCredential,
      generateRawNonce: generateRawNonce,
      // Default: swallow so tests don't touch real Crashlytics.
      crashRecorder: crashRecorder ?? (_, __) async {},
    );
  }

  // -------------------------------------------------------------------------
  // signInWithGoogle
  // -------------------------------------------------------------------------

  group('signInWithGoogle', () {
    test('returns Success(true) and calls Supabase on happy path', () async {
      final sut = buildSut(
        googleAuthenticate: () async => _FakeGoogleAccount('id-token-x'),
        googleAuthorize: (_) async => 'access-token-y',
      );
      when(
        () => mockAuth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
          nonce: any(named: 'nonce'),
        ),
      ).thenAnswer((_) async => AuthResponse());

      final result = await sut.signInWithGoogle();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, isTrue);
      verify(
        () => mockAuth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'id-token-x',
          accessToken: 'access-token-y',
        ),
      ).called(1);
    });

    test('returns Success(false) on user-cancel (no Supabase call)', () async {
      final sut = buildSut(
        googleAuthenticate: () async => throw const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'user canceled',
        ),
        googleAuthorize: (_) async => null,
      );

      final result = await sut.signInWithGoogle();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, isFalse);
      verifyNever(
        () => mockAuth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
        ),
      );
    });

    test(
      'returns Failure(ServerException) on Google clientConfigurationError',
      () async {
        final sut = buildSut(
          googleAuthenticate: () async => throw const GoogleSignInException(
            code: GoogleSignInExceptionCode.clientConfigurationError,
            description: 'bad client id',
          ),
          googleAuthorize: (_) async => null,
        );

        final result = await sut.signInWithGoogle();

        expect(result, isA<Failure<bool>>());
        expect((result as Failure<bool>).error, isA<ServerException>());
        expect(result.error.message, contains('bad client id'));
      },
    );

    test('returns Failure when ID token is null', () async {
      final sut = buildSut(
        googleAuthenticate: () async => _FakeGoogleAccountNullToken(),
        googleAuthorize: (_) async => null,
      );

      final result = await sut.signInWithGoogle();

      expect(result, isA<Failure<bool>>());
      expect((result as Failure<bool>).error, isA<ServerException>());
    });

    test('maps Supabase AuthException to Failure(ServerException)', () async {
      final sut = buildSut(
        googleAuthenticate: () async => _FakeGoogleAccount('id-token-x'),
        googleAuthorize: (_) async => 'access-token-y',
      );
      when(
        () => mockAuth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
        ),
      ).thenThrow(const AuthException('provider not enabled'));

      final result = await sut.signInWithGoogle();

      expect(result, isA<Failure<bool>>());
      expect((result as Failure<bool>).error.message, 'provider not enabled');
    });
  });

  // -------------------------------------------------------------------------
  // signInWithApple
  // -------------------------------------------------------------------------

  group('signInWithApple', () {
    test(
      'returns Success(true), passes hashed nonce to Apple and raw to Supabase',
      () async {
        String? receivedAppleNonce;
        final sut = buildSut(
          appleCredential: (hashedNonce) async {
            receivedAppleNonce = hashedNonce;
            return _makeAppleCredential(identityToken: 'apple-id-token');
          },
          generateRawNonce: () => 'raw-nonce-fixed',
        );
        when(
          () => mockAuth.signInWithIdToken(
            provider: any(named: 'provider'),
            idToken: any(named: 'idToken'),
            nonce: any(named: 'nonce'),
          ),
        ).thenAnswer((_) async => AuthResponse());

        final result = await sut.signInWithApple();

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, isTrue);

        // Apple receives the HASHED nonce. SHA-256 of "raw-nonce-fixed".
        expect(receivedAppleNonce, hasLength(64));
        expect(receivedAppleNonce, isNot('raw-nonce-fixed'));

        // Supabase receives the RAW nonce.
        verify(
          () => mockAuth.signInWithIdToken(
            provider: OAuthProvider.apple,
            idToken: 'apple-id-token',
            nonce: 'raw-nonce-fixed',
          ),
        ).called(1);
      },
    );

    test('returns Success(false) on user-cancel (no Supabase call)', () async {
      final sut = buildSut(
        appleCredential: (_) async =>
            throw const SignInWithAppleAuthorizationException(
              code: AuthorizationErrorCode.canceled,
              message: 'user canceled',
            ),
        generateRawNonce: () => 'raw-nonce-fixed',
      );

      final result = await sut.signInWithApple();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, isFalse);
      verifyNever(
        () => mockAuth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
        ),
      );
    });

    test(
      'returns Success(false) on unknown code (closed Apple-ID alert)',
      () async {
        // NIB-164 — closing the system "Sign in to your Apple Account" alert on
        // a device with no Apple ID surfaces as `unknown`; treat as a cancel.
        final sut = buildSut(
          appleCredential: (_) async =>
              throw const SignInWithAppleAuthorizationException(
                code: AuthorizationErrorCode.unknown,
                message:
                    'The operation couldn’t be completed. '
                    '(com.apple.AuthenticationServices.Authorization'
                    'Error error 1000.)',
              ),
          generateRawNonce: () => 'raw-nonce-fixed',
        );

        final result = await sut.signInWithApple();

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, isFalse);
      },
    );

    test(
      'returns Failure with friendly copy on Apple authorization failure',
      () async {
        // NIB-164 — never surface the raw NSError string.
        final sut = buildSut(
          appleCredential: (_) async =>
              throw const SignInWithAppleAuthorizationException(
                code: AuthorizationErrorCode.failed,
                message: 'authorization failed',
              ),
          generateRawNonce: () => 'raw-nonce-fixed',
        );

        final result = await sut.signInWithApple();

        expect(result, isA<Failure<bool>>());
        expect((result as Failure<bool>).error, isA<ServerException>());
        expect(
          result.error.message,
          "Couldn't sign in with Apple. Please try again.",
        );
      },
    );

    test('returns Failure when Apple identityToken is null', () async {
      final sut = buildSut(
        appleCredential: (_) async => _makeAppleCredential(),
        generateRawNonce: () => 'raw-nonce-fixed',
      );

      final result = await sut.signInWithApple();

      expect(result, isA<Failure<bool>>());
      expect((result as Failure<bool>).error, isA<ServerException>());
    });

    test('maps Supabase AuthException to Failure(ServerException)', () async {
      final sut = buildSut(
        appleCredential: (_) async =>
            _makeAppleCredential(identityToken: 'apple-id-token'),
        generateRawNonce: () => 'raw-nonce-fixed',
      );
      when(
        () => mockAuth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          nonce: any(named: 'nonce'),
        ),
      ).thenThrow(const AuthException('nonce mismatch'));

      final result = await sut.signInWithApple();

      expect(result, isA<Failure<bool>>());
      expect((result as Failure<bool>).error.message, 'nonce mismatch');
    });
  });

  // -------------------------------------------------------------------------
  // signUp
  // -------------------------------------------------------------------------

  group('signUp', () {
    test('returns Success when session is not null', () async {
      final sut = buildSut();
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: _FakeSession()));

      final result = await sut.signUp('test@example.com', 'password123');

      expect(result, isA<Success<void>>());
    });

    test('returns Failure(ServerException) when session is null', () async {
      final sut = buildSut();
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse());

      final result = await sut.signUp('test@example.com', 'password123');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<ServerException>());
      expect(result.error.message, contains('confirm your email'));
    });

    test('maps AuthException to Failure(ServerException)', () async {
      final sut = buildSut();
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('email already registered'));

      final result = await sut.signUp('test@example.com', 'password123');

      expect(result, isA<Failure<void>>());
      expect(
        (result as Failure<void>).error.message,
        'email already registered',
      );
    });

    test('returns Failure(UnknownException) on unexpected error', () async {
      final sut = buildSut();
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('network error'));

      final result = await sut.signUp('test@example.com', 'password123');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });

  // -------------------------------------------------------------------------
  // signIn
  // -------------------------------------------------------------------------

  group('signIn', () {
    test('returns Success on valid credentials', () async {
      final sut = buildSut();
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: _FakeSession()));

      final result = await sut.signIn('test@example.com', 'password123');

      expect(result, isA<Success<void>>());
    });

    test('maps AuthException to Failure(ServerException)', () async {
      final sut = buildSut();
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('invalid credentials'));

      final result = await sut.signIn('test@example.com', 'wrong');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error.message, 'invalid credentials');
    });
  });

  // -------------------------------------------------------------------------
  // signOut
  // -------------------------------------------------------------------------

  group('signOut', () {
    test('returns Success', () async {
      final sut = buildSut();
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final result = await sut.signOut();

      expect(result, isA<Success<void>>());
    });

    test('maps AuthException to Failure(ServerException)', () async {
      final sut = buildSut();
      when(() => mockAuth.signOut())
          .thenThrow(const AuthException('session expired'));

      final result = await sut.signOut();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error.message, 'session expired');
    });

    test('returns Failure(UnknownException) on unexpected error', () async {
      final sut = buildSut();
      when(() => mockAuth.signOut()).thenThrow(Exception('network error'));

      final result = await sut.signOut();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });

  // -------------------------------------------------------------------------
  // resetPassword
  // -------------------------------------------------------------------------

  group('resetPassword', () {
    test('returns Success and passes redirectTo', () async {
      final sut = buildSut();
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      final result = await sut.resetPassword('test@example.com');

      expect(result, isA<Success<void>>());
      final captured = verify(
        () => mockAuth.resetPasswordForEmail(
          'test@example.com',
          redirectTo: captureAny(named: 'redirectTo'),
        ),
      ).captured;
      expect(captured.first as String, contains('://auth/reset-password'));
    });

    test('maps AuthException to Failure(ServerException)', () async {
      final sut = buildSut();
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(const AuthException('email not found'));

      final result = await sut.resetPassword('test@example.com');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error.message, 'email not found');
    });

    test('returns Failure(UnknownException) on unexpected error', () async {
      final sut = buildSut();
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(Exception('network error'));

      final result = await sut.resetPassword('test@example.com');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });

  // -------------------------------------------------------------------------
  // updatePassword
  // -------------------------------------------------------------------------

  group('updatePassword', () {
    test('returns Success', () async {
      final sut = buildSut();
      when(() => mockAuth.updateUser(any()))
          .thenAnswer((_) async => _FakeUserResponse());

      final result = await sut.updatePassword('newpassword123');

      expect(result, isA<Success<void>>());
    });

    test('maps AuthException to Failure(ServerException)', () async {
      final sut = buildSut();
      when(() => mockAuth.updateUser(any()))
          .thenThrow(const AuthException('weak password'));

      final result = await sut.updatePassword('weak');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error.message, 'weak password');
    });

    test('returns Failure(UnknownException) on unexpected error', () async {
      final sut = buildSut();
      when(() => mockAuth.updateUser(any()))
          .thenThrow(Exception('network error'));

      final result = await sut.updatePassword('newpassword123');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });

  // -------------------------------------------------------------------------
  // updateEmail
  // -------------------------------------------------------------------------

  group('updateEmail', () {
    test('returns Success', () async {
      final sut = buildSut();
      when(() => mockAuth.updateUser(any()))
          .thenAnswer((_) async => _FakeUserResponse());

      final result = await sut.updateEmail('new@example.com');

      expect(result, isA<Success<void>>());
    });

    test('maps AuthException to Failure(ServerException)', () async {
      final sut = buildSut();
      when(() => mockAuth.updateUser(any()))
          .thenThrow(const AuthException('email already taken'));

      final result = await sut.updateEmail('new@example.com');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error.message, 'email already taken');
    });

    test('returns Failure(UnknownException) on unexpected error', () async {
      final sut = buildSut();
      when(() => mockAuth.updateUser(any()))
          .thenThrow(Exception('network error'));

      final result = await sut.updateEmail('new@example.com');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });

  // -------------------------------------------------------------------------
  // Computed properties
  // -------------------------------------------------------------------------

  group('computed properties', () {
    test('isLoggedIn returns true when session exists', () {
      final sut = buildSut();
      when(() => mockAuth.currentSession).thenReturn(_FakeSession());

      expect(sut.isLoggedIn, isTrue);
    });

    test('isLoggedIn returns false when no session', () {
      final sut = buildSut();
      when(() => mockAuth.currentSession).thenReturn(null);

      expect(sut.isLoggedIn, isFalse);
    });

    test('currentUserEmail returns email from current user', () {
      final sut = buildSut();
      when(() => mockAuth.currentUser)
          .thenReturn(_FakeUserWithEmail('user@example.com'));

      expect(sut.currentUserEmail, 'user@example.com');
    });

    test('currentUserEmail returns null when no user', () {
      final sut = buildSut();
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(sut.currentUserEmail, isNull);
    });

    test('authStateStream delegates to Supabase auth state stream', () {
      final sut = buildSut();
      const stream = Stream<AuthState>.empty();
      when(() => mockAuth.onAuthStateChange).thenAnswer((_) => stream);

      expect(sut.authStateStream, same(stream));
    });
  });

  // -------------------------------------------------------------------------
  // Crashlytics non-fatal on UnknownException path
  // -------------------------------------------------------------------------

  group('Crashlytics non-fatal', () {
    test('records the original error on signIn UnknownException', () async {
      Object? recordedError;
      final sut = buildSut(
        crashRecorder: (error, _) async {
          recordedError = error;
        },
      );
      final boom = Exception('boom');
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(boom);

      final result = await sut.signIn('e@e.com', 'pw');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
      expect(recordedError, same(boom));
    });

    test('crash recorder throwing does NOT escalate', () async {
      final sut = buildSut(
        crashRecorder: (_, __) => throw Exception('crashlytics down'),
      );
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('boom'));

      // Must complete normally with a Failure — Crashlytics must not bubble.
      final result = await sut.signIn('e@e.com', 'pw');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });
}

/// Variant whose authentication has a null idToken.
class _FakeGoogleAccountNullToken extends _FakeGoogleAccount {
  _FakeGoogleAccountNullToken() : super('');

  @override
  GoogleSignInAuthentication get authentication =>
      const GoogleSignInAuthentication(idToken: null);
}

class _FakeAuthUser extends Fake implements User {}

class _FakeSession extends Fake implements Session {
  @override
  User get user => _FakeAuthUser();
}

class _FakeUserResponse extends Fake implements UserResponse {}

class _FakeUserWithEmail extends Fake implements User {
  _FakeUserWithEmail(this._email);

  final String _email;

  @override
  String? get email => _email;
}

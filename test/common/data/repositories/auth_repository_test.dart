import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
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
        googleAuthenticate: () async =>
            _FakeGoogleAccount('id-token-x'),
        googleAuthorize: (_) async => 'access-token-y',
      );
      when(
        () => mockAuth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
          nonce: any(named: 'nonce'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(),
      );

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
        googleAuthenticate: () async =>
            _FakeGoogleAccount('id-token-x'),
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
      expect(
        (result as Failure<bool>).error.message,
        'provider not enabled',
      );
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

    test('returns Failure on Apple authorization failure', () async {
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
      expect(result.error.message, 'authorization failed');
    });

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

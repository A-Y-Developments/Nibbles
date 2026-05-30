import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

/// Function injected so the repo is unit-testable without a real Google SDK.
typedef GoogleAuthenticateFn = Future<GoogleSignInAccount> Function();

/// Function injected so the repo is unit-testable. Returns the access token
/// for the granted scopes (may be null if the platform did not return one).
typedef GoogleAuthorizeFn =
    Future<String?> Function(GoogleSignInAccount account);

/// Function injected so the repo is unit-testable without a real Apple SDK.
typedef AppleCredentialFn =
    Future<AuthorizationCredentialAppleID> Function(String hashedNonce);

/// Function injected to make the one-shot Google initialize step swappable
/// in tests (the real `GoogleSignIn.instance.initialize` throws on a missing
/// platform plugin under the test runner).
typedef GoogleInitializeFn = Future<void> Function();

/// Function injected so unit tests don't touch real Crashlytics. Records a
/// non-fatal diagnostic for an unrecognised auth exception path.
typedef AuthCrashRecorderFn =
    Future<void> Function(Object error, StackTrace stack);

abstract interface class AuthRepository {
  Future<Result<void>> signUp(String email, String password);
  Future<Result<void>> signIn(String email, String password);

  /// Returns `Success(true)` on a completed Google sign-in,
  /// `Success(false)` if the user cancelled the native dialog (silent no-op),
  /// or `Failure` for any provider/SDK/Supabase error.
  Future<Result<bool>> signInWithGoogle();

  /// Returns `Success(true)` on a completed Apple sign-in,
  /// `Success(false)` if the user cancelled the native dialog (silent no-op),
  /// or `Failure` for any provider/SDK/Supabase error.
  Future<Result<bool>> signInWithApple();

  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
  Future<Result<void>> updatePassword(String newPassword);

  /// Triggers Supabase's email-change flow. Supabase sends a confirmation
  /// email to the new address; the change only takes effect after the user
  /// clicks the link. Returns `Success(null)` once the request is accepted.
  Future<Result<void>> updateEmail(String newEmail);
  bool get isLoggedIn;
  Stream<AuthState> get authStateStream;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    SupabaseClient? supabaseClient,
    GoogleInitializeFn? googleInitialize,
    GoogleAuthenticateFn? googleAuthenticate,
    GoogleAuthorizeFn? googleAuthorize,
    AppleCredentialFn? appleCredential,
    String? Function()? generateRawNonce,
    AuthCrashRecorderFn? crashRecorder,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _googleInitialize = googleInitialize ?? _defaultGoogleInitialize,
       _googleAuthenticate = googleAuthenticate ?? _defaultGoogleAuthenticate,
       _googleAuthorize = googleAuthorize ?? _defaultGoogleAuthorize,
       _appleCredential = appleCredential ?? _defaultAppleCredential,
       _generateRawNonce = generateRawNonce,
       _crashRecorder = crashRecorder ?? _defaultCrashRecorder;

  final SupabaseClient _supabase;
  final GoogleInitializeFn _googleInitialize;
  final GoogleAuthenticateFn _googleAuthenticate;
  final GoogleAuthorizeFn _googleAuthorize;
  final AppleCredentialFn _appleCredential;
  final String? Function()? _generateRawNonce;
  final AuthCrashRecorderFn _crashRecorder;

  /// One-shot guard. `GoogleSignIn.initialize()` must run exactly once per
  /// process — calling it twice is undefined behavior per the 7.x docs.
  Future<void>? _googleInitFuture;

  @override
  bool get isLoggedIn => _supabase.auth.currentSession != null;

  @override
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

  @override
  Future<Result<void>> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.session == null) {
        return const Result.failure(
          ServerException('Please confirm your email before continuing.'),
        );
      }
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<bool>> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final GoogleSignInAccount account;
      try {
        account = await _googleAuthenticate();
      } on GoogleSignInException catch (e) {
        // User-cancel / dismissed UI is a silent no-op — not an error.
        if (e.code == GoogleSignInExceptionCode.canceled ||
            e.code == GoogleSignInExceptionCode.interrupted ||
            e.code == GoogleSignInExceptionCode.uiUnavailable) {
          return const Result.success(false);
        }
        return Result.failure(
          ServerException(e.description ?? 'Google sign-in failed.'),
        );
      }

      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return const Result.failure(
          ServerException('Google sign-in did not return an ID token.'),
        );
      }
      final accessToken = await _googleAuthorize(account);

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return const Result.success(true);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<bool>> signInWithApple() async {
    try {
      // Per the Supabase Flutter README: pass the HASHED nonce to Apple
      // (gets embedded as the `nonce` claim in the identity JWT), then pass
      // the RAW nonce to Supabase via `nonce:` — Supabase hashes & compares.
      // (The ticket text inverts these; the README is canonical.)
      final rawNonce =
          _generateRawNonce?.call() ?? _supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final AuthorizationCredentialAppleID credential;
      try {
        credential = await _appleCredential(hashedNonce);
      } on SignInWithAppleAuthorizationException catch (e) {
        if (e.code == AuthorizationErrorCode.canceled) {
          return const Result.success(false);
        }
        return Result.failure(ServerException(e.message));
      }

      final idToken = credential.identityToken;
      if (idToken == null) {
        return const Result.failure(
          ServerException('Apple sign-in did not return an ID token.'),
        );
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return const Result.success(true);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: '${FlavorConfig.instance.appScheme}://auth/reset-password',
      );
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> updateEmail(String newEmail) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object catch (e, st) {
      await _recordAuthUnknown(e, st);
      return const Result.failure(UnknownException());
    }
  }

  /// `GoogleSignIn.initialize` must run exactly once per process. Calls
  /// after the first reuse the same Future.
  Future<void> _ensureGoogleInitialized() =>
      _googleInitFuture ??= _googleInitialize();

  /// Records an unrecognised auth-path exception to Crashlytics as a
  /// non-fatal. Guarded so a Crashlytics failure (e.g. uninitialised Firebase
  /// in tests) never escalates the original failure path. No PII passed —
  /// only the raw error/stack and a static reason string.
  Future<void> _recordAuthUnknown(Object error, StackTrace stack) async {
    try {
      await _crashRecorder(error, stack);
    } on Object {
      // Crashlytics is best-effort; never let it escalate the auth failure.
    }
  }
}

String? _readServerClientId() {
  if (!dotenv.isInitialized) return null;
  final value = dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID');
  if (value == null || value.isEmpty) return null;
  return value;
}

/// The serverClientId is read from `.env.<flavor>` if present; otherwise the
/// native side (iOS GIDClientID from Info.plist, Android Google Services)
/// supplies the necessary configuration.
Future<void> _defaultGoogleInitialize() => GoogleSignIn.instance.initialize(
  serverClientId: _readServerClientId(),
);

Future<GoogleSignInAccount> _defaultGoogleAuthenticate() =>
    GoogleSignIn.instance.authenticate();

Future<String?> _defaultGoogleAuthorize(GoogleSignInAccount account) async {
  // Supabase signInWithIdToken accepts a null accessToken when the ID token
  // has no `at_hash` claim, so we use the non-prompting variant: if the user
  // hasn't pre-authorized email/profile scopes, we skip the access token
  // rather than block the sign-in with a second consent prompt.
  final authz = await account.authorizationClient.authorizationForScopes(
    const ['email', 'profile'],
  );
  return authz?.accessToken;
}

Future<AuthorizationCredentialAppleID> _defaultAppleCredential(
  String hashedNonce,
) {
  return SignInWithApple.getAppleIDCredential(
    scopes: const [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );
}

Future<void> _defaultCrashRecorder(Object error, StackTrace stack) =>
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: 'auth_unknown',
    );

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl();

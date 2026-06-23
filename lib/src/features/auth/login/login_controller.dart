import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/login/login_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void updateEmail(String value) {
    state = state.copyWith(email: EmailInput.dirty(value), errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: PasswordInput.dirty(value),
      errorMessage: null,
    );
  }

  void toggleObscure() {
    state = state.copyWith(obscure: !state.obscure);
  }

  Future<void> submit() async {
    _fireAndForget(
      ref
          .read(analyticsProvider)
          .logLoginMethodSelected(method: AuthMethod.email),
    );

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .signIn(state.email.value, state.password.value);

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _fireAndForget(
          ref.read(analyticsProvider).logLoginSuccess(method: AuthMethod.email),
        );
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        _fireAndForget(
          ref
              .read(analyticsProvider)
              .logLoginFailure(
                method: AuthMethod.email,
                errorCode: authErrorCode(error),
              ),
        );
      },
    );
    // On success: GoRouter redirect picks up authServiceProvider state change
  }

  Future<void> signInWithGoogle() => _runSocial(
    method: AuthMethod.google,
    provider: SocialProvider.google,
    call: () => ref.read(authServiceProvider.notifier).signInWithGoogle(),
  );

  Future<void> signInWithApple() => _runSocial(
    method: AuthMethod.apple,
    provider: SocialProvider.apple,
    call: () => ref.read(authServiceProvider.notifier).signInWithApple(),
  );

  Future<void> _runSocial({
    required AuthMethod method,
    required SocialProvider provider,
    required Future<Result<bool>> Function() call,
  }) async {
    _fireAndForget(
      ref.read(analyticsProvider).logLoginMethodSelected(method: method),
    );

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await call();

    result.when(
      // Success(false) = user-cancel: clear loading silently, no error UI.
      // Success(true)  = signed in: router redirect picks up the state flip.
      success: (signedIn) {
        state = state.copyWith(isLoading: false);
        if (signedIn) {
          _fireAndForget(
            ref.read(analyticsProvider).logLoginSuccess(method: method),
          );
        } else {
          _fireAndForget(
            ref
                .read(analyticsProvider)
                .logSocialLoginCancelled(provider: provider),
          );
        }
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        _fireAndForget(
          ref
              .read(analyticsProvider)
              .logLoginFailure(method: method, errorCode: authErrorCode(error)),
        );
      },
    );
  }

  /// Analytics is best-effort. Swallow any rejected future so it never blocks
  /// navigation or escalates to the root zone.
  void _fireAndForget(Future<void> future) {
    unawaited(future.catchError((Object _) {}));
  }
}

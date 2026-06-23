import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/register/register_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  @override
  RegisterState build() => const RegisterState();

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

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  void toggleObscureConfirm() {
    state = state.copyWith(obscureConfirm: !state.obscureConfirm);
  }

  Future<bool> submit() async {
    _fireAndForget(
      ref
          .read(analyticsProvider)
          .logSignUpMethodSelected(method: AuthMethod.email),
    );

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .signUp(state.email.value, state.password.value);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _fireAndForget(
          ref
              .read(analyticsProvider)
              .logSignUpSuccess(method: AuthMethod.email),
        );
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        _fireAndForget(
          ref
              .read(analyticsProvider)
              .logSignUpFailure(
                method: AuthMethod.email,
                errorCode: authErrorCode(error),
              ),
        );
        return false;
      },
    );
  }

  Future<bool> signInWithGoogle() => _runSocial(
    method: AuthMethod.google,
    provider: SocialProvider.google,
    call: () => ref.read(authServiceProvider.notifier).signInWithGoogle(),
  );

  Future<bool> signInWithApple() => _runSocial(
    method: AuthMethod.apple,
    provider: SocialProvider.apple,
    call: () => ref.read(authServiceProvider.notifier).signInWithApple(),
  );

  /// Returns `true` on successful sign-in, `false` for cancel or failure.
  /// On failure the error message is stored in state so the screen can
  /// render it as P1. On cancel the error is silent.
  Future<bool> _runSocial({
    required AuthMethod method,
    required SocialProvider provider,
    required Future<Result<bool>> Function() call,
  }) async {
    _fireAndForget(
      ref.read(analyticsProvider).logSignUpMethodSelected(method: method),
    );

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await call();

    return result.when(
      success: (signedIn) {
        // signedIn == false ⇒ user-cancel: silent no-op, no error UI.
        state = state.copyWith(isLoading: false);
        if (signedIn) {
          _fireAndForget(
            ref.read(analyticsProvider).logSignUpSuccess(method: method),
          );
        } else {
          _fireAndForget(
            ref
                .read(analyticsProvider)
                .logSocialLoginCancelled(provider: provider),
          );
        }
        return signedIn;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        _fireAndForget(
          ref
              .read(analyticsProvider)
              .logSignUpFailure(
                method: method,
                errorCode: authErrorCode(error),
              ),
        );
        return false;
      },
    );
  }

  /// Analytics is best-effort. Swallow any rejected future so it never blocks
  /// navigation or escalates to the root zone.
  void _fireAndForget(Future<void> future) {
    unawaited(future.catchError((Object _) {}));
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_controller.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_state.dart';

class _SuccessAuthService extends AuthService {
  @override
  bool build() => false;

  @override
  Future<Result<void>> updatePassword(String newPassword) async =>
      const Result.success(null);
}

class _FailingAuthService extends AuthService {
  @override
  bool build() => false;

  @override
  Future<Result<void>> updatePassword(String newPassword) async =>
      const Result.failure(ServerException('token expired'));
}

ProviderContainer _container({required AuthService Function() svc}) {
  final c = ProviderContainer(
    overrides: [authServiceProvider.overrideWith(svc)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('ResetPasswordController', () {
    test('initial state is empty', () {
      final c = _container(svc: _SuccessAuthService.new);
      expect(
        c.read(resetPasswordControllerProvider),
        const ResetPasswordState(),
      );
    });

    test('updatePassword sets password field', () {
      final c = _container(svc: _SuccessAuthService.new);
      c
          .read(resetPasswordControllerProvider.notifier)
          .updatePassword('secret99');
      expect(
        c.read(resetPasswordControllerProvider).password.value,
        'secret99',
      );
      expect(c.read(resetPasswordControllerProvider).errorMessage, isNull);
    });

    test('updateConfirmPassword sets confirmPassword field', () {
      final c = _container(svc: _SuccessAuthService.new);
      c
          .read(resetPasswordControllerProvider.notifier)
          .updateConfirmPassword('secret99');
      expect(
        c.read(resetPasswordControllerProvider).confirmPassword,
        'secret99',
      );
    });

    group('submit', () {
      test('short password — sets errorMessage, no service call', () async {
        final c = _container(svc: _SuccessAuthService.new);
        await (c.read(resetPasswordControllerProvider.notifier)
              ..updatePassword('abc')
              ..updateConfirmPassword('abc'))
            .submit();
        final s = c.read(resetPasswordControllerProvider);
        expect(s.errorMessage, 'Password is too short');
        expect(s.success, isFalse);
        expect(s.isLoading, isFalse);
      });

      test('passwords mismatch — sets errorMessage, no service call', () async {
        final c = _container(svc: _SuccessAuthService.new);
        await (c.read(resetPasswordControllerProvider.notifier)
              ..updatePassword('validpass1')
              ..updateConfirmPassword('different2'))
            .submit();
        final s = c.read(resetPasswordControllerProvider);
        expect(s.errorMessage, "Password doesn't match");
        expect(s.success, isFalse);
      });

      test('success — sets success:true and clears loading', () async {
        final c = _container(svc: _SuccessAuthService.new);
        await (c.read(resetPasswordControllerProvider.notifier)
              ..updatePassword('validpass1')
              ..updateConfirmPassword('validpass1'))
            .submit();
        final s = c.read(resetPasswordControllerProvider);
        expect(s.success, isTrue);
        expect(s.isLoading, isFalse);
        expect(s.errorMessage, isNull);
      });

      test('failure — sets errorMessage from exception, clears', () async {
        final c = _container(svc: _FailingAuthService.new);
        await (c.read(resetPasswordControllerProvider.notifier)
              ..updatePassword('validpass1')
              ..updateConfirmPassword('validpass1'))
            .submit();
        final s = c.read(resetPasswordControllerProvider);
        expect(s.errorMessage, 'token expired');
        expect(s.isLoading, isFalse);
        expect(s.success, isFalse);
      });
    });
  });
}

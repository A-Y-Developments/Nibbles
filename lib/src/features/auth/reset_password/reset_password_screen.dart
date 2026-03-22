import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_controller.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(
      resetPasswordControllerProvider,
      (_, ResetPasswordState next) {
        if (next.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated. Please log in.'),
            ),
          );
          context.goNamed(AppRoute.login.name);
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Set New Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.xxl),
              Text('Create a new password', style: textTheme.headlineLarge),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Your new password must be at least 8 characters.',
                style:
                    textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
              ),
              const SizedBox(height: AppSizes.xl),
              TextField(
                key: const Key('reset_password_new_field'),
                onChanged: ref
                    .read(resetPasswordControllerProvider.notifier)
                    .updatePassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New password',
                  errorText: state.password.isNotValid &&
                          state.password.value.isNotEmpty
                      ? 'Password must be at least 8 characters.'
                      : null,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                key: const Key('reset_password_confirm_field'),
                onChanged: ref
                    .read(resetPasswordControllerProvider.notifier)
                    .updateConfirmPassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  errorText: state.confirmPassword.isNotEmpty &&
                          !state.passwordsMatch
                      ? 'Passwords do not match.'
                      : null,
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  state.errorMessage!,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('reset_password_submit_button'),
                  onPressed: state.isLoading ? null : () {
                    ref
                        .read(resetPasswordControllerProvider.notifier)
                        .submit();
                  },
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/inputs/app_text_field.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_controller.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(resetPasswordControllerProvider, (_, ResetPasswordState next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated. Please log in.')),
        );
        context.goNamed(AppRoute.login.name);
      }
    });

    final controller = ref.read(resetPasswordControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Set New Password',
          style: textTheme.titleMedium?.copyWith(color: AppColors.fgStrong),
        ),
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
              Text(
                'Create a new password',
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Your new password must be at least 8 characters.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.fgMuted),
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                key: const Key('reset_password_new_field'),
                label: 'New password',
                hintText: 'Enter new password',
                obscureText: true,
                onChanged: controller.updatePassword,
                errorText:
                    state.password.isNotValid &&
                        state.password.value.isNotEmpty
                    ? 'Password must be at least 8 characters.'
                    : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                key: const Key('reset_password_confirm_field'),
                label: 'Confirm password',
                hintText: 'Re-enter new password',
                obscureText: true,
                onChanged: controller.updateConfirmPassword,
                errorText:
                    state.confirmPassword.isNotEmpty && !state.passwordsMatch
                    ? 'Passwords do not match.'
                    : null,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  state.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSizes.xl),
              AppPillButton(
                key: const Key('reset_password_submit_button'),
                label: 'Confirm',
                onPressed: state.isLoading ? null : controller.submit,
                leading: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cream,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

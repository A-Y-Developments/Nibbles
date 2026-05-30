import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/common/components/inputs/app_text_field.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_controller.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-115 — Reset password / AU-03.
///
/// Figma frames 971:10136 (initial guidance), 971:10148 (too short),
/// 971:10160 (mismatch). Background is the Grad-1 token
/// (butterSoft → cream diagonal — same as the forgot-password sibling).
/// Helper text under each field uses Nibble-primary-Forest (#5C7852 →
/// [AppColors.green]) for ALL variants — including the validation
/// failures — per the Figma spec's intentional "guidance tone" choice.
///
/// Verbatim copy (do not paraphrase):
///   title "Forget Password"  (sic — spec mismatch with state-1 flagged)
///   body  "Password must be at least 8 characters"
///   field labels "Password" / "Retype Password"
///   placeholders "Input password" / "Retype password"
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

    void goBack() => context.canPop()
        ? context.pop()
        : context.goNamed(AppRoute.login.name);

    // Per-field helper text — derived from controller state to match the
    // three Figma states. Falls back to the guidance copy when no error.
    const guidance = 'Password must be at least 8 characters';
    final passwordHelper =
        state.passwordTooShort ? 'Password is too short' : guidance;
    final String confirmHelper;
    if (state.confirmTooShort) {
      confirmHelper = 'Password is too short';
    } else if (state.confirmMismatch) {
      confirmHelper = "Password doesn't match";
    } else {
      confirmHelper = guidance;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.19, 0.5],
            colors: [AppColors.butterSoft, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.md,
              AppSizes.pagePaddingH,
              AppSizes.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppRoundButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: goBack,
                    tone: AppRoundButtonTone.butter,
                    semanticLabel: 'Back',
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  // Verbatim from Figma 971:10136 — "Forget Password" (sic).
                  'Forget Password',
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  guidance,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  key: const Key('reset_password_new_field'),
                  label: 'Password',
                  hintText: 'Input password',
                  obscureText: true,
                  onChanged: controller.updatePassword,
                  // Helper text is ALWAYS shown (guidance or error) — render
                  // via errorText slot so the colour swap follows the field
                  // border. Forest-green tone per Figma 971:10148 helper.
                  errorText: passwordHelper,
                  errorColor: AppColors.green,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  key: const Key('reset_password_confirm_field'),
                  label: 'Retype Password',
                  hintText: 'Retype password',
                  obscureText: true,
                  onChanged: controller.updateConfirmPassword,
                  errorText: confirmHelper,
                  errorColor: AppColors.green,
                ),
                if (state.errorMessage != null &&
                    state.errorMessage != 'Password is too short' &&
                    state.errorMessage != "Password doesn't match") ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    state.errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const Spacer(),
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
      ),
    );
  }
}

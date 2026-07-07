import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_controller.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_state.dart';

/// NIB-114 — Forgot password entry + error.
///
/// Figma frames 971:10119 (entry) and 971:10128 (error). Background is the
/// Grad-1 token (butterSoft→cream diagonal — same as login). The error frame
/// adds burgundy inline helper text; we map this onto AppTextField's burgundy
/// errorColor.
///
/// Enumeration safety: Supabase `resetPasswordForEmail` returns success even
/// for unregistered emails (anti-enumeration, by design). We therefore never
/// render a literal "Email doesn't exist" caption (would mislead users and
/// would require a separate existence query — the exact vector this app
/// rejects). Any submit failure collapses to a generic caption.
const String _genericErrorMessage =
    "Couldn't send the reset link. Please try again.";

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordControllerProvider);

    void goBack() => context.pop();

    return GradientScaffold(
      body: SafeArea(
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
                child: _BackPill(onPressed: goBack),
              ),
              const SizedBox(height: AppSizes.lg),
              Expanded(
                child: state.sent
                    ? _ConfirmationView(onBackToLogin: goBack)
                    : _InputView(
                        state: state,
                        onEmailChanged: ref
                            .read(forgotPasswordControllerProvider.notifier)
                            .updateEmail,
                        onSubmit: ref
                            .read(forgotPasswordControllerProvider.notifier)
                            .submit,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputView extends StatelessWidget {
  const _InputView({
    required this.state,
    required this.onEmailChanged,
    required this.onSubmit,
  });

  final ForgotPasswordState state;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // NIB-200: an invalid email (empty or malformed, once the field is dirty)
    // shows the specific validation caption; the generic anti-enumeration
    // caption is reserved for a real backend failure (`errorMessage`). A pure
    // (untouched) field shows nothing until Confirm marks it dirty.
    final inlineError = !state.email.isPure && state.email.isNotValid
        ? 'Please enter a valid email address.'
        : (state.errorMessage != null ? _genericErrorMessage : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Forgot your password?',
          style: textTheme.displaySmall,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          // Verbatim copy from Figma node 971:10119.
          // Smart apostrophe per Figma render.
          'Please enter the email address you’d like your password reset '
          'information sent to',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          key: const Key('forgot_email_field'),
          hintText: 'Email address',
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onChanged: onEmailChanged,
          onSubmitted: (_) => state.isLoading ? null : onSubmit(),
          errorText: inlineError,
          // Figma error frame 971:10128 — Nibble-primary-Burgundy border +
          // caption.
          errorColor: AppColors.burgundy,
        ),
        const Spacer(),
        AppPillButton(
          key: const Key('forgot_submit_button'),
          label: state.isLoading ? 'Sending…' : 'Confirm',
          onPressed: state.isLoading ? null : onSubmit,
        ),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({required this.onBackToLogin});

  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left-align the badge to match the left-aligned title/body below;
        // a bare Container in a stretch column would be forced full-width
        // and the circle would render centered.
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: AppSizes.iconXl + AppSizes.md,
            height: AppSizes.iconXl + AppSizes.md,
            decoration: const BoxDecoration(
              color: AppColors.butter,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: AppSizes.iconLg,
              color: AppColors.greenDeep,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          'Check your email',
          style: textTheme.displaySmall,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          "We've sent you a reset link. Follow it to set a new password.",
          style: textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
          textAlign: TextAlign.left,
        ),
        const Spacer(),
        AppPillButton(
          key: const Key('forgot_back_to_login'),
          label: 'Back to login',
          onPressed: onBackToLogin,
        ),
      ],
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.sp20,
              vertical: AppSizes.sp12,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.greenDeep,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

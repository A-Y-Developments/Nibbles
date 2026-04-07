import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_controller.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(AppRoute.login.name),
        ),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: state.sent
              ? _ConfirmationView(
                  onBackToLogin: () => context.goNamed(AppRoute.login.name),
                )
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.xxl),
        Text('Reset your password', style: textTheme.headlineLarge),
        const SizedBox(height: AppSizes.sm),
        Text(
          "Enter your email and we'll send you a reset link.",
          style: textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
        ),
        const SizedBox(height: AppSizes.xl),
        TextField(
          key: const Key('forgot_email_field'),
          onChanged: onEmailChanged,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.email.isNotValid && state.email.value.isNotEmpty
                ? 'Please enter a valid email.'
                : null,
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            state.errorMessage!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSizes.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('forgot_submit_button'),
            onPressed: state.isLoading ? null : onSubmit,
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
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
        const SizedBox(height: AppSizes.xxl),
        const Icon(
          Icons.mark_email_read_outlined,
          size: AppSizes.iconXl,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.lg),
        Text('Check your email', style: textTheme.headlineLarge),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Check your email for a reset link.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
        ),
        const SizedBox(height: AppSizes.xl),
        Center(
          child: TextButton(
            key: const Key('forgot_back_to_login'),
            onPressed: onBackToLogin,
            child: const Text('Back to Login'),
          ),
        ),
      ],
    );
  }
}

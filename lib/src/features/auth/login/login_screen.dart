import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/auth/login/login_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.xl),
              Text('Welcome back', style: textTheme.headlineLarge),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Log in to continue.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
              ),
              const SizedBox(height: AppSizes.xl),
              TextField(
                key: const Key('login_email_field'),
                onChanged: ref
                    .read(loginControllerProvider.notifier)
                    .updateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText:
                      state.email.isNotValid && state.email.value.isNotEmpty
                      ? 'Please enter a valid email.'
                      : null,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                key: const Key('login_password_field'),
                onChanged: ref
                    .read(loginControllerProvider.notifier)
                    .updatePassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.goNamed(AppRoute.forgotPassword.name),
                  child: const Text('Forgot your password?'),
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  state.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('login_submit_button'),
                  onPressed: state.isLoading
                      ? null
                      : ref.read(loginControllerProvider.notifier).submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Log In'),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: textTheme.bodySmall),
                  TextButton(
                    onPressed: () => context.goNamed(AppRoute.register.name),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

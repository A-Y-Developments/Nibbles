import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/auth/register/register_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
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
              Text('Create your account', style: textTheme.headlineLarge),
              const SizedBox(height: AppSizes.sm),
              Text(
                "Let's get you started.",
                style:
                    textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
              ),
              const SizedBox(height: AppSizes.xl),
              TextField(
                key: const Key('register_name_field'),
                onChanged: ref
                    .read(registerControllerProvider.notifier)
                    .updateName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Your name'),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                key: const Key('register_email_field'),
                onChanged: ref
                    .read(registerControllerProvider.notifier)
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
                key: const Key('register_password_field'),
                onChanged: ref
                    .read(registerControllerProvider.notifier)
                    .updatePassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: state.password.isNotValid &&
                          state.password.value.isNotEmpty
                      ? 'Password must be at least 8 characters.'
                      : null,
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  state.errorMessage!,
                  style:
                      textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('register_submit_button'),
                  onPressed: (!state.isValid || state.isLoading)
                      ? null
                      : () async {
                          final ok = await ref
                              .read(registerControllerProvider.notifier)
                              .submit();
                          if (ok && context.mounted) {
                            context.goNamed(
                              AppRoute.onboardingBabySetup.name,
                            );
                          }
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
                      : const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () =>
                        context.goNamed(AppRoute.login.name),
                    child: const Text('Log In'),
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

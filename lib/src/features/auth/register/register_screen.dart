import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/register/register_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final emailShowError =
        state.email.isNotValid && state.email.value.isNotEmpty;
    final passwordShowError =
        state.password.isNotValid && state.password.value.isNotEmpty;

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
              const SizedBox(height: AppSizes.lg),
              const Center(child: BrandLogo(size: 72)),
              const SizedBox(height: AppSizes.xl),
              Text(
                'Start Your Journey',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Create an account to begin guiding your '
                'little one through solids.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.fgMuted),
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                key: const Key('register_email_field'),
                label: 'Email',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: controller.updateEmail,
                errorText: emailShowError
                    ? 'Please enter a valid email.'
                    : null,
                suffixIcon: state.email.isValid
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: AppSizes.iconMd,
                      )
                    : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                key: const Key('register_password_field'),
                label: 'Password',
                hintText: 'At least 8 characters',
                obscureText: state.obscure,
                textInputAction: TextInputAction.done,
                onChanged: controller.updatePassword,
                errorText: passwordShowError
                    ? 'Password must be at least 8 characters.'
                    : null,
                suffixIcon: _ObscureToggle(
                  obscure: state.obscure,
                  onTap: controller.toggleObscure,
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
              AppPillButton(
                key: const Key('register_submit_button'),
                label: state.isLoading ? 'Signing up…' : 'Sign Up',
                onPressed: (!state.isValid || state.isLoading)
                    ? null
                    : () async {
                        final ok = await controller.submit();
                        if (ok && context.mounted) {
                          context.goNamed(AppRoute.onboardingBabySetup.name);
                        }
                      },
              ),
              const SizedBox(height: AppSizes.lg),
              const _OrDivider(),
              const SizedBox(height: AppSizes.lg),
              _SocialButtons(
                isLoading: state.isLoading,
                onGoogle: () async {
                  final ok = await controller.signInWithGoogle();
                  if (ok && context.mounted) {
                    context.goNamed(AppRoute.onboardingBabySetup.name);
                  }
                },
                onApple: () async {
                  final ok = await controller.signInWithApple();
                  if (ok && context.mounted) {
                    context.goNamed(AppRoute.onboardingBabySetup.name);
                  }
                },
              ),
              const SizedBox(height: AppSizes.xl),
              _LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObscureToggle extends StatelessWidget {
  const _ObscureToggle({required this.obscure, required this.onTap});

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: AppSizes.iconMd,
      child: Icon(
        obscure
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: AppColors.fgMuted,
        size: AppSizes.iconMd,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderSoft)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'Or sign up with',
            style: textTheme.bodySmall?.copyWith(color: AppColors.fgMuted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({
    required this.isLoading,
    required this.onGoogle,
    required this.onApple,
  });

  final bool isLoading;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppPillButton(
            key: const Key('register_google_button'),
            label: 'Google',
            variant: AppPillButtonVariant.secondary,
            onPressed: isLoading ? null : onGoogle,
            // TODO(infra): swap Material icon for brand Google glyph when
            // design/assets/google.svg ships.
            leading: const Icon(Icons.g_mobiledata_rounded),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: AppPillButton(
            key: const Key('register_apple_button'),
            label: 'Apple',
            variant: AppPillButtonVariant.secondary,
            onPressed: isLoading ? null : onApple,
            // TODO(infra): swap Material icon for brand Apple glyph when
            // design/assets/apple.svg ships.
            leading: const Icon(Icons.apple_rounded),
          ),
        ),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
        ),
        TextButton(
          onPressed: () => context.goNamed(AppRoute.login.name),
          child: const Text('Login'),
        ),
      ],
    );
  }
}

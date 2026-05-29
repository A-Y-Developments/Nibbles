import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/login/login_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final hasError = state.errorMessage != null;

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
              const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  // BrandLogo defaults to size 120 (==AppSizes.avatarXl),
                  // matching the NIB-107 spec; FittedBox prevents overflow
                  // on narrow screens.
                  child: BrandLogo(),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                'Hi, Welcome!',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Log in to continue your journey.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                key: const Key('login_email_field'),
                label: 'Email',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: controller.updateEmail,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                key: const Key('login_password_field'),
                label: 'Password',
                hintText: 'Your password',
                obscureText: state.obscure,
                textInputAction: TextInputAction.done,
                onChanged: controller.updatePassword,
                suffixIcon: _ObscureToggle(
                  obscure: state.obscure,
                  onTap: controller.toggleObscure,
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  state.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.goNamed(AppRoute.forgotPassword.name),
                  child: const Text('Forgot your password?'),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppPillButton(
                key: const Key('login_submit_button'),
                label: state.isLoading ? 'Logging in…' : 'Log In',
                onPressed: state.isLoading ? null : controller.submit,
              ),
              const SizedBox(height: AppSizes.lg),
              const _OrDivider(),
              const SizedBox(height: AppSizes.lg),
              _SocialButtons(
                isLoading: state.isLoading,
                onGoogle: controller.signInWithGoogle,
                onApple: controller.signInWithApple,
              ),
              const SizedBox(height: AppSizes.xl),
              _SignUpFooter(),
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
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
            'Or login with',
            style: textTheme.bodySmall?.copyWith(color: AppColors.fgFaint),
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
            key: const Key('login_google_button'),
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
            key: const Key('login_apple_button'),
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

class _SignUpFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
        ),
        TextButton(
          onPressed: () => context.goNamed(AppRoute.register.name),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}

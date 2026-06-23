import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/register/register_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final emailFormatError =
        state.email.isNotValid && state.email.value.isNotEmpty
        ? 'Please enter a valid email.'
        : null;
    final passwordFormatError =
        state.password.isNotValid && state.password.value.isNotEmpty
        ? 'Password must be at least 8 characters.'
        : null;
    final confirmError =
        state.confirmPassword.isNotEmpty && !state.passwordsMatch
        ? "Passwords don't match."
        : null;

    final emailErrorText = state.errorMessage ?? emailFormatError;

    return GradientScaffold(
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
              const Center(child: _SignUpLogoMark()),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Start Your Journey',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                "Create an account to track your baby's\n"
                'nutrition and feeding progress.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                key: const Key('register_email_field'),
                identifier: 'register_email_field',
                label: 'Email address',
                hintText: 'Email address',
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                onChanged: controller.updateEmail,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                errorText: emailErrorText,
                errorColor: AppColors.burgundy,
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
                identifier: 'register_password_field',
                label: 'Password',
                hintText: 'Password',
                obscureText: state.obscure,
                textInputAction: TextInputAction.next,
                focusNode: _passwordFocus,
                onChanged: controller.updatePassword,
                onSubmitted: (_) => _confirmFocus.requestFocus(),
                errorText: passwordFormatError,
                errorColor: AppColors.burgundy,
                suffixIcon: _ObscureToggle(
                  obscure: state.obscure,
                  onTap: controller.toggleObscure,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                key: const Key('register_confirm_field'),
                identifier: 'register_confirm_field',
                label: 'Confirm Password',
                hintText: 'Confirm password',
                obscureText: state.obscureConfirm,
                textInputAction: TextInputAction.done,
                focusNode: _confirmFocus,
                onChanged: controller.updateConfirmPassword,
                onSubmitted: (_) {
                  if (state.isValid && !state.isLoading) {
                    _submit(controller, context);
                  }
                },
                errorText: confirmError,
                errorColor: AppColors.burgundy,
                suffixIcon: _ObscureToggle(
                  obscure: state.obscureConfirm,
                  onTap: controller.toggleObscureConfirm,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              AppPillButton(
                key: const Key('register_submit_button'),
                identifier: 'register_submit_button',
                label: state.isLoading ? 'Signing up…' : 'Sign Up',
                onPressed: (!state.isValid || state.isLoading)
                    ? null
                    : () => _submit(controller, context),
              ),
              const SizedBox(height: AppSizes.md),
              const _OrDivider(),
              const SizedBox(height: AppSizes.md),
              SocialAuthButton(
                key: const Key('register_google_button'),
                identifier: 'register_google_button',
                provider: SocialAuthProvider.google,
                label: 'Sign up with Google',
                isLoading: state.isLoading,
                onPressed: () async {
                  final ok = await controller.signInWithGoogle();
                  if (ok && context.mounted) {
                    context.goNamed(AppRoute.onboardingBabySetup.name);
                  }
                },
              ),
              const SizedBox(height: AppSizes.md),
              SocialAuthButton(
                key: const Key('register_apple_button'),
                identifier: 'register_apple_button',
                provider: SocialAuthProvider.apple,
                label: 'Sign up with Apple',
                isLoading: state.isLoading,
                onPressed: () async {
                  final ok = await controller.signInWithApple();
                  if (ok && context.mounted) {
                    context.goNamed(AppRoute.onboardingBabySetup.name);
                  }
                },
              ),
              const SizedBox(height: AppSizes.xl),
              const _LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(
    RegisterController controller,
    BuildContext context,
  ) async {
    final ok = await controller.submit();
    if (ok && context.mounted) {
      context.goNamed(AppRoute.onboardingBabySetup.name);
    }
  }
}

class _SignUpLogoMark extends StatelessWidget {
  const _SignUpLogoMark();

  static const double _size = 119;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nibbles',
      image: true,
      child: ExcludeSemantics(
        child: Assets.images.auth.nibblesLogo.svg(width: _size, height: _size),
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
    return Semantics(
      button: true,
      toggled: !obscure,
      label: obscure ? 'Show password' : 'Hide password',
      excludeSemantics: true,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.fgMuted,
          size: AppSizes.iconMd,
        ),
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
            style: textTheme.bodyLarge?.copyWith(color: AppColors.fgFaint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
        ),
        Semantics(
          button: true,
          label: 'Login',
          identifier: 'register_login_link',
          excludeSemantics: true,
          child: TextButton(
            key: const Key('register_login_link'),
            onPressed: () => context.goNamed(AppRoute.login.name),
            child: Text(
              'Login',
              style: AppTypography.headline.copyWith(color: AppColors.burgundy),
            ),
          ),
        ),
      ],
    );
  }
}

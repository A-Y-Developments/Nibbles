import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/login/login_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final hasError = state.errorMessage != null;
    final canSubmit = state.email.isValid && state.password.isValid;

    return GradientScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              0,
              AppSizes.pagePaddingH,
              AppSizes.pagePaddingH,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSizes.lg),
                    const Center(child: _LoginLogoMark()),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Hi, Welcome!',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Login to continue tracking your\n'
                      'baby’s healthy growth.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      key: const Key('login_email_field'),
                      identifier: 'login_email_field',
                      label: 'Email address',
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailFocus,
                      onChanged: controller.updateEmail,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      errorColor: AppColors.burgundy,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      key: const Key('login_password_field'),
                      identifier: 'login_password_field',
                      label: 'Password',
                      hintText: 'Password',
                      obscureText: state.obscure,
                      textInputAction: TextInputAction.done,
                      focusNode: _passwordFocus,
                      onChanged: controller.updatePassword,
                      onSubmitted: (_) {
                        if (!state.isLoading && canSubmit) {
                          controller.submit();
                        }
                      },
                      errorText: hasError ? state.errorMessage : null,
                      errorColor: AppColors.burgundy,
                      suffixIcon: _PasswordSuffixIcon(
                        obscure: state.obscure,
                        onToggle: controller.toggleObscure,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Semantics(
                        identifier: 'login_forgot_password_link',
                        child: TextButton(
                          onPressed: () =>
                              context.goNamed(AppRoute.forgotPassword.name),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontFamily: FontFamily.parkinsans,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.burgundy,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    AppPillButton(
                      key: const Key('login_submit_button'),
                      identifier: 'login_submit_button',
                      label: state.isLoading ? 'Logging in…' : 'Login',
                      onPressed: (state.isLoading || !canSubmit)
                          ? null
                          : controller.submit,
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSizes.md),
                    const _OrDivider(),
                    const SizedBox(height: AppSizes.md),
                    SocialAuthButton(
                      key: const Key('login_google_button'),
                      identifier: 'login_google_button',
                      provider: SocialAuthProvider.google,
                      label: 'Login with Google',
                      isLoading: state.isLoading,
                      onPressed: controller.signInWithGoogle,
                    ),
                    const SizedBox(height: AppSizes.md),
                    SocialAuthButton(
                      key: const Key('login_apple_button'),
                      identifier: 'login_apple_button',
                      provider: SocialAuthProvider.apple,
                      label: 'Login with Apple',
                      isLoading: state.isLoading,
                      onPressed: controller.signInWithApple,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    const _SignUpFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginLogoMark extends StatelessWidget {
  const _LoginLogoMark();

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

class _PasswordSuffixIcon extends StatelessWidget {
  const _PasswordSuffixIcon({required this.obscure, required this.onToggle});

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: !obscure,
      label: obscure ? 'Show password' : 'Hide password',
      excludeSemantics: true,
      child: IconButton(
        onPressed: onToggle,
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
            'Or login with',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.fgFaint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
      ],
    );
  }
}

class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don’t have an account?',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
        ),
        Semantics(
          button: true,
          label: 'Sign up',
          identifier: 'login_signup_link',
          excludeSemantics: true,
          child: TextButton(
            key: const Key('login_signup_link'),
            onPressed: () => context.goNamed(AppRoute.register.name),
            child: Text(
              'Sign Up',
              style: AppTypography.headline.copyWith(color: AppColors.burgundy),
            ),
          ),
        ),
      ],
    );
  }
}

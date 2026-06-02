import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/login/login_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-107 — Login screen.
///
/// 3 state variants — empty / filled / error — per Figma frames 971:10029,
/// 1015:10854, 1023:6909. Background is the Grad-1 token (butter→cream).
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

    return Scaffold(
      // Grad-1 — butter→cream diagonal. Frame backdrop applied via the
      // scaffold body container; Scaffold's bg must be transparent.
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.pagePaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.lg),
                const Center(child: _LoginLogoMark()),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Hi, Welcome!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  // Annotation: "split word like this", exactly 2 lines.
                  // Smart apostrophe per Figma copy.
                  'Login to continue tracking your\nbaby’s healthy growth.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  key: const Key('login_email_field'),
                  label: 'Email address',
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocus,
                  onChanged: controller.updateEmail,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  errorColor: AppColors.burgundy,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  key: const Key('login_password_field'),
                  label: 'Password',
                  hintText: 'Password',
                  obscureText: state.obscure,
                  textInputAction: TextInputAction.done,
                  focusNode: _passwordFocus,
                  onChanged: controller.updatePassword,
                  onSubmitted: (_) {
                    if (!state.isLoading && canSubmit) controller.submit();
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
                const SizedBox(height: AppSizes.md),
                AppPillButton(
                  key: const Key('login_submit_button'),
                  label: state.isLoading ? 'Logging in…' : 'Login',
                  onPressed: (state.isLoading || !canSubmit)
                      ? null
                      : controller.submit,
                ),
                const SizedBox(height: AppSizes.lg),
                const _OrDivider(),
                const SizedBox(height: AppSizes.md),
                SocialAuthButton(
                  key: const Key('login_google_button'),
                  provider: SocialAuthProvider.google,
                  label: 'Login with Google',
                  isLoading: state.isLoading,
                  onPressed: controller.signInWithGoogle,
                ),
                const SizedBox(height: AppSizes.md),
                SocialAuthButton(
                  key: const Key('login_apple_button'),
                  provider: SocialAuthProvider.apple,
                  label: 'Login with Apple Account',
                  isLoading: state.isLoading,
                  onPressed: controller.signInWithApple,
                ),
                const SizedBox(height: AppSizes.xl),
                const _SignUpFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Branded mark: butter quatrefoil with the green sage "n" glyph centered.
/// No wordmark (Figma node 1015:13496 — `imgVector`).
class _LoginLogoMark extends StatelessWidget {
  const _LoginLogoMark();

  static const double _size = 119;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Quatrefoil(size: _size, coreColor: AppColors.butter),
          Text(
            'n',
            style: TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 70,
              fontWeight: FontWeight.w800,
              height: 1,
              color: AppColors.greenDeep,
            ),
          ),
        ],
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
          // Smart apostrophe per Figma copy.
          'Don’t have an account?',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
        ),
        Semantics(
          button: true,
          label: 'Sign up',
          excludeSemantics: true,
          child: TextButton(
            key: const Key('login_signup_link'),
            onPressed: () => context.goNamed(AppRoute.register.name),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontFamily: FontFamily.parkinsans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 22 / 15,
                color: AppColors.burgundy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

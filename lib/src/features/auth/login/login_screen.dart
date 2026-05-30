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
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final hasError = state.errorMessage != null;

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
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  key: const Key('login_email_field'),
                  label: 'Email address',
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: controller.updateEmail,
                  errorText: hasError ? state.errorMessage : null,
                  errorColor: AppColors.burgundy,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  key: const Key('login_password_field'),
                  label: 'Password',
                  hintText: 'Password',
                  obscureText: state.obscure,
                  textInputAction: TextInputAction.done,
                  onChanged: controller.updatePassword,
                  errorText: hasError ? state.errorMessage : null,
                  errorColor: AppColors.burgundy,
                  suffixIcon: _PasswordSuffixIcon(
                    obscure: state.obscure,
                    hasError: hasError,
                    onToggle: controller.toggleObscure,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppPillButton(
                  key: const Key('login_submit_button'),
                  label: state.isLoading ? 'Logging in…' : 'Login',
                  onPressed: state.isLoading ? null : controller.submit,
                ),
                const SizedBox(height: AppSizes.lg),
                const _OrDivider(),
                const SizedBox(height: AppSizes.md),
                _GoogleLoginButton(
                  isLoading: state.isLoading,
                  onPressed: controller.signInWithGoogle,
                ),
                const SizedBox(height: AppSizes.md),
                _AppleLoginButton(
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
          Quatrefoil(
            size: _size,
            coreColor: AppColors.butter,
          ),
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
  const _PasswordSuffixIcon({
    required this.obscure,
    required this.hasError,
    required this.onToggle,
  });

  final bool obscure;
  final bool hasError;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    // Error variant (Figma login-3) shows a check glyph in the password
    // suffix instead of the eye toggle — odd, but per spec.
    if (hasError) {
      return const Icon(
        Icons.check_rounded,
        color: AppColors.burgundy,
        size: AppSizes.iconMd,
      );
    }
    return InkResponse(
      onTap: onToggle,
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
            style: textTheme.bodyLarge?.copyWith(color: AppColors.fgFaint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
      ],
    );
  }
}

/// White pill with the Google "G" mark + black "Login with Google" label.
class _GoogleLoginButton extends StatelessWidget {
  const _GoogleLoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading;
    return Material(
      key: const Key('login_google_button'),
      color: AppColors.surface,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.borderSoft),
      ),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: AppSizes.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _GoogleGlyph(size: 24),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Login with Google',
                style: TextStyle(
                  fontFamily: FontFamily.parkinsans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 20 / 13,
                  color: disabled ? AppColors.fgMuted : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stylized Google "G" mark — single-color blue brand glyph rendered as a
/// circular badge with the "G" letterform centered. Used in lieu of bundling a
/// brand SVG; the social sign-in row only needs an unmistakable recognition
/// cue.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.size});

  // Google Brand "Mountain View" blue — recognised brand primary.
  static const Color _googleBlue = Color(0xFF4285F4);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _googleBlue,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontSize: size * 0.66,
          fontWeight: FontWeight.w700,
          height: 1,
          color: AppColors.surface,
        ),
      ),
    );
  }
}

/// Black pill with the Apple glyph + white "Login with Apple Account" label.
class _AppleLoginButton extends StatelessWidget {
  const _AppleLoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading;
    return Material(
      key: const Key('login_apple_button'),
      color: AppColors.text,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: AppSizes.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.apple_rounded,
                color: AppColors.surface,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Login with Apple Account',
                style: TextStyle(
                  fontFamily: FontFamily.parkinsans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 20 / 13,
                  color: disabled ? AppColors.fgFaint : AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
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
        const SizedBox(width: AppSizes.xs),
        InkWell(
          key: const Key('login_signup_link'),
          onTap: () => context.goNamed(AppRoute.register.name),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.xs,
            ),
            child: Text(
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

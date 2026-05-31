import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/auth/register/register_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-112 — Sign Up screen.
///
/// 2 state variants — initial / error — per Figma frames 1023:6996 (initial)
/// and 1023:7060 (error). Mirrors the NIB-107 login redesign layout (Grad-1
/// butter→cream gradient, quatrefoil mark, stacked full-width social pills,
/// burgundy footer link).
class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    // Inline format hints — only surface when the user has typed an obviously
    // invalid value (not while still empty). Server-side errors take
    // precedence so the field shows the verbatim controller errorMessage
    // exactly once.
    final emailFormatError =
        state.email.isNotValid && state.email.value.isNotEmpty
            ? 'Please enter a valid email.'
            : null;
    final passwordFormatError =
        state.password.isNotValid && state.password.value.isNotEmpty
            ? 'Password must be at least 8 characters.'
            : null;

    final emailErrorText = state.errorMessage ?? emailFormatError;
    final passwordErrorText = passwordFormatError;

    return Scaffold(
      // Grad-1 — butter→cream diagonal. Scaffold bg transparent so the
      // gradient DecoratedBox underneath is visible.
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
                const Center(child: _SignUpLogoMark()),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Start Your Journey',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  // Annotation: "Make sure the line same with design, make it 2
                  // line and split word like this". Smart apostrophe per Figma.
                  "Create an account to track your baby's\n"
                  'nutrition and feeding progress.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  key: const Key('register_email_field'),
                  label: 'Email address',
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: controller.updateEmail,
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
                  label: 'Password',
                  hintText: 'Password',
                  obscureText: state.obscure,
                  textInputAction: TextInputAction.done,
                  onChanged: controller.updatePassword,
                  errorText: passwordErrorText,
                  errorColor: AppColors.burgundy,
                  suffixIcon: _ObscureToggle(
                    obscure: state.obscure,
                    onTap: controller.toggleObscure,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppPillButton(
                  key: const Key('register_submit_button'),
                  label: state.isLoading ? 'Signing up…' : 'Sign Up',
                  onPressed: (!state.isValid || state.isLoading)
                      ? null
                      : () async {
                          final ok = await controller.submit();
                          if (ok && context.mounted) {
                            context.goNamed(
                              AppRoute.onboardingBabySetup.name,
                            );
                          }
                        },
                ),
                const SizedBox(height: AppSizes.lg),
                const _OrDivider(),
                const SizedBox(height: AppSizes.md),
                _GoogleSignUpButton(
                  isLoading: state.isLoading,
                  onPressed: () async {
                    final ok = await controller.signInWithGoogle();
                    if (ok && context.mounted) {
                      context.goNamed(AppRoute.onboardingBabySetup.name);
                    }
                  },
                ),
                const SizedBox(height: AppSizes.md),
                _AppleSignUpButton(
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
      ),
    );
  }
}

/// Branded mark: butter quatrefoil with the green sage "n" glyph centered.
/// Matches Figma node 1023:7000 (imgGroup75, 119x119).
class _SignUpLogoMark extends StatelessWidget {
  const _SignUpLogoMark();

  static const double _size = 119;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nibbles',
      image: true,
      child: const ExcludeSemantics(
        child: SizedBox(
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

/// White pill with the Google "G" mark + black "Sign Up with Google" label.
class _GoogleSignUpButton extends StatelessWidget {
  const _GoogleSignUpButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading;
    return Material(
      key: const Key('register_google_button'),
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
                'Sign Up with Google',
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
    return ExcludeSemantics(
      child: Container(
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
      ),
    );
  }
}

/// Black pill with the Apple glyph + white "Sign Up with Apple Account" label.
class _AppleSignUpButton extends StatelessWidget {
  const _AppleSignUpButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading;
    return Material(
      key: const Key('register_apple_button'),
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
                'Sign Up with Apple Account',
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
        const SizedBox(width: AppSizes.xs),
        InkWell(
          key: const Key('register_login_link'),
          onTap: () => context.goNamed(AppRoute.login.name),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.xs,
            ),
            child: Text(
              'Login',
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

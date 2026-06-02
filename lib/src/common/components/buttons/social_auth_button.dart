import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Social identity provider rendered by [SocialAuthButton].
enum SocialAuthProvider { google, apple }

/// Full-width social sign-in pill shared by Login (NIB-107) and Sign Up
/// (NIB-112). Renders the real brand logos exported from Figma — Google's
/// multicolour "G" (`google_logo.svg`) on a white pill, Apple's mark
/// (`apple_logo.png`) on a black pill — matching Figma 865:9185 / 865:11282.
///
/// Replaces the per-screen `_GoogleGlyph` / `_Google*Button` / `_Apple*Button`
/// widgets that previously duplicated this markup and faked the logos.
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.provider,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final SocialAuthProvider provider;
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  static const double _logoSize = 28;

  bool get _isApple => provider == SocialAuthProvider.apple;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading;
    final background = _isApple ? AppColors.text : AppColors.surface;
    final foreground = _isApple
        ? (disabled ? AppColors.fgFaint : AppColors.surface)
        : (disabled ? AppColors.fgMuted : AppColors.text);
    final shape = _isApple
        ? const StadiumBorder()
        : const StadiumBorder(side: BorderSide(color: AppColors.borderSoft));

    return Material(
      color: background,
      shape: shape,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: AppSizes.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(child: _logo(disabled)),
              const SizedBox(width: AppSizes.sp12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontFamily.parkinsans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 20 / 13,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo(bool disabled) {
    if (_isApple) {
      return Image.asset(
        Assets.images.auth.appleLogo.path,
        width: _logoSize,
        height: _logoSize,
        fit: BoxFit.contain,
        color: disabled ? AppColors.fgFaint : null,
      );
    }
    // Google brand guidelines: never recolour the "G" — keep it full colour
    // even when the button is disabled (only the label dims).
    return SvgPicture.asset(
      Assets.images.auth.googleLogo.path,
      width: _logoSize,
      height: _logoSize,
    );
  }
}

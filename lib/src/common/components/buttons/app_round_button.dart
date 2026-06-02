import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Background tone for [AppRoundButton] — maps to kit `.rbtn--*`.
enum AppRoundButtonTone { white, ghost, green, butter, lime }

/// Sizing for [AppRoundButton]. `regular` = 44 circle, `small` = 32 circle.
enum AppRoundButtonSize { regular, small }

/// Circular icon button used in headers / overlays. Mirrors kit `.rbtn`.
class AppRoundButton extends StatelessWidget {
  const AppRoundButton({
    required this.icon,
    required this.onPressed,
    this.tone = AppRoundButtonTone.white,
    this.size = AppRoundButtonSize.regular,
    this.semanticLabel,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final AppRoundButtonTone tone;
  final AppRoundButtonSize size;
  final String? semanticLabel;

  double get _diameter => size == AppRoundButtonSize.small
      ? AppSizes.roundButtonSm
      : AppSizes.roundButton;

  Color get _background {
    switch (tone) {
      case AppRoundButtonTone.white:
        return AppColors.surface;
      case AppRoundButtonTone.ghost:
        return Colors.transparent;
      case AppRoundButtonTone.green:
        return AppColors.greenDeep;
      case AppRoundButtonTone.butter:
        return AppColors.butter;
      case AppRoundButtonTone.lime:
        return AppColors.lime;
    }
  }

  Color get _foreground =>
      tone == AppRoundButtonTone.green ? AppColors.cream : AppColors.greenDeep;

  @override
  Widget build(BuildContext context) {
    final iconSize = size == AppRoundButtonSize.small ? 18.0 : 22.0;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: _background,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _diameter,
            height: _diameter,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(color: _foreground, size: iconSize),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

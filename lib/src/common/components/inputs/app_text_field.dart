import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Labelled text field. Mirrors kit `.field` (h48, radiusMd, bgInput fill,
/// sage focus shadow) + `label.field-label` (14/700) and the error state
/// (#E53E3E border + caption error text).
class AppTextField extends StatefulWidget {
  const AppTextField({
    this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.errorColor,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
    this.suffixIcon,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.identifier,
    super.key,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hintText;

  /// When non-null the field renders its error state (red border + caption).
  final String? errorText;

  /// Optional override for the error border + caption colour. Defaults to
  /// [AppColors.error] (#E53E3E). Used by screens whose Figma spec calls for a
  /// non-default tone (e.g. NIB-66 baby-name uses burgundy / destructive).
  final Color? errorColor;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  /// Optional trailing widget rendered inside the field (e.g. a valid-email
  /// checkmark or a password visibility toggle).
  final Widget? suffixIcon;

  /// Forwarded to [TextField.autocorrect]. Pass `false` for email fields.
  final bool autocorrect;

  /// Forwarded to [TextField.enableSuggestions]. Pass `false` for email fields.
  final bool enableSuggestions;

  /// Forwarded to [TextField.textCapitalization].
  final TextCapitalization textCapitalization;

  /// Stable semantics identifier for UI automation (maps to
  /// accessibilityIdentifier on iOS).
  final String? identifier;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _ownsNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsNode = true;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = _focusNode.hasFocus;
    final errorColor = widget.errorColor ?? AppColors.error;

    OutlineInputBorder borderOf(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        // Single box driven by the field's own InputDecoration — no wrapping
        // container and no hard-edged focus shadow (the previous spreadRadius
        // BoxShadow rendered a phantom second border). Border + fill + error
        // caption + suffix icon are all native decoration slots.
        Semantics(
          identifier: widget.identifier,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            textCapitalization: widget.textCapitalization,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgStrong,
            ),
            cursorColor: AppColors.greenDeep,
            decoration: InputDecoration(
              filled: true,
              fillColor: focused ? AppColors.surface : AppColors.bgInput,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sp12 + 1,
              ),
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.greenSoft,
              ),
              suffixIcon: widget.suffixIcon,
              enabledBorder: borderOf(AppColors.borderSoft, 1),
              disabledBorder: borderOf(AppColors.borderSoft, 1),
              focusedBorder: borderOf(AppColors.greenDeep, 2),
              errorBorder: borderOf(errorColor, 1),
              focusedErrorBorder: borderOf(errorColor, 2),
              errorText: widget.errorText,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

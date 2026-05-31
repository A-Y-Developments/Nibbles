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
    final hasError = widget.errorText != null;
    final focused = _focusNode.hasFocus;
    final errorColor = widget.errorColor ?? AppColors.error;

    final borderColor = hasError
        ? errorColor
        : focused
            ? AppColors.greenDeep
            : AppColors.borderSoft;

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
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: AppSizes.fieldHeight,
          decoration: BoxDecoration(
            color: focused ? AppColors.surface : AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: borderColor,
              width: focused || hasError ? 2 : 1,
            ),
            boxShadow: focused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.18),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md - 2),
          child: Row(
            children: [
              Expanded(
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
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.greenSoft,
                    ),
                  ),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: AppSizes.sm),
                widget.suffixIcon!,
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: errorColor),
          ),
        ],
      ],
    );
  }
}

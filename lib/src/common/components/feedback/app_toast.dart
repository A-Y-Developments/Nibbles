import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:toastification/toastification.dart';

/// How long a toast stays on screen before auto-dismissing. Matches the P2
/// error-level spec (`.claude/rules/error-handling.md`): "auto-dismiss 3s".
const Duration kAppToastDuration = Duration(seconds: 3);

enum _AppToastTone { success, error }

/// App-wide toast, shown top-of-screen via `toastification` (renders in the
/// root [Overlay] — unlike a [SnackBar], it always paints above modal bottom
/// sheets, so no per-sheet `ScaffoldMessenger` workaround is needed).
///
/// Use [AppToast.success] for a positive confirmation (e.g. "Item added")
/// and [AppToast.error] for a P2 non-blocking failure — anything the app's
/// error-handling rules classify as P0/P1 (fatal / blocking) must stay a
/// full-screen error or inline/modal retry, never a toast.
class AppToast {
  const AppToast._();

  static void success(BuildContext context, String message) =>
      _show(context, message, tone: _AppToastTone.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, tone: _AppToastTone.error);

  static void _show(
    BuildContext context,
    String message, {
    required _AppToastTone tone,
  }) {
    toastification.showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: kAppToastDuration,
      builder: (context, item) => _AppToastBanner(message: message, tone: tone),
    );
  }
}

class _AppToastBanner extends StatelessWidget {
  const _AppToastBanner({required this.message, required this.tone});

  final String message;
  final _AppToastTone tone;

  @override
  Widget build(BuildContext context) {
    final isSuccess = tone == _AppToastTone.success;
    final background = isSuccess
        ? AppColors.butter
        : AppColors.error.withValues(alpha: 0.12);
    final foreground = isSuccess ? AppColors.greenDeep : AppColors.error;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sp12,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: foreground),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

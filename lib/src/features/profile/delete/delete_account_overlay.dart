import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_controller.dart';
import 'package:nibbles/src/features/profile/delete/widgets/reason_choice_row.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// 6 reason strings — verbatim copy from Figma 1216:11954 (NIB-78 spec).
/// Order matches the Figma canvas top-to-bottom. The selected string is
/// passed verbatim to `AccountService.deleteAccount(reason)`.
const List<String> _kReasons = [
  'I achieved my goal already',
  'I experienced technical issues',
  'The app no longer fits my needs',
  'I had trouble using the app',
  'I’m taking a break and may come back later',
  'Other',
];

/// Opens the Delete Account reason overlay (Figma 1216:11954).
///
/// Modal bottom sheet, `isScrollControlled: true`. Returns once dismissed —
/// either by Cancel/close, by tapping the scrim, or after a successful
/// deletion (the sheet pops itself before signOut triggers the redirect).
Future<void> showDeleteAccountOverlay(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        // Figma sheet top corner radius = 30.
        top: Radius.circular(AppSizes.radius3xl),
      ),
    ),
    // isDismissible and enableDrag are wired dynamically inside the sheet
    // via a ValueNotifier so the sheet rebuilds when submitting starts.
    builder: (_) => const _DeleteAccountSheet(),
  );
}

class _DeleteAccountSheet extends ConsumerStatefulWidget {
  const _DeleteAccountSheet();

  @override
  ConsumerState<_DeleteAccountSheet> createState() =>
      _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<_DeleteAccountSheet> {
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    // Fire screen_view('delete_account_overlay') once on mount via post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await ref
          .read(analyticsProvider)
          .logScreenView(screenName: 'delete_account_overlay');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  Future<void> _onContinue() async {
    final reason = _selectedReason;
    if (reason == null) return;

    // Final gate before the irreversible call — must confirm intent.
    final confirmed = await _confirmDeletion();
    if (!mounted || confirmed != true) return;

    // Intent event — fires only after the user confirms, right BEFORE the
    // destructive call. Reason is one of the 6 hardcoded `_kReasons` strings
    // (stable enum, NOT PII / NOT free text).
    unawaited(
      ref.read(analyticsProvider).logAccountDeletionStarted(reason: reason),
    );

    // The controller pops this sheet (via onBeforeSignOut) right before it
    // signs out, so the sheet is gone before the GoRouter redirect fires —
    // avoids the navigator re-entrancy crash. On failure it's never called and
    // the sheet stays open with the inline error + retry.
    await ref
        .read(deleteAccountControllerProvider.notifier)
        .submit(
          reason,
          onBeforeSignOut: () async {
            if (mounted) Navigator.of(context).pop();
          },
        );
  }

  Future<bool?> _confirmDeletion() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('delete_account_confirm_dialog'),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Delete account?',
          style: AppTypography.sectionTitle.copyWith(color: AppColors.text),
        ),
        content: Text(
          "This permanently deletes your account and data. This can't be "
          'undone.',
          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
            color: AppColors.subtext,
            height: 22 / 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          0,
          AppSizes.md,
          AppSizes.md,
        ),
        actions: [
          TextButton(
            key: const Key('delete_account_confirm_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.fgMuted),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('delete_account_confirm_button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.onGreen,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final state = ref.watch(deleteAccountControllerProvider);
    final theme = Theme.of(context);
    final submitting = state.isSubmitting;
    final reasonPicked = _selectedReason != null;

    return PopScope(
      canPop: !submitting,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
          child: Padding(
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: SingleChildScrollView(
              child: Padding(
                // Figma column inset: left/right 16, top 37, bottom 27.
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  37,
                  AppSizes.md,
                  27,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SheetHeader(
                      onClose: submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                    // Header-to-heading gap.
                    const SizedBox(height: AppSizes.lg),
                    // Title 2 / Bold — Parkinsans 20/28, Black (#2c2c2c), left.
                    Text(
                      'Tell us why you want to delete your account',
                      textAlign: TextAlign.left,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.text,
                        height: 28 / 20,
                      ),
                    ),
                    // Figma: heading-to-chips gap = 24.
                    const SizedBox(height: AppSizes.lg),
                    for (var i = 0; i < _kReasons.length; i++) ...[
                      ReasonChoiceRow(
                        key: Key('delete_reason_$i'),
                        label: _kReasons[i],
                        selected: _selectedReason == _kReasons[i],
                        onTap: submitting
                            ? () {}
                            : () => setState(() {
                                _selectedReason = _kReasons[i];
                              }),
                      ),
                      // Figma: gap between choices = 12.
                      if (i != _kReasons.length - 1)
                        const SizedBox(height: AppSizes.sp12),
                    ],
                    // Chips-to-warning gap.
                    const SizedBox(height: AppSizes.md),
                    const _DeleteWarning(),
                    AnimatedSize(
                      duration: AppDurations.base,
                      curve: AppCurves.standard,
                      alignment: Alignment.topCenter,
                      child: state.errorMessage != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: AppSizes.sp12,
                              ),
                              child: _InlineError(
                                message: state.errorMessage!,
                                onRetry: reasonPicked && !submitting
                                    ? _onContinue
                                    : null,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    // Figma: warning-to-CTA stack gap (column → bottom stack).
                    const SizedBox(height: AppSizes.lg),
                    _ContinueButton(
                      enabled: reasonPicked && !submitting,
                      submitting: submitting,
                      onPressed: _onContinue,
                    ),
                    // Figma: Continue-to-Cancel gap = 12.
                    const SizedBox(height: AppSizes.sp12),
                    _CancelButton(
                      enabled: !submitting,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    // Figma close affordance: 34x33 pill (radius 30), left-aligned.
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 34,
        height: 33,
        child: IconButton(
          key: const Key('delete_account_close_button'),
          icon: const Icon(Icons.close, size: AppSizes.iconMd),
          color: AppColors.text,
          onPressed: onClose,
          tooltip: 'Close',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 33),
          style: IconButton.styleFrom(shape: const CircleBorder()),
        ),
      ),
    );
  }
}

/// Boxed irreversibility warning — soft destructive tint + alert glyph so the
/// finality reads with weight (the reason picker above stays warm/friendly).
class _DeleteWarning extends StatelessWidget {
  const _DeleteWarning();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: AppSizes.iconMd,
            color: AppColors.destructive,
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Text(
              'After your account is deleted, you will permanently lose '
              'your profile, meal history, preferences, and subscription '
              'data. This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.destructive,
                height: 22 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Continue" CTA — destructive red fill signalling the irreversible action.
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.enabled,
    required this.submitting,
    required this.onPressed,
  });

  final bool enabled;
  final bool submitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppPillButton(
      key: const Key('delete_account_continue_button'),
      label: submitting ? 'Deleting…' : 'Continue',
      variant: AppPillButtonVariant.destructive,
      size: AppPillButtonSize.small,
      onPressed: enabled ? onPressed : null,
    );
  }
}

/// Figma "Cancel" CTA — transparent bg, no border, Black (#2c2c2c) text,
/// h42, radius 24, full-width. No existing `AppPillButton` variant matches
/// (`secondary` has a green border and green text), so render directly.
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? AppColors.text : AppColors.fgFaint;
    return Material(
      key: const Key('delete_account_cancel_button'),
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: 42,
          width: double.infinity,
          child: Center(
            child: Text(
              'Cancel',
              style: AppTypography.headline.copyWith(color: fg),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.destructive.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: AppSizes.iconSm + 2,
            color: AppColors.destructive,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              key: const Key('delete_account_retry_button'),
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.destructive,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

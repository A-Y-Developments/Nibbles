import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
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
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        // Figma sheet top corner radius = 30.
        top: Radius.circular(30),
      ),
    ),
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

    // Intent event — fires BEFORE the destructive call. Reason is one of the
    // 6 hardcoded `_kReasons` strings (stable enum, NOT PII / NOT free text).
    unawaited(
      ref.read(analyticsProvider).logAccountDeletionStarted(reason: reason),
    );

    final ok = await ref
        .read(deleteAccountControllerProvider.notifier)
        .submit(reason);

    if (!mounted) return;
    // On success, dismiss the sheet so it doesn't linger over the post-redirect
    // /auth/login (or /onboarding/intro since flags were just cleared). Modal
    // bottom sheets aren't popped by GoRouter redirects — pop it explicitly.
    if (ok) Navigator.of(context).pop();
    // On failure, leave the sheet open; the controller has populated
    // `errorMessage` and the UI rebuilds with the inline error + retry.
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final state = ref.watch(deleteAccountControllerProvider);
    final theme = Theme.of(context);
    final submitting = state.isSubmitting;
    final reasonPicked = _selectedReason != null;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * 0.92,
        ),
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
                  // Figma: header-to-heading gap = 24.
                  const SizedBox(height: AppSizes.lg),
                  const _BrandLockup(),
                  // Figma: lockup-to-heading gap = 24.
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
                  // Figma: chips-to-warning gap = 12 (column gap).
                  const SizedBox(height: AppSizes.sp12),
                  // Callout / Regular — Figtree 14/22, Black (#2c2c2c), left.
                  Text(
                    'After your account is deleted, you will permanently lose '
                    'your profile, meal history, preferences, and subscription '
                    'data. This action cannot be undone.',
                    textAlign: TextAlign.left,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.text,
                      height: 22 / 14,
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSizes.sp12),
                    _InlineError(
                      message: state.errorMessage!,
                      onRetry: reasonPicked && !submitting ? _onContinue : null,
                    ),
                  ],
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
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        key: const Key('delete_account_close_button'),
        icon: const Icon(Icons.close, size: AppSizes.iconMd),
        color: AppColors.text,
        onPressed: onClose,
        tooltip: 'Close',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSizes.roundButtonSm,
          minHeight: AppSizes.roundButtonSm,
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Figma wordmark: 173x42 — render as Parkinsans Bold, Black (#2c2c2c).
        Text(
          'nibbles',
          style: AppTypography.brandWordmark.copyWith(
            fontSize: 36,
            color: AppColors.text,
            letterSpacing: -0.72,
          ),
        ),
        const SizedBox(width: AppSizes.sp12),
        // Figma Nibble-Icon-2 mascot: 42x42 lime square with crown glyph.
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.butter,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: const Text(
            '👑',
            style: TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 22,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Figma "Continue" CTA — lime fill (#eaec8c) + green-deep text. Maps 1:1 to
/// the kit `pillbtn--ghost` variant (butter bg + greenDeep fg, h42 small).
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
      variant: AppPillButtonVariant.ghost,
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
              style: AppTypography.button.copyWith(
                fontFamily: FontFamily.parkinsans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fg,
                height: 22 / 15,
              ),
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

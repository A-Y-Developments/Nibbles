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

/// 6 reason strings — hardcoded per NIB-78 spec. The selected string is
/// passed verbatim to `AccountService.deleteAccount(reason)`.
const List<String> _kReasons = [
  "I'm not getting value from the app",
  "I'm using a different app",
  'Too many notifications / not enough',
  'Privacy concerns',
  'I had a bad experience',
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
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
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
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.sm,
                AppSizes.pagePaddingH,
                AppSizes.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHeader(
                    onClose: submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Why are you leaving us?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.fgStrong,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'We’d love a quick reason so we can keep improving for '
                    'other little ones.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.fgMuted,
                    ),
                  ),
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
                    if (i != _kReasons.length - 1)
                      const SizedBox(height: AppSizes.sm),
                  ],
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.destructive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    _InlineError(
                      message: state.errorMessage!,
                      onRetry: reasonPicked && !submitting ? _onContinue : null,
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  AppPillButton(
                    key: const Key('delete_account_continue_button'),
                    label: submitting ? 'Deleting…' : 'Continue',
                    variant: AppPillButtonVariant.destructive,
                    onPressed: (reasonPicked && !submitting)
                        ? _onContinue
                        : null,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  AppPillButton(
                    key: const Key('delete_account_cancel_button'),
                    label: 'Cancel',
                    variant: AppPillButtonVariant.ghost,
                    onPressed: submitting
                        ? null
                        : () => Navigator.of(context).pop(),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: AppSizes.sm),
            child: _BrandLockup(),
          ),
        ),
        IconButton(
          key: const Key('delete_account_close_button'),
          icon: const Icon(Icons.close, size: AppSizes.iconMd),
          color: AppColors.fgMuted,
          onPressed: onClose,
          tooltip: 'Close',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AppSizes.roundButtonSm,
            minHeight: AppSizes.roundButtonSm,
          ),
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'nibbles',
          style: AppTypography.brandWordmark.copyWith(
            fontSize: 28,
            letterSpacing: -0.56,
          ),
        ),
        const SizedBox(width: AppSizes.xs),
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.butter,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: const Text(
            '👑',
            style: TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 16,
              height: 1,
            ),
          ),
        ),
      ],
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

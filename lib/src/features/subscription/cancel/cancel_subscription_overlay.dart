import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_reason.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_subscription_controller.dart';
import 'package:nibbles/src/features/subscription/cancel/widgets/cancel_reason_chip.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Verbatim sheet title from Figma 1216:12029. The apostrophe is a U+2019
/// curly apostrophe — never paraphrase.
const _kHeading = 'Tell us why you’re canceling';

/// Verbatim copy from the ticket for the P2 URL-open failure path.
const _kLaunchFailureCopy = "Couldn't open subscription settings. Try again.";

/// Opens the cancel-subscription reason overlay (Figma 1216:12019).
///
/// Modal bottom sheet, `isScrollControlled: true`. Returns once dismissed —
/// either by Cancel / close, by tapping the scrim, or after a successful
/// deep-link to the store-managed subscription page.
///
/// Failure to open the management URL is a **P2** event: the overlay pops
/// itself and surfaces a transient SnackBar on the parent route (NOT an
/// inline error block — that's the P1 delete-account treatment).
Future<void> showCancelSubscriptionOverlay(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Figma sheet fill: Nibble-primary-white (#fffdf8).
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        // Figma sheet top corner radius = 30.
        top: Radius.circular(30),
      ),
    ),
    builder: (_) => const _CancelSubscriptionSheet(),
  );
}

class _CancelSubscriptionSheet extends ConsumerStatefulWidget {
  const _CancelSubscriptionSheet();

  @override
  ConsumerState<_CancelSubscriptionSheet> createState() =>
      _CancelSubscriptionSheetState();
}

class _CancelSubscriptionSheetState
    extends ConsumerState<_CancelSubscriptionSheet> {
  CancelReason? _selectedReason;

  /// Local ScaffoldMessenger key. SnackBars must render via this messenger
  /// (NOT the parent-route messenger) — modal bottom sheets paint above the
  /// parent Scaffold's body, so a parent SnackBar lands behind the sheet
  /// and is invisible. The local ScaffoldMessenger wrapping the sheet body
  /// (below) puts the toast in front.
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // screen_view fires once on mount via post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await ref
          .read(analyticsProvider)
          .logScreenView(screenName: 'cancel_subscription_overlay');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  Future<void> _onContinue() async {
    final reason = _selectedReason;
    if (reason == null) return;

    // Capture the navigator BEFORE the await. The messenger lookup goes
    // through the local key (below) so the toast renders inside the sheet.
    final navigator = Navigator.of(context);

    final ok = await ref
        .read(cancelSubscriptionControllerProvider.notifier)
        .submit(reason);

    if (!mounted) return;
    if (ok) {
      // Success — dismiss the overlay. The deep-link has already handed off
      // to the OS subscription UI; the parent Manage Subscription screen
      // remains visible underneath.
      navigator.pop();
    } else {
      // P2 failure — keep the sheet open so the user can retry, and show a
      // transient toast on the sheet's local messenger so it paints above
      // the bottom sheet's content.
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(
          key: Key('cancel_subscription_failure_snackbar'),
          content: Text(_kLaunchFailureCopy),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final state = ref.watch(cancelSubscriptionControllerProvider);
    final theme = Theme.of(context);
    final submitting = state.isSubmitting;
    final reasonPicked = _selectedReason != null;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        // Transparent so the sheet's `backgroundColor` (set in
        // showModalBottomSheet, AppColors.background) shows through and the
        // rounded top corners aren't clipped by an opaque scaffold.
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
                      // Figma: header-to-lockup gap = 24.
                      const SizedBox(height: AppSizes.lg),
                      const _BrandLockup(),
                      // Figma: lockup-to-heading gap = 24.
                      const SizedBox(height: AppSizes.lg),
                      // Title 2 / Bold — Parkinsans 20/28, Black (#2c2c2c), left.
                      Text(
                        _kHeading,
                        key: const Key('cancel_subscription_heading'),
                        textAlign: TextAlign.left,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          height: 28 / 20,
                        ),
                      ),
                      // Figma: heading-to-chips gap = 24.
                      const SizedBox(height: AppSizes.lg),
                      for (var i = 0; i < CancelReason.values.length; i++) ...[
                        CancelReasonChip(
                          key: Key('cancel_subscription_reason_$i'),
                          label: CancelReason.values[i].label,
                          selected: _selectedReason == CancelReason.values[i],
                          onTap: submitting
                              ? () {}
                              : () => setState(() {
                                  _selectedReason = CancelReason.values[i];
                                }),
                        ),
                        // Figma: gap between choices = 12.
                        if (i != CancelReason.values.length - 1)
                          const SizedBox(height: AppSizes.sp12),
                      ],
                      // Figma: chips-to-CTA stack gap (column → bottom stack).
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
          key: const Key('cancel_subscription_close_button'),
          icon: const Icon(Icons.close, size: AppSizes.iconMd),
          color: AppColors.text,
          onPressed: onClose,
          tooltip: 'Close',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 33),
          style: IconButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand lockup — `nibbles` wordmark + butter crown badge.
///
/// Mirrors `_BrandLockup` from `manage_subscription_screen.dart` (the screen
/// that opens this sheet) so the visual rhythm is consistent. Sized to the
/// Figma values: wordmark 173x42, crown badge 42x42 (vs. the 26x26 inline
/// variant on the parent screen).
class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    // 42px wordmark height matches Figma's 869:7532 (h=42) and lines up with
    // the brand wordmark token's intrinsic 42px size — no scaling needed.
    final wordmark = AppTypography.brandWordmark.copyWith(
      color: AppColors.text,
    );

    return Row(
      key: const Key('cancel_subscription_brand_lockup'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('nibbles', style: wordmark),
        const SizedBox(width: AppSizes.sp12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.butter,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            size: 28,
            color: AppColors.greenDeep,
          ),
        ),
      ],
    );
  }
}

/// Figma "Continue" CTA — lime fill (#eaec8c) + ForestDarkn text. Maps 1:1 to
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
      key: const Key('cancel_subscription_continue_button'),
      label: submitting ? 'Opening…' : 'Continue',
      variant: AppPillButtonVariant.ghost,
      size: AppPillButtonSize.small,
      onPressed: enabled ? onPressed : null,
    );
  }
}

/// Figma "Cancel" CTA — transparent bg, no border, Black (#2c2c2c) text,
/// h42, radius 24, full-width. No existing [AppPillButton] variant matches
/// (`secondary` has a green border and green text), so render directly.
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? AppColors.text : AppColors.fgFaint;
    return Material(
      key: const Key('cancel_subscription_cancel_button'),
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
              style: AppTypography.headline.copyWith(
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

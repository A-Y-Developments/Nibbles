import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/brand_logo.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/subscription_offering.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_controller.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Opens [PaywallSheet] as a modal bottom sheet (Figma "Overlay - subsplan",
/// frame 1216:11727). Top corners are rounded 30 per spec; the sheet is
/// `isScrollControlled` so the content can fill ~92% of screen height on
/// short devices without clipping the trial card / CTAs.
///
/// Returns once the sheet is dismissed (Close X, scrim tap, or a successful
/// purchase that pops the sheet from inside).
Future<void> showPaywallSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => const PaywallSheet(),
  );
}

/// Stateless sheet body. Hosted directly inside [showPaywallSheet] for the
/// real entry-point flow (Go Premium → bottom sheet) and inside
/// `PaywallScreen` as a full-page scaffold so the existing
/// `/subscription/paywall` GoRoute still compiles. The two surfaces share
/// state via the same [paywallControllerProvider] instance.
class PaywallSheet extends ConsumerStatefulWidget {
  const PaywallSheet({super.key});

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await ref
          .read(analyticsProvider)
          .logScreenView(screenName: 'paywall');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  Future<void> _onPurchase() async {
    final controller = ref.read(paywallControllerProvider.notifier);
    final result = await controller.purchaseDefault();
    if (!mounted) return;
    result.whenOrNull(
      success: (_) {
        // Pop the sheet on success — the upstream `Go Premium` caller can
        // route to the subscription success screen if it wants to (NIB-130).
        Navigator.of(context).pop();
      },
      failure: (error) {
        _showErrorDialog(
          title: 'Purchase failed',
          message: error.message,
        );
      },
    );
  }

  Future<void> _onRestore() async {
    final controller = ref.read(paywallControllerProvider.notifier);
    final result = await controller.restore();
    if (!mounted) return;
    result.whenOrNull(
      success: (_) {
        Navigator.of(context).pop();
      },
      failure: (error) {
        // Per error-handling.md, restore failure surfaces as P1 with the
        // canonical "No active subscription found." copy when the seam
        // returns NotFoundException; otherwise show the underlying message.
        final message = error is NotFoundException
            ? 'No active subscription found.'
            : error.message;
        _showErrorDialog(
          title: 'Restore failed',
          message: message,
        );
      },
    );
  }

  void _onViewAllPlans() {
    // TODO(NIB-61): push the All-plans picker sheet when it ships.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        key: Key('paywall_view_all_plans_snackbar'),
        content: Text('All plans coming soon.'),
      ),
    );
  }

  Future<void> _showErrorDialog({
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('paywall_error_dialog'),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paywallControllerProvider);
    final media = MediaQuery.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * 0.92,
        ),
        // Sheet padding from Figma: px 24 / py 12.
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.sp12,
          ),
          child: _PaywallBody(
            state: state,
            onClose: state.action == PaywallAction.none
                ? () => Navigator.of(context).pop()
                : null,
            onRestore: state.action == PaywallAction.none ? _onRestore : null,
            onPurchase: state.action == PaywallAction.none && state.phase ==
                    PaywallPhase.ready
                ? _onPurchase
                : null,
            onViewAllPlans: state.action == PaywallAction.none
                ? _onViewAllPlans
                : null,
            onRetry: state.action == PaywallAction.none
                ? () => ref
                    .read(paywallControllerProvider.notifier)
                    .reloadOfferings()
                : null,
          ),
        ),
      ),
    );
  }
}

/// Pure presentational body — no provider reads. Lets us drive every state
/// variant from widget tests without spinning up a riverpod container.
class _PaywallBody extends StatelessWidget {
  const _PaywallBody({
    required this.state,
    required this.onClose,
    required this.onRestore,
    required this.onPurchase,
    required this.onViewAllPlans,
    required this.onRetry,
  });

  final PaywallState state;
  final VoidCallback? onClose;
  final VoidCallback? onRestore;
  final VoidCallback? onPurchase;
  final VoidCallback? onViewAllPlans;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          onClose: onClose,
          onRestore: onRestore,
          restoreSpinning: state.action == PaywallAction.restoring,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: _ScrollContent(
              state: state,
              onRetry: onRetry,
            ),
          ),
        ),
        // Footer column gap to scroll content == 24 (Figma column gap).
        const SizedBox(height: AppSizes.lg),
        _Footer(
          onPurchase: onPurchase,
          onViewAllPlans: onViewAllPlans,
          purchasing: state.action == PaywallAction.purchasing,
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.onClose,
    required this.onRestore,
    required this.restoreSpinning,
  });

  final VoidCallback? onClose;
  final VoidCallback? onRestore;
  final bool restoreSpinning;

  @override
  Widget build(BuildContext context) {
    // Figma row: 34x33 close (radius 30) ↔ 148x42 Restore purchase pill.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 34,
          height: 33,
          child: IconButton(
            key: const Key('paywall_close_button'),
            icon: const Icon(Icons.close, size: AppSizes.iconMd),
            color: AppColors.text,
            onPressed: onClose,
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 33,
            ),
            style: IconButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: TextButton(
            key: const Key('paywall_restore_purchase_button'),
            onPressed: onRestore,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              shape: const StadiumBorder(),
              minimumSize: const Size(148, 42),
            ),
            child: restoreSpinning
                ? const SizedBox(
                    width: AppSizes.iconSm,
                    height: AppSizes.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.text,
                    ),
                  )
                : Text(
                    'Restore purchase',
                    style: AppTypography.button.copyWith(
                      fontFamily: FontFamily.parkinsans,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 22 / 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ScrollContent extends StatelessWidget {
  const _ScrollContent({required this.state, required this.onRetry});

  final PaywallState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column gap from header to logo == 24 per spec.
        const SizedBox(height: AppSizes.lg),
        const _BrandRow(),
        const SizedBox(height: AppSizes.lg),
        const _Heading(),
        const SizedBox(height: AppSizes.lg),
        const _FeatureRows(),
        const SizedBox(height: AppSizes.lg),
        const _SocialProof(),
        const SizedBox(height: AppSizes.lg),
        switch (state.phase) {
          PaywallPhase.loading => const _TrialCardLoading(),
          PaywallPhase.error => _TrialCardError(
            message: state.errorMessage ?? 'Could not load offering.',
            onRetry: onRetry,
          ),
          PaywallPhase.ready => _TrialCard(
            offering: state.offering ??
                // Defensive — phase=ready always carries an offering.
                const SubscriptionOffering(
                  productId: '',
                  priceString: '',
                  periodLabel: '',
                  trialDays: 0,
                ),
          ),
        },
      ],
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    // Figma: 173x42 wordmark + 12 gap + 42x42 Nibble-Icon-2 (crown/bee).
    // SVG asset isn't in the repo yet — use the existing brand lockup + a
    // butter circular placeholder for the mascot per precedent
    // (delete_account_overlay). TODO(NIB-55): swap to real mascot SVG when
    // assets/svgs/nibble_icon_2.svg lands.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // BrandLogo at size 42 ≈ 162px wordmark, close to the 173 spec width
        // without per-pixel hand-tuning.
        const BrandLogo(size: 42),
        const SizedBox(width: AppSizes.sp12),
        Container(
          key: const Key('paywall_mascot_placeholder'),
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.butter,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            // Crown stand-in for the Figma bee/crown mascot — closest
            // material icon until the real SVG ships.
            Icons.workspace_premium,
            color: AppColors.greenDeep,
            size: AppSizes.iconMd,
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    // Title 1 / Bold — Parkinsans 22/34 (matches theme `headlineSmall`/`titleLarge`
    // height ratio 34/22 = 1.545; theme is 1.273 from a different ramp, so
    // override the line-height explicitly to the Figma spec).
    return Text(
      'Everything you need for safe feeding',
      style: AppTypography.textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 34 / 22,
        color: AppColors.text,
      ),
    );
  }
}

class _FeatureRows extends StatelessWidget {
  const _FeatureRows();

  @override
  Widget build(BuildContext context) {
    // Per ticket: "All three feature rows currently share the sub-title …
    // likely a copy placeholder per the audit. Wait for PO confirmation
    // before substituting." — keep verbatim.
    const subtitle = 'Clear guidance for the big 9';
    const rows = [
      ('Introduce allergens safely', subtitle, true),
      ('Get 300+ recipe', subtitle, false),
      ('Meal Planning', subtitle, false),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          _FeatureRow(
            title: rows[i].$1,
            subtitle: rows[i].$2,
            roundedThumb: rows[i].$3,
          ),
          if (i != rows.length - 1) const SizedBox(height: AppSizes.lg),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.title,
    required this.subtitle,
    required this.roundedThumb,
  });

  final String title;
  final String subtitle;

  /// First-row thumbnail uses rounded corners (radius 10) per spec — the
  /// other two rows are unclipped 68x68 tiles.
  final bool roundedThumb;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.coralSoft,
            borderRadius: roundedThumb
                ? BorderRadius.circular(AppSizes.radiusMd)
                : null,
          ),
          // TODO(NIB-55): replace with the Figma `Intersect` / nuts-table /
          // meal-plan thumbnail PNGs when the assets land in
          // assets/images/paywall/. Until then a neutral coral tile keeps
          // the rhythm without shipping the wrong art.
          child: const Icon(
            Icons.restaurant_outlined,
            color: AppColors.coralDeep,
          ),
        ),
        const SizedBox(width: AppSizes.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: FontFamily.parkinsans,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 22 / 15,
                  color: AppColors.text,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 22 / 15,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialProof extends StatelessWidget {
  const _SocialProof();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.xs + 2),
              child: Icon(
                Icons.star_rounded,
                size: 22,
                color: AppColors.coral,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        const Text(
          'Already help 150+ parents',
          style: TextStyle(
            fontFamily: FontFamily.parkinsans,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 22 / 15,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

/// Trial card — ready state. Renders the real RC-sourced price out of
/// [SubscriptionOffering] (no hardcoded `$29.99` literal — AC requirement).
class _TrialCard extends StatelessWidget {
  const _TrialCard({required this.offering});

  final SubscriptionOffering offering;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('paywall_trial_card'),
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.switchTrackOff),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // Verbatim copy: "3 Days Free" (capitalised exactly as Figma).
            '${offering.trialDays} Days Free',
            style: const TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 22 / 15,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          RichText(
            text: TextSpan(
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 22 / 15,
                color: AppColors.text,
              ),
              children: [
                const TextSpan(text: 'Then billed at '),
                TextSpan(
                  // Figma calls out Nunito Bold inline for the price token.
                  text:
                      '${offering.priceString} ${offering.periodLabel}',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 22 / 15,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialCardLoading extends StatelessWidget {
  const _TrialCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('paywall_trial_card_loading'),
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.switchTrackOff),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const Center(
        child: SizedBox(
          width: AppSizes.iconMd,
          height: AppSizes.iconMd,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.greenDeep,
          ),
        ),
      ),
    );
  }
}

class _TrialCardError extends StatelessWidget {
  const _TrialCardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('paywall_trial_card_error'),
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.destructiveSoft,
        border: Border.all(color: AppColors.destructive.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              key: const Key('paywall_offerings_retry_button'),
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

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onPurchase,
    required this.onViewAllPlans,
    required this.purchasing,
  });

  final VoidCallback? onPurchase;
  final VoidCallback? onViewAllPlans;
  final bool purchasing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary CTA — h48 / radius 24 / Forest-dark fill.
          SizedBox(
            height: 48,
            child: Material(
              color: onPurchase == null
                  ? AppColors.borderMuted
                  : AppColors.greenDeep,
              shape: const StadiumBorder(),
              child: InkWell(
                key: const Key('paywall_try_for_zero_button'),
                onTap: onPurchase,
                customBorder: const StadiumBorder(),
                child: Center(
                  child: purchasing
                      ? const SizedBox(
                          width: AppSizes.iconMd,
                          height: AppSizes.iconMd,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.cream,
                          ),
                        )
                      : Text(
                          r'Try for $0',
                          style: AppTypography.button.copyWith(
                            fontFamily: FontFamily.parkinsans,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream,
                            height: 22 / 15,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          // Secondary CTA — transparent bg, Black text, h48.
          SizedBox(
            height: 48,
            child: Material(
              color: Colors.transparent,
              shape: const StadiumBorder(),
              child: InkWell(
                key: const Key('paywall_view_all_plans_button'),
                onTap: onViewAllPlans,
                customBorder: const StadiumBorder(),
                child: Center(
                  child: Text(
                    'View all plans',
                    style: AppTypography.button.copyWith(
                      fontFamily: FontFamily.parkinsans,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 22 / 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

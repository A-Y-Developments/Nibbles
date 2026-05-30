import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/petal_blob.dart';

/// Two-phase composition used by passive loading -> "You all set!"
/// confirmation screens.
///
/// `loading` — petal blob + faint uppercase "Loading" caption.
/// `success` — petal blob + bold success label; the caption stays mounted at
/// low opacity so the cross-fade does not shift the layout.
enum LoadingConfirmationPhase {
  loading,
  success,
}

/// NIB-131 — reusable loading -> confirmation composite.
///
/// Extracted from the NIB-130 post-purchase transition so any flow whose audit
/// resolves to a "Loading + You all set!" composition (frame ids 1290:10122,
/// 1216:11584, etc.) can reuse the same petal animation + cross-fade slot
/// without duplicating geometry. Callers own:
///   * which `phase` to render (driven by their controller),
///   * the success copy (verbatim from the audit they map to),
///   * unique widget keys for the blob / labels so screen-level tests can
///     assert against them.
///
/// This widget is purely presentational — no controllers, no analytics, no
/// auto-route. Hosts wrap it in their own `ConsumerWidget` to wire those in.
class LoadingConfirmation extends StatelessWidget {
  const LoadingConfirmation({
    required this.phase,
    required this.successLabel,
    this.blobKey,
    this.loadingLabelKey,
    this.successLabelKey,
    super.key,
  });

  final LoadingConfirmationPhase phase;
  final String successLabel;
  final Key? blobKey;
  final Key? loadingLabelKey;
  final Key? successLabelKey;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.butterSoft,
      child: SafeArea(
        // SizedBox.expand forces the Stack to fill the SafeArea — without it
        // the Stack collapses to its non-positioned child (_PetalBlob) and
        // the cluster snaps to the upper-left.
        child: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PetalBlob(key: blobKey),
              _PhaseLabel(
                phase: phase,
                successLabel: successLabel,
                loadingLabelKey: loadingLabelKey,
                successLabelKey: successLabelKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phase caption — faint uppercase "Loading" sits below the petal animation
/// in both phases; the success caption fades in below it. Both labels stay
/// mounted with opacity gating so layout never shifts on transition.
class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel({
    required this.phase,
    required this.successLabel,
    required this.loadingLabelKey,
    required this.successLabelKey,
  });

  final LoadingConfirmationPhase phase;
  final String successLabel;
  final Key? loadingLabelKey;
  final Key? successLabelKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSuccess = phase == LoadingConfirmationPhase.success;

    return Positioned.fill(
      child: Stack(
        children: [
          // "Loading" — Inter Regular 12.8 / tracking 4.33 / UPPERCASE,
          // rendered low-contrast (cream on butter-soft) per Figma spec.
          // Stays visible (faded) during the success phase to match the
          // cross-fade snapshot in the audit.
          Align(
            alignment: const Alignment(0, 0.34),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              opacity: isSuccess ? 0.55 : 1,
              child: Text(
                'Loading'.toUpperCase(),
                key: loadingLabelKey,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.cream,
                  fontSize: 12.8,
                  height: 19.2 / 12.8,
                  letterSpacing: 4.33,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // Success label sits just below LOADING so the two captions read
          // as a tight cluster (Figma: cancel-flow + no-plan refs both show
          // ~14% gap, not the old ~26%). Slot is always laid out; opacity
          // gates visibility so there's zero layout shift on transition.
          Align(
            alignment: const Alignment(0, 0.43),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md + AppSizes.sp2,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 240),
                opacity: isSuccess ? 1 : 0,
                child: Text(
                  successLabel,
                  key: successLabelKey,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
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

import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

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
              _PetalBlob(key: blobKey),
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

/// Layered petal mark mimicking the Figma `LoadingAnimation` frame: a pale
/// outer quatrefoil + a sage inner quatrefoil + a soft butter glow dot at
/// the core (the bare circle reads as flat without the glow).
class _PetalBlob extends StatelessWidget {
  const _PetalBlob({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.avatarXl * 1.84,
      height: AppSizes.avatarXl * 1.84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pale-butter petal blob (spec petal layer 1+2 composite).
          const Quatrefoil(
            size: AppSizes.avatarXl * 1.84,
            coreColor: AppColors.butter,
          ),
          // Inner sage petal — smaller, scales down to ~52% of outer.
          const Quatrefoil(
            size: AppSizes.avatarXl * 0.96,
            petalColor: AppColors.green,
            coreColor: AppColors.greenDeep,
          ),
          // Soft butter glow dot at the center (spec blurred lime dot).
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.butter,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.butter.withValues(alpha: 0.9),
                  blurRadius: AppSizes.sm,
                  spreadRadius: AppSizes.xs,
                ),
              ],
            ),
            child: const SizedBox(
              width: AppSizes.sp12 * 1.4,
              height: AppSizes.sp12 * 1.4,
            ),
          ),
        ],
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
          // Success label below the animation. Always laid out so the slot
          // is reserved during the loading phase too; opacity gates
          // visibility so there's zero layout shift on transition.
          Align(
            alignment: const Alignment(0, 0.6),
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
                    fontWeight: FontWeight.w600,
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

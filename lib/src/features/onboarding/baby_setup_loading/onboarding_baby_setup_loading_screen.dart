import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/features/onboarding/baby_setup_loading/baby_setup_loading_controller.dart';
import 'package:nibbles/src/features/onboarding/baby_setup_loading/baby_setup_loading_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-137 — passive post-consent loading transition.
///
/// Reached from `OnboardingConsentScreen` after `createBaby` resolves and
/// `onboarding_done` is set true. The screen owns no data calls: it renders
/// a static petal-blob frame for [BabySetupLoadingController.minDwell] and
/// then auto-pushes /home.
///
/// Visuals (Figma node 1290:10122 — "You all set!" celebration):
///   - Solid cream (#FFFCD5 — `AppColors.butterSoft`) background.
///   - Brand flower cluster center-screen with faint uppercase "LOADING"
///     caption layered inside (cream-on-cream, low contrast per spec). The
///     OUTER butter quatrefoil rotates continuously (~9s/rev, linear) while
///     the CENTER glow dot pulses gently (~1.2s, reverse-repeat). The inner
///     sage quatrefoil stays static.
///   - Footer tagline ("We need several data to know more about your babys")
///     anchored ~70% down screen, Figtree SemiBold 15/22, black.
///
/// Back-nav is blocked while the screen is mounted so kill-and-resume after
/// a consent submit does not let the user re-enter the consent form with the
/// baby already created. Once the auto-route fires the GoRouter redirect
/// gates this path anyway (onboarding_done is true).
class OnboardingBabySetupLoadingScreen extends ConsumerStatefulWidget {
  const OnboardingBabySetupLoadingScreen({super.key});

  @override
  ConsumerState<OnboardingBabySetupLoadingScreen> createState() =>
      _OnboardingBabySetupLoadingScreenState();
}

class _OnboardingBabySetupLoadingScreenState
    extends ConsumerState<OnboardingBabySetupLoadingScreen>
    with TickerProviderStateMixin {
  /// Full revolution of the outer petals — "not fast, not slow" per owner,
  /// linear so the spin reads as a steady bloom, never a jolt.
  static const Duration _rotationPeriod = Duration(seconds: 9);

  /// Center-glow pulse half-cycle. Reverse-repeats so the dot breathes
  /// gently between [_glowPulseMin] and full scale.
  static const Duration _pulsePeriod = Duration(milliseconds: 1200);

  /// Lower bound of the glow pulse scale (full scale = 1.0).
  static const double _glowPulseMin = 0.85;

  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _glowPulse;

  /// Footer copy — verbatim from the Figma audit (incl. the flagged grammar
  /// issue: "several data" treated singular + missing apostrophe on "babys").
  /// PO has the rewrite "We need some data to learn more about your baby." on
  /// the open-questions list; until that lands here this stays byte-for-byte
  /// to keep the visual diff clean.
  static const String footerCopy =
      'We need several data to know more about your babys';

  /// Caption inside the petal cluster — Figma renders the word "Loading" in
  /// title case but at a tracking/contrast where the eye reads it as caps;
  /// uppercased here to match the LoadingConfirmation convention (NIB-130).
  static const String loadingCaption = 'LOADING';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: _rotationPeriod,
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: _pulsePeriod,
    );
    _glowPulse = Tween<double>(begin: 1, end: _glowPulseMin).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_logScreenView());
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _logScreenView() async {
    try {
      await Analytics.instance.logScreenView(
        screenName: 'onboarding_baby_setup_loading',
      );
    } on Object catch (_) {
      // Best-effort — never surface to the UI.
    }
  }

  void _goHome() {
    if (!mounted) return;
    context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Listen (not watch) so the auto-route side-effect fires exactly on the
    // loading -> ready edge. Watching would re-fire on every rebuild after
    // the phase has already flipped. No `ref.watch` is needed: both phases
    // render identically, and the `ref.listen` registration itself is what
    // mounts the controller on first build.
    ref.listen<BabySetupLoadingPhase>(
      babySetupLoadingControllerProvider,
      (prev, next) {
        if (next == BabySetupLoadingPhase.ready &&
            prev != BabySetupLoadingPhase.ready) {
          _goHome();
        }
      },
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.butterSoft,
        body: Semantics(
          label: 'Setting up your baby profile',
          liveRegion: true,
          container: true,
          child: SafeArea(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative cluster — excluded from semantics; the outer
                  // live-region Semantics covers the loading state.
                  ExcludeSemantics(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _AnimatedPetalBlob(
                          key: const Key(
                            'onboarding_baby_setup_loading_blob',
                          ),
                          rotation: _rotationController,
                          glowPulse: _glowPulse,
                        ),
                        Padding(
                          // Nudge the caption slightly below the blob's optical
                          // center so it reads under the inner sage quatrefoil
                          // (matches the audit snapshot).
                          padding: const EdgeInsets.only(top: AppSizes.xxl),
                          child: Text(
                            loadingCaption,
                            key: const Key(
                              'onboarding_baby_setup_loading_caption',
                            ),
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
                      ],
                    ),
                  ),
                  // Footer tagline anchored ~70% down screen — Figma footer at
                  // bottom 611 of an 874 height (≈30% from the bottom = 0.40
                  // on the y axis once expressed as Alignment(0, y)).
                  Align(
                    alignment: const Alignment(0, 0.40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH,
                      ),
                      child: Text(
                        footerCopy,
                        key: const Key('onboarding_baby_setup_loading_footer'),
                        textAlign: TextAlign.center,
                        // Body/SemiBold (Figtree 15/22 w600) per audit token map.
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
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

/// Brand flower for the "You all set!" celebration — a decomposed `PetalBlob`
/// so the outer petals can rotate independently of the pulsing center.
///
/// Geometry mirrors `PetalBlob` byte-for-byte (outer = avatarXl*1.84, inner
/// ~52% of outer, glow ratio sp12*1.4/outer) so the static frame is visually
/// identical to the consent screen's cluster.
///   - Outer butter [Quatrefoil] wrapped in a [RotationTransition].
///   - Inner sage [Quatrefoil] — static.
///   - Soft butter glow dot wrapped in a [ScaleTransition] driven by the pulse.
class _AnimatedPetalBlob extends StatelessWidget {
  const _AnimatedPetalBlob({
    required this.rotation,
    required this.glowPulse,
    super.key,
  });

  final Animation<double> rotation;
  final Animation<double> glowPulse;

  @override
  Widget build(BuildContext context) {
    const outerSize = AppSizes.avatarXl * 1.84;
    const baseInner = AppSizes.avatarXl * 0.96;
    const baseGlow = AppSizes.sp12 * 1.4;
    const innerSize = outerSize * (baseInner / outerSize);
    const glowSize = outerSize * (baseGlow / outerSize);

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: rotation,
            child: const Quatrefoil(
              size: outerSize,
              coreColor: AppColors.butter,
            ),
          ),
          const Quatrefoil(
            size: innerSize,
            petalColor: AppColors.green,
            coreColor: AppColors.greenDeep,
          ),
          ScaleTransition(
            scale: glowPulse,
            child: DecoratedBox(
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
              child: const SizedBox(width: glowSize, height: glowSize),
            ),
          ),
        ],
      ),
    );
  }
}

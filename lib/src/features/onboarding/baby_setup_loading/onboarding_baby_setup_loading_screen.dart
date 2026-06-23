import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
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
/// Visuals (Figma node 2458:27249 — post-baby-setup loading):
///   - Solid cream (#FFFCD5 — `AppColors.butterSoft`) background.
///   - Brand flower cluster center-screen. The OUTER butter quatrefoil rotates
///     continuously (~9s/rev, linear) while the CENTER glow dot pulses gently
///     (~1.2s, reverse-repeat); the inner sage quatrefoil stays static. A faint
///     gold ring circles the cluster with a single gold dot orbiting it
///     (~2.5s/rev), the dot sharing the center-glow pulse.
///   - Footer tagline ("We need several data to know more about your babys")
///     anchored ~70% down screen (Figtree SemiBold 15/22, black) with an
///     animated three-dot ellipsis below it.
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
    extends ConsumerState<OnboardingBabySetupLoadingScreen> {
  /// Footer copy — verbatim from the Figma audit (incl. the flagged grammar
  /// issue: "several data" treated singular + missing apostrophe on "babys").
  /// PO has the rewrite "We need some data to learn more about your baby." on
  /// the open-questions list; until that lands here this stays byte-for-byte
  /// to keep the visual diff clean.
  static const String footerCopy =
      'We need several data to know more about your babys';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_logScreenView());
    });
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
    ref.listen<BabySetupLoadingPhase>(babySetupLoadingControllerProvider, (
      prev,
      next,
    ) {
      if (next == BabySetupLoadingPhase.ready &&
          prev != BabySetupLoadingPhase.ready) {
        _goHome();
      }
    });

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
                  const ExcludeSemantics(
                    child: BrandFlowerLoader(
                      blobKey: Key('onboarding_baby_setup_loading_blob'),
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
                      child: AnimatedEllipsisText(
                        key: const Key('onboarding_baby_setup_loading_footer'),
                        text: footerCopy,
                        // Body/SemiBold (Figtree 15/22 w600) per audit token.
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

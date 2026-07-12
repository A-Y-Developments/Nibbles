import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/splash/splash_controller.dart';
import 'package:nibbles/src/logging/analytics.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Emit screen_view('splash') once on the first frame. Guarded + unawaited
    // so an uninitialised Firebase / analytics hiccup never throws into the
    // frame callback or blocks the splash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await Analytics.instance.logScreenView(screenName: 'splash');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    // whenData fires only on the success (data) state — never on loading or
    // error — so navigation runs once and never double-fires on a P0.
    ref.listen<AsyncValue<String>>(
      splashControllerProvider,
      (_, next) => next.whenData(context.go),
    );

    final state = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.green,
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: AppDurations.fade,
            switchInCurve: AppCurves.standard,
            switchOutCurve: AppCurves.standard,
            child: state.hasError
                ? KeyedSubtree(
                    key: const ValueKey('splash_error'),
                    child: _buildError(context, isReloading: state.isLoading),
                  )
                : KeyedSubtree(
                    key: const ValueKey('splash_branding'),
                    child: _buildBranding(context),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Welcome to',
            style: TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 22 / 15,
              color: AppColors.cream,
            ),
          ).animate().fadeIn(duration: AppDurations.slow),
          const SizedBox(height: 17),
          Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: Assets.images.nibblesLogo.image(
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              )
              .animate()
              .fadeIn(delay: 120.ms, duration: AppDurations.slow)
              .scale(
                delay: 120.ms,
                duration: AppDurations.slow,
                curve: AppCurves.emphasized,
                begin: const Offset(0.88, 0.88),
                end: const Offset(1, 1),
              ),
        ],
      ),
    );
  }

  /// P0 boot failure: full-screen maroon-accented message on cream + a primary
  /// 'Try again' CTA that re-runs the whole boot (incl. session restore).
  ///
  /// While a retry is re-running the build (the previous error is carried over
  /// during the brand-minimum delay), the CTA is disabled so rapid taps can't
  /// keep restarting boot — guards against a tight retry loop when offline.
  Widget _buildError(BuildContext context, {required bool isReloading}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: AppSizes.iconXl,
            color: AppColors.destructive,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            "We couldn't get things ready. Please check your connection "
            'and try again.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.destructive),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          if (isReloading)
            Semantics(
              label: 'Try again, retrying',
              enabled: false,
              button: true,
              liveRegion: true,
              child: const SizedBox(
                height: AppSizes.buttonHeightSm,
                child: Center(
                  child: SizedBox.square(
                    dimension: AppSizes.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.destructive,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            AppPillButton(
              label: 'Try again',
              expand: false,
              onPressed: () => ref.invalidate(splashControllerProvider),
            ),
        ],
      ),
    );
  }
}

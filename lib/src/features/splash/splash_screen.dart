import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/splash/splash_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // whenData fires only on the success (data) state — never on loading or
    // error — so navigation runs once and never double-fires on a P0.
    ref.listen<AsyncValue<String>>(
      splashControllerProvider,
      (_, next) => next.whenData(context.go),
    );

    final state = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: state.hasError
              ? _buildError(context, ref, isReloading: state.isLoading)
              : _buildBranding(context),
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Quatrefoil(size: AppSizes.avatarXl),
        SizedBox(height: AppSizes.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'nibbles',
            style: AppTypography.brandWordmark,
          ),
        ),
      ],
    );
  }

  /// P0 boot failure: full-screen maroon-accented message on cream + a primary
  /// 'Try again' CTA that re-runs the whole boot (incl. session restore).
  ///
  /// While a retry is re-running the build (the previous error is carried over
  /// during the brand-minimum delay), the CTA is disabled so rapid taps can't
  /// keep restarting boot — guards against a tight retry loop when offline.
  Widget _buildError(
    BuildContext context,
    WidgetRef ref, {
    required bool isReloading,
  }) {
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.destructive,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          AppPillButton(
            label: 'Try again',
            expand: false,
            onPressed: isReloading
                ? null
                : () => ref.invalidate(splashControllerProvider),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/splash/splash_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(
      splashControllerProvider,
      (_, next) => next.whenData(context.go),
    );

    final state = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: state.hasError
              ? _buildError(context, state.error)
              : _buildBranding(context),
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          child: const Icon(
            Icons.child_care_rounded,
            color: AppColors.onPrimary,
            size: AppSizes.iconXl,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          'Nibbles',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object? error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: AppSizes.iconXl,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            error?.toString() ??
                'Something went wrong. Please restart the app.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

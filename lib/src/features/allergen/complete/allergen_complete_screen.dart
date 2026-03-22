import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/allergen/complete/allergen_complete_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class AllergenCompleteScreen extends ConsumerWidget {
  const AllergenCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(allergenCompleteControllerProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(allergenCompleteControllerProvider.notifier).markShown();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (s) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.pagePaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.xl),
                  Center(
                    child: const Text(
                      '🎉',
                      style: TextStyle(fontSize: 80),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    '${s.babyName} has passed all 9 allergens! '
                    'Well done.',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    "You've done an incredible job introducing allergens "
                    'safely. Keep enjoying a wide variety of foods together!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.subtext,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  const SizedBox(height: AppSizes.xl),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    alignment: WrapAlignment.center,
                    children: s.allergens
                        .map(
                          (a) => Chip(
                            avatar: Text(
                              a.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            label: Text(a.name),
                            backgroundColor:
                                AppColors.allergenSafe.withValues(alpha: 0.15),
                            side: const BorderSide(
                              color: AppColors.allergenSafe,
                            ),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.allergenSafe),
                          ),
                        )
                        .toList(),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                  const SizedBox(height: AppSizes.xxl),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(allergenCompleteControllerProvider.notifier)
                          .markShown();
                      context.goNamed(AppRoute.profile.name);
                    },
                    child: const Text('View in Profile'),
                  ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/meal_plan_ai_service.dart';

/// Arguments for the full-screen AI generation loading route. Handed in via
/// `GoRouterState.extra`.
class AiLoadingArgs {
  const AiLoadingArgs({
    required this.babyId,
    required this.babyName,
    required this.startDate,
    required this.endDate,
    required this.preferences,
    required this.notes,
  });

  final String babyId;
  final String babyName;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> preferences;
  final String notes;
}

/// Outcome popped by [AiLoadingScreen] once generation resolves.
class AiLoadingResult {
  const AiLoadingResult({required this.success, this.errorMessage});

  final bool success;
  final String? errorMessage;
}

/// Full-screen, non-dismissable loading route shown while the AI builds the
/// meal plan. Runs [MealPlanAiService.generateAndPersist] on mount and pops
/// with an [AiLoadingResult]. Wrapped in `PopScope(canPop: false)` so the
/// user cannot back out mid-generation.
class AiLoadingScreen extends ConsumerStatefulWidget {
  const AiLoadingScreen({required this.args, super.key});

  final AiLoadingArgs args;

  @override
  ConsumerState<AiLoadingScreen> createState() => _AiLoadingScreenState();
}

class _AiLoadingScreenState extends ConsumerState<AiLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    final args = widget.args;
    final result = await ref
        .read(mealPlanAiServiceProvider)
        .generateAndPersist(
          babyId: args.babyId,
          startDate: args.startDate,
          endDate: args.endDate,
          preferences: args.preferences,
          notes: args.notes,
        );
    if (!mounted) return;
    context.pop(
      AiLoadingResult(
        success: result.isSuccess,
        errorMessage: result.errorOrNull?.message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GradientScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandFlowerLoader(),
                const SizedBox(height: AppSizes.xl),
                Text(
                  "Building ${widget.args.babyName}'s plan…",
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.displaySmall,
                ).animate().fadeIn(duration: AppDurations.fade),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Picking recipes and mapping them across your days.',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.fgMuted,
                  ),
                ).animate().fadeIn(
                  delay: AppDurations.quick,
                  duration: AppDurations.fade,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_icon_tile.dart';

/// Pre-introduce bottom sheet (Figma 2780:13939). Explains the 3-time
/// introduction plan and starts the allergen on confirm. Resolves to `true`
/// only when the introduction was successfully started.
Future<bool> showStartIntroduceSheet(
  BuildContext context, {
  required Allergen allergen,
  required String babyId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StartIntroduceSheet(allergen: allergen, babyId: babyId),
  );
  return result ?? false;
}

class _TimeStep {
  const _TimeStep({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

const List<_TimeStep> _steps = <_TimeStep>[
  _TimeStep(title: 'Time 1', subtitle: 'First introduction'),
  _TimeStep(title: 'Time 2', subtitle: 'Watch for reactions'),
  _TimeStep(title: 'Time 3', subtitle: 'Full serving, you did it!'),
];

class _StartIntroduceSheet extends ConsumerStatefulWidget {
  const _StartIntroduceSheet({required this.allergen, required this.babyId});

  final Allergen allergen;
  final String babyId;

  @override
  ConsumerState<_StartIntroduceSheet> createState() =>
      _StartIntroduceSheetState();
}

class _StartIntroduceSheetState extends ConsumerState<_StartIntroduceSheet> {
  bool _submitting = false;

  Future<void> _onStart() async {
    setState(() => _submitting = true);
    final result = await ref
        .read(allergenTrackerControllerProvider(widget.babyId).notifier)
        .startIntroduce(widget.allergen.key);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _submitting = false);
    final error = result.errorOrNull;
    final message = error is ValidationException
        ? 'Finish the current allergen before starting another.'
        : (error?.message ?? "Couldn't start introduction. Please try again.");
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.butterSoft, AppColors.background],
          stops: [0, 0.35],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radius3xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSizes.pagePaddingH,
            right: AppSizes.pagePaddingH,
            top: AppSizes.lg,
            bottom: AppSizes.md + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMuted,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              const AllergenIconTile(),
              const SizedBox(height: AppSizes.sm),
              Text(
                widget.allergen.name,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'For the safest approach, introduce only one new allergen per '
                "day and don't forget to log your baby's response after each "
                'exposure.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
              ),
              const SizedBox(height: AppSizes.lg),
              for (var i = 0; i < _steps.length; i++) ...[
                _TimeCard(step: _steps[i], number: i + 1),
                if (i != _steps.length - 1) const SizedBox(height: AppSizes.sm),
              ],
              const SizedBox(height: AppSizes.lg),
              AppPillButton(
                label: 'Start ${widget.allergen.name} for 3 Times',
                identifier: 'start_introduce_confirm_${widget.allergen.key}',
                onPressed: _submitting ? null : _onStart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.step, required this.number});

  final _TimeStep step;
  final int number;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Assets.images.allergen.babyOrange.svg(width: 52, height: 52),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(step.title, style: textTheme.titleSmall),
                const SizedBox(height: AppSizes.sp2),
                Text(
                  step.subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Container(
            width: AppSizes.lg,
            height: AppSizes.lg,
            decoration: const BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.cream,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

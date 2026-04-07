import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/gp_referral_block.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/log_entry_card.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/timing_guidance_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class AllergenDetailScreen extends ConsumerWidget {
  const AllergenDetailScreen({required this.allergenKey, super.key});
  final String allergenKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(allergenDetailControllerProvider(allergenKey));

    return asyncState.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  err is AppException ? err.message : 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
                ),
                const SizedBox(height: AppSizes.lg),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    allergenDetailControllerProvider(allergenKey),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (state) =>
          _AllergenDetailView(state: state, allergenKey: allergenKey),
    );
  }
}

class _AllergenDetailView extends ConsumerWidget {
  const _AllergenDetailView({required this.state, required this.allergenKey});

  final AllergenDetailState state;
  final String allergenKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isCurrent =
        state.programState.currentAllergenKey == state.allergen.key;
    final showProceed =
        state.status == AllergenStatus.safe ||
        state.status == AllergenStatus.flagged;
    final showLogToday = isCurrent && !showProceed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.allergen.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSizes.sm),
            Text(state.allergen.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.pagePaddingV,
              ),
              children: [
                // Day X/3 progress chip — only count clean (no-reaction) logs.
                _DayProgressChip(
                  logCount: state.logs.where((l) => !l.hadReaction).length,
                ),
                const SizedBox(height: AppSizes.lg),

                // Log history
                if (state.logs.isNotEmpty) ...[
                  Text('Your logs', style: textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  ...state.logs.asMap().entries.map(
                    (e) => LogEntryCard(
                      key: ValueKey(e.value.id),
                      log: e.value,
                      dayNumber: e.key + 1,
                      reactionDetail: state.reactionDetails[e.value.id],
                      signedPhotoUrl: state.signedPhotoUrls[e.value.id],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],

                // Timing guidance — always visible
                const TimingGuidanceCard(),
                const SizedBox(height: AppSizes.lg),

                // Reaction history + GP referral
                if (state.status == AllergenStatus.flagged) ...[
                  Text('Reaction history', style: textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  ...state.logs
                      .where((l) => l.hadReaction)
                      .map(
                        (log) => _ReactionSummaryTile(
                          key: ValueKey('reaction_${log.id}'),
                          detail: state.reactionDetails[log.id],
                        ),
                      ),
                  const SizedBox(height: AppSizes.md),
                  const GpReferralBlock(),
                  const SizedBox(height: AppSizes.lg),
                ],

                // Bottom padding so last item isn't hidden by CTA
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),

          // CTA area
          _CtaSection(
            state: state,
            allergenKey: allergenKey,
            showLogToday: showLogToday,
            showProceed: showProceed,
          ),
        ],
      ),
    );
  }
}

class _DayProgressChip extends StatelessWidget {
  const _DayProgressChip({required this.logCount});
  final int logCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = logCount >= 3 ? 'Log 3/3 — Complete' : 'Log $logCount/3';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: logCount >= 3
                ? AppColors.allergenSafe.withAlpha(26)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: logCount >= 3 ? AppColors.allergenSafe : AppColors.divider,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: logCount >= 3 ? AppColors.allergenSafe : AppColors.subtext,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionSummaryTile extends StatelessWidget {
  const _ReactionSummaryTile({required this.detail, super.key});
  final ReactionDetail? detail;

  Color _severityColor(ReactionSeverity severity) => switch (severity) {
    ReactionSeverity.mild => AppColors.warning,
    ReactionSeverity.moderate => AppColors.secondary,
    ReactionSeverity.severe => AppColors.error,
  };

  String _severityLabel(ReactionSeverity severity) => switch (severity) {
    ReactionSeverity.mild => 'Mild',
    ReactionSeverity.moderate => 'Moderate',
    ReactionSeverity.severe => 'Severe',
  };

  @override
  Widget build(BuildContext context) {
    if (detail == null) return const SizedBox.shrink();
    final d = detail!;
    final textTheme = Theme.of(context).textTheme;
    final color = _severityColor(d.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                _severityLabel(d.severity),
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (d.symptoms.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.xs,
                runSpacing: AppSizes.xs,
                children: d.symptoms
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        labelStyle: textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.surfaceVariant,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (d.notes != null && d.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                d.notes!,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.subtext,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtaSection extends ConsumerWidget {
  const _CtaSection({
    required this.state,
    required this.allergenKey,
    required this.showLogToday,
    required this.showProceed,
  });

  final AllergenDetailState state;
  final String allergenKey;
  final bool showLogToday;
  final bool showProceed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        bottomPadding + AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLogToday)
            FilledButton(
              key: const Key('log_today_button'),
              onPressed: () {
                // TODO(NIB-24): open AL-04 log today modal.
                // After modal saves, invalidate:
                // allergenDetailControllerProvider(allergenKey)
                // allergenTrackerControllerProvider
              },
              child: const Text('Log Today'),
            )
          else if (showProceed) ...[
            if (state.status == AllergenStatus.flagged)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'A reaction was recorded for this allergen.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            FilledButton(
              key: const Key('proceed_button'),
              onPressed: () => _handleProceed(context, ref),
              child: const Text('Proceed to Next Allergen'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleProceed(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(allergenDetailControllerProvider(allergenKey).notifier)
        .advanceToNext();

    if (!context.mounted) return;
    result.when(
      success: (nextKey) {
        if (nextKey == null) {
          context.goNamed(AppRoute.allergenComplete.name);
        } else {
          context.goNamed(
            AppRoute.allergenDetail.name,
            pathParameters: {'allergenKey': nextKey},
          );
        }
      },
      failure: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't advance. Please try again.")),
      ),
    );
  }
}

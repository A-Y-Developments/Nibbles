import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class AllergenTrackerScreen extends ConsumerWidget {
  const AllergenTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _TrackerBody(babyId: babyId);
      },
    );
  }
}

class _TrackerBody extends ConsumerWidget {
  const _TrackerBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerAsync = ref.watch(allergenTrackerControllerProvider(babyId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'Allergen Tracker',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.subtext,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'All Allergens'),
            ],
          ),
        ),
        body: trackerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.pagePaddingH),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Could not load tracker.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  FilledButton(
                    onPressed: () => ref.invalidate(
                      allergenTrackerControllerProvider(babyId),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (state) => TabBarView(
            children: [
              _OverviewTab(state: state, babyId: babyId),
              _BoardTab(state: state, babyId: babyId),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AL-01 — Overview Tab
// ---------------------------------------------------------------------------

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.state, required this.babyId});

  final AllergenTrackerState state;
  final String babyId;

  int get _introducedCount => state.boardItems
      .where(
        (b) =>
            b.status == AllergenStatus.safe ||
            b.status == AllergenStatus.flagged,
      )
      .length;

  int get _safeCount =>
      state.boardItems.where((b) => b.status == AllergenStatus.safe).length;

  int get _flaggedCount =>
      state.boardItems.where((b) => b.status == AllergenStatus.flagged).length;

  bool get _hasAnyLogs => state.boardItems.any((b) => b.logs.isNotEmpty);

  int get _currentLogCount {
    final currentKey = state.programState.currentAllergenKey;
    final currentItem = state.boardItems
        .where((b) => b.allergen.key == currentKey)
        .firstOrNull;
    return currentItem?.logs.length ?? 0;
  }

  AllergenBoardItem? get _currentItem {
    final currentKey = state.programState.currentAllergenKey;
    return state.boardItems
        .where((b) => b.allergen.key == currentKey)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress circle
          Center(
            child: _ProgressCircle(introduced: _introducedCount, total: 9),
          ),
          const SizedBox(height: AppSizes.lg),

          // Stat chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                label: 'Safe',
                count: _safeCount,
                color: AppColors.allergenSafe,
              ),
              const SizedBox(width: AppSizes.md),
              _StatChip(
                label: 'Flagged',
                count: _flaggedCount,
                color: AppColors.allergenFlagged,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Today's checklist card
          if (!_hasAnyLogs)
            _EmptyState(currentItem: _currentItem)
          else
            _CurrentAllergenCard(
              currentItem: _currentItem,
              logCount: _currentLogCount,
            ),

          // Recent logs (all exposures)
          if (state.recentLogs.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            Text('Recent Logs', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            ...state.recentLogs.map(
              (entry) => _LogRow(
                entry: entry,
                onTap: () => context.pushNamed(
                  AppRoute.allergenDetail.name,
                  pathParameters: {'allergenKey': entry.allergenKey},
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  const _ProgressCircle({required this.introduced, required this.total});

  final int introduced;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? introduced / total : 0.0;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$introduced/$total',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text('introduced', style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            '$count $label',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.currentItem});

  final AllergenBoardItem? currentItem;

  @override
  Widget build(BuildContext context) {
    final emoji = currentItem?.allergen.emoji ?? '🥜';
    final name = currentItem?.allergen.name ?? 'Peanut';

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Start your allergen journey!',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Begin with $emoji $name.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CurrentAllergenCard extends StatelessWidget {
  const _CurrentAllergenCard({
    required this.currentItem,
    required this.logCount,
  });

  final AllergenBoardItem? currentItem;
  final int logCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emoji = currentItem?.allergen.emoji ?? '';
    final name = currentItem?.allergen.name ?? 'Current Allergen';
    final isComplete = logCount >= 3;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current allergen', style: textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(name, style: textTheme.titleMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.allergenSafe.withValues(alpha: 0.12)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              '$logCount of 3 logged',
              style: textTheme.labelSmall?.copyWith(
                color: isComplete ? AppColors.allergenSafe : AppColors.subtext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry, required this.onTap});

  final RecentLogEntry entry;
  final VoidCallback onTap;

  String get _tasteEmoji => switch (entry.taste) {
    EmojiTaste.love => '😍',
    EmojiTaste.neutral => '😐',
    EmojiTaste.dislike => '😣',
  };

  String get _badgeLabel {
    if (!entry.hadReaction) return 'No Reaction';
    return switch (entry.severity) {
      ReactionSeverity.mild => 'Mild',
      ReactionSeverity.moderate => 'Moderate',
      ReactionSeverity.severe => 'Severe',
      null => 'Reaction',
    };
  }

  Color get _badgeColor {
    if (!entry.hadReaction) return AppColors.allergenSafe;
    return switch (entry.severity) {
      ReactionSeverity.mild => AppColors.warning,
      ReactionSeverity.moderate => AppColors.secondary,
      ReactionSeverity.severe => AppColors.allergenFlagged,
      null => AppColors.subtext,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = entry.logDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.cardPadding,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Text(entry.allergenEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.allergenName, style: textTheme.labelLarge),
                    Row(
                      children: [
                        Text(dateStr, style: textTheme.bodySmall),
                        const SizedBox(width: AppSizes.xs),
                        Text(_tasteEmoji, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  _badgeLabel,
                  style: textTheme.labelSmall?.copyWith(color: _badgeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AL-02 — Board Tab
// ---------------------------------------------------------------------------

class _BoardTab extends ConsumerWidget {
  const _BoardTab({required this.state, required this.babyId});

  final AllergenTrackerState state;
  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentKey = state.programState.currentAllergenKey;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      itemCount: state.boardItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final item = state.boardItems[index];
        final isCurrent = item.allergen.key == currentKey;
        return _AllergenBoardRow(
          item: item,
          isCurrent: isCurrent,
          onTap: () => context.pushNamed(
            AppRoute.allergenDetail.name,
            pathParameters: {'allergenKey': item.allergen.key},
          ),
        );
      },
    );
  }
}

class _AllergenBoardRow extends StatelessWidget {
  const _AllergenBoardRow({
    required this.item,
    required this.isCurrent,
    required this.onTap,
  });

  final AllergenBoardItem item;
  final bool isCurrent;
  final VoidCallback onTap;

  Color get _statusColor {
    return switch (item.status) {
      AllergenStatus.safe => AppColors.allergenSafe,
      AllergenStatus.flagged => AppColors.allergenFlagged,
      AllergenStatus.inProgress => AppColors.allergenInProgress,
      AllergenStatus.notStarted => AppColors.allergenNotStarted,
    };
  }

  String get _statusLabel {
    return switch (item.status) {
      AllergenStatus.safe => 'Safe',
      AllergenStatus.flagged => 'Flagged',
      AllergenStatus.inProgress => 'In Progress',
      AllergenStatus.notStarted => 'Not Started',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isCurrent ? AppColors.primary : AppColors.divider,
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji + name
            Text(item.allergen.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.allergen.name, style: textTheme.labelLarge),
                      if (isCurrent) ...[
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          '→ Current',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  // 3 day-slot dot indicators
                  Row(
                    children: List.generate(3, (i) {
                      final log = i < item.logs.length ? item.logs[i] : null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _DotIndicator(log: log),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                _statusLabel,
                style: textTheme.labelSmall?.copyWith(color: _statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.log});

  final AllergenLog? log;

  @override
  Widget build(BuildContext context) {
    if (log == null) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.allergenNotStarted, width: 1.5),
        ),
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: log!.hadReaction
            ? AppColors.allergenFlagged
            : AppColors.allergenSafe,
      ),
    );
  }
}

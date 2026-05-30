import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_state.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_progress_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/reaction_log_row.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/start_introduce_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/tracker_header.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Redesigned Allergen Tracker board (NIB-79).
///
/// Layout: butter-soft header + segmented control (`Ongoing` | `Big 11`) with
/// a coral progress ring (safeCount / 9) and stat columns above it. The
/// Ongoing tab lists allergens with at least one log (inProgress/safe/flagged)
/// followed by a Reaction Log list. The Big 11 tab is a long-scrolling
/// grouped list of all 9 canonical allergens — Not-Started ones expose a
/// Start Introduce CTA that opens the existing log capture sheet.
class AllergenTrackerScreen extends ConsumerWidget {
  const AllergenTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _TrackerBody(babyId: babyId);
      },
    );
  }
}

class _TrackerBody extends ConsumerStatefulWidget {
  const _TrackerBody({required this.babyId});

  final String babyId;

  @override
  ConsumerState<_TrackerBody> createState() => _TrackerBodyState();
}

class _TrackerBodyState extends ConsumerState<_TrackerBody> {
  // 0 = Ongoing, 1 = Big 11. Held locally — never persisted.
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final trackerAsync = ref.watch(
      allergenTrackerControllerProvider(widget.babyId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: trackerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorState(
            onRetry: () => ref.invalidate(
              allergenTrackerControllerProvider(widget.babyId),
            ),
          ),
          data: (state) => _TrackerContent(
            babyId: widget.babyId,
            state: state,
            segmentIndex: _segmentIndex,
            onSegmentChanged: _onSegmentChanged,
            onStartIntroduce: _startIntroduce,
          ),
        ),
      ),
    );
  }

  void _onSegmentChanged(int index) {
    setState(() => _segmentIndex = index);
    final segment = index == 1 ? 'big_11' : 'ongoing';
    unawaited(
      Analytics.instance.logAllergenSegmentChanged(segment: segment),
    );
  }

  Future<void> _startIntroduce(Allergen allergen) async {
    unawaited(
      Analytics.instance.logAllergenStartIntroduce(allergenKey: allergen.key),
    );
    final logged = await context.pushNamed<bool>(
      AppRoute.allergenLogCreate.name,
      pathParameters: {'allergenKey': allergen.key},
    );

    if ((logged ?? false) && mounted) {
      ref.invalidate(allergenTrackerControllerProvider(widget.babyId));
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pagePaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Could not load tracker.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.md),
          AppPillButton(
            label: 'Retry',
            onPressed: onRetry,
            size: AppPillButtonSize.small,
            expand: false,
          ),
        ],
      ),
    );
  }
}

class _TrackerContent extends ConsumerWidget {
  const _TrackerContent({
    required this.babyId,
    required this.state,
    required this.segmentIndex,
    required this.onSegmentChanged,
    required this.onStartIntroduce,
  });

  final String babyId;
  final AllergenTrackerState state;
  final int segmentIndex;
  final ValueChanged<int> onSegmentChanged;
  final void Function(Allergen allergen) onStartIntroduce;

  int get _safeCount =>
      state.statuses.values.where((s) => s == AllergenStatus.safe).length;

  int get _flaggedCount =>
      state.statuses.values.where((s) => s == AllergenStatus.flagged).length;

  int get _notTriedCount => state.statuses.values
      .where((s) => s == AllergenStatus.notStarted)
      .length;

  bool get _isBig11 => segmentIndex == 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Baby is needed for the Reaction Log row avatar. The currentBabyIdProvider
    // upstream already guarantees a baby exists; we read it again here for the
    // initial. Falls back to a neutral glyph when the read is still in flight.
    final babyAsync = ref.watch(_currentBabyProvider);
    final babyInitial = babyAsync.maybeWhen(
      data: (b) => (b?.name.isNotEmpty ?? false)
          ? b!.name[0].toUpperCase()
          : '?',
      orElse: () => '?',
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TrackerAppBar(onBack: () => context.pop())),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.sm,
              AppSizes.pagePaddingH,
              AppSizes.sp12,
            ),
            child: TrackerHeader(
              safeCount: _safeCount,
              flaggedCount: _flaggedCount,
              notTriedCount: _notTriedCount,
              showNotTried: _isBig11,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
            ),
            child: AppSegmentedControl(
              segments: const ['Ongoing', 'Big 11'],
              selectedIndex: segmentIndex,
              onChanged: onSegmentChanged,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
        if (_isBig11)
          _Big11List(
            allergens: state.allergens,
            statuses: state.statuses,
            logs: state.logs,
            onStartIntroduce: onStartIntroduce,
            onAllergenTap: (a) => _openAllergenDetail(context, a.key),
          )
        else
          _OngoingList(
            babyId: babyId,
            babyInitial: babyInitial,
            allergens: state.allergens,
            statuses: state.statuses,
            logs: state.logs,
            onAllergenTap: (a) => _openAllergenDetail(context, a.key),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
      ],
    );
  }

  void _openAllergenDetail(BuildContext context, String allergenKey) {
    context.pushNamed(
      AppRoute.allergenDetail.name,
      pathParameters: {'allergenKey': allergenKey},
    );
  }
}

/// Local provider used to fetch the Baby for the Reaction Log avatar initial.
/// Scoped here because the tracker is the only consumer that needs the full
/// Baby object (the rest of the screen only needs the id).
final _currentBabyProvider = FutureProvider.autoDispose<Baby?>((ref) async {
  final service = ref.watch(babyProfileServiceProvider);
  return service.getBaby();
});

class _TrackerAppBar extends StatelessWidget {
  const _TrackerAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH - 4,
        AppSizes.sm,
        AppSizes.pagePaddingH - 4,
        0,
      ),
      child: Row(
        children: [
          AppRoundButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
            semanticLabel: 'Back',
          ),
          Expanded(
            child: Text(
              'Allergen Tracker',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.fgStrong,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.roundButton),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ongoing tab — allergens with at least one log + Reaction Log feed.
// ---------------------------------------------------------------------------

class _OngoingList extends StatelessWidget {
  const _OngoingList({
    required this.babyId,
    required this.babyInitial,
    required this.allergens,
    required this.statuses,
    required this.logs,
    required this.onAllergenTap,
  });

  final String babyId;
  final String babyInitial;
  final List<Allergen> allergens;
  final Map<String, AllergenStatus> statuses;
  final List<AllergenLog> logs;
  final void Function(Allergen) onAllergenTap;

  List<Allergen> get _ongoing => allergens
      .where(
        (a) =>
            (statuses[a.key] ?? AllergenStatus.notStarted) !=
            AllergenStatus.notStarted,
      )
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final ongoing = _ongoing;
    final textTheme = Theme.of(context).textTheme;

    if (ongoing.isEmpty && logs.isEmpty) {
      return const SliverToBoxAdapter(child: _OngoingEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      sliver: SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          if (ongoing.isNotEmpty) ...[
            Text('In progress', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            for (final a in ongoing) ...[
              AllergenProgressCard(
                allergen: a,
                status: statuses[a.key] ?? AllergenStatus.notStarted,
                cleanLogCount: logs
                    .where((l) => l.allergenKey == a.key && !l.hadReaction)
                    .length,
                totalLogCount:
                    logs.where((l) => l.allergenKey == a.key).length,
                onTap: () => onAllergenTap(a),
              ),
              const SizedBox(height: AppSizes.sm),
            ],
            const SizedBox(height: AppSizes.sm),
          ],
          if (logs.isNotEmpty) ...[
            Text('Reaction Log', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            for (final entry in _reverseIndexed(logs)) ...[
              Builder(
                builder: (context) => ReactionLogRow(
                  log: entry.log,
                  logIndex: entry.index,
                  babyInitial: babyInitial,
                  onTap: () => context.pushNamed(
                    AppRoute.allergenLogDetail.name,
                    pathParameters: {
                      'allergenKey': entry.log.allergenKey,
                      'logId': entry.log.id,
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ],
        ]),
      ),
    );
  }

  /// Returns logs newest-first while keeping a deterministic 1-based "Log N"
  /// numbering. N is the position in the original (oldest-first) sequence,
  /// so newer logs show higher numbers regardless of display order.
  Iterable<_IndexedLog> _reverseIndexed(List<AllergenLog> sorted) sync* {
    for (var i = sorted.length - 1; i >= 0; i--) {
      yield _IndexedLog(log: sorted[i], index: i + 1);
    }
  }
}

class _IndexedLog {
  const _IndexedLog({required this.log, required this.index});
  final AllergenLog log;
  final int index;
}

class _OngoingEmptyState extends StatelessWidget {
  const _OngoingEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.lg,
      ),
      child: EmptyState(
        title: 'No introductions yet',
        subtitle:
            'Switch to Big 11 to choose an allergen and tap '
            "'Start Introduce' to begin.",
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Big 11 tab — long-scrolling grouped list of all 9 canonical allergens.
// ---------------------------------------------------------------------------

class _Big11List extends StatelessWidget {
  const _Big11List({
    required this.allergens,
    required this.statuses,
    required this.logs,
    required this.onStartIntroduce,
    required this.onAllergenTap,
  });

  final List<Allergen> allergens;
  final Map<String, AllergenStatus> statuses;
  final List<AllergenLog> logs;
  final void Function(Allergen) onStartIntroduce;
  final void Function(Allergen) onAllergenTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final allergen = allergens[index];
            final status =
                statuses[allergen.key] ?? AllergenStatus.notStarted;
            final card = status == AllergenStatus.notStarted
                ? StartIntroduceCard(
                    allergen: allergen,
                    onStartIntroduce: () => onStartIntroduce(allergen),
                  )
                : AllergenProgressCard(
                    allergen: allergen,
                    status: status,
                    cleanLogCount: logs
                        .where(
                          (l) =>
                              l.allergenKey == allergen.key && !l.hadReaction,
                        )
                        .length,
                    totalLogCount: logs
                        .where((l) => l.allergenKey == allergen.key)
                        .length,
                    onTap: () => onAllergenTap(allergen),
                  );

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: card,
            );
          },
          childCount: allergens.length,
        ),
      ),
    );
  }
}

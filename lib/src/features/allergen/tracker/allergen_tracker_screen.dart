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
/// Figma frames 1089:17373 (Ongoing tab) / 1116:18287 (Big 11 tab):
///  - Butter→grey gradient background (Grad-1)
///  - "Allergen Trackers" title (verbatim — plural)
///  - Coral progress ring (introduced / 9) + horizontal stat columns
///  - Segmented control "Ongoing " | "Big 11" (no nav transition)
///  - Ongoing tab → "Allergen Exposure" section (See All → Big 11)
///                 + "Reaction Log" feed of recent rows
///  - Big 11 tab → grouped sections "Already Tried" / "Ongoing" / "Not Tried"
class AllergenTrackerScreen extends ConsumerWidget {
  const AllergenTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const GradientScaffold(
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const GradientScaffold(
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

    return GradientScaffold(
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
            onSeeAll: () => _onSegmentChanged(1),
            onStartIntroduce: _startIntroduce,
          ),
        ),
      ),
    );
  }

  void _onSegmentChanged(int index) {
    if (index == _segmentIndex) return;
    setState(() => _segmentIndex = index);
    final segment = index == 1 ? 'big_11' : 'ongoing';
    unawaited(Analytics.instance.logAllergenSegmentChanged(segment: segment));
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
    required this.onSeeAll,
    required this.onStartIntroduce,
  });

  final String babyId;
  final AllergenTrackerState state;
  final int segmentIndex;
  final ValueChanged<int> onSegmentChanged;
  final VoidCallback onSeeAll;
  final void Function(Allergen allergen) onStartIntroduce;

  int get _safeCount =>
      state.statuses.values.where((s) => s == AllergenStatus.safe).length;

  int get _flaggedCount =>
      state.statuses.values.where((s) => s == AllergenStatus.flagged).length;

  int get _notTriedCount =>
      state.statuses.values.where((s) => s == AllergenStatus.notStarted).length;

  /// "Introduced" = anything past `notStarted`. Drives the ring numerator.
  int get _introducedCount =>
      state.statuses.values.where((s) => s != AllergenStatus.notStarted).length;

  bool get _isBig11 => segmentIndex == 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Baby is needed for the Reaction Log row avatar. The currentBabyIdProvider
    // upstream already guarantees a baby exists; we read it again here for the
    // initial. Falls back to a neutral glyph when the read is still in flight.
    final babyAsync = ref.watch(_currentBabyProvider);
    final babyInitial = babyAsync.maybeWhen(
      data: (b) =>
          (b?.name.isNotEmpty ?? false) ? b!.name[0].toUpperCase() : '?',
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
              AppSizes.md,
            ),
            child: TrackerHeader(
              introducedCount: _introducedCount,
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
            // Verbatim: "Ongoing " preserves the trailing space.
            child: AppSegmentedControl(
              segments: const ['Ongoing ', 'Big 11'],
              selectedIndex: segmentIndex,
              onChanged: onSegmentChanged,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
        if (_isBig11)
          _Big11Sections(
            allergens: state.allergens,
            statuses: state.statuses,
            logs: state.logs,
            onStartIntroduce: onStartIntroduce,
            onAllergenTap: (a) =>
                unawaited(_openAllergenDetail(context, ref, a.key)),
          )
        else
          _OngoingList(
            babyId: babyId,
            babyInitial: babyInitial,
            allergens: state.allergens,
            statuses: state.statuses,
            logs: state.logs,
            onAllergenTap: (a) =>
                unawaited(_openAllergenDetail(context, ref, a.key)),
            onSeeAll: onSeeAll,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
      ],
    );
  }

  Future<void> _openAllergenDetail(
    BuildContext context,
    WidgetRef ref,
    String allergenKey,
  ) async {
    await context.pushNamed(
      AppRoute.allergenDetail.name,
      pathParameters: {'allergenKey': allergenKey},
    );
    // Adding a log inside the detail screen changes this allergen's derived
    // status; detail invalidates only its own provider, so refresh the tracker
    // on return to avoid showing a stale per-allergen status.
    if (context.mounted) {
      ref.invalidate(allergenTrackerControllerProvider(babyId));
    }
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
            tone: AppRoundButtonTone.ghost,
            semanticLabel: 'Back',
          ),
          Expanded(
            child: Text(
              // Verbatim Figma copy: plural "Trackers".
              'Allergen Trackers',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.fgStrong),
            ),
          ),
          const SizedBox(width: AppSizes.roundButton),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(color: AppColors.fgStrong),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'See All',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Text(
          'See All',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.fgFaint),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ongoing tab — "Allergen Exposure" + Reaction Log feed.
// ---------------------------------------------------------------------------

class _OngoingList extends StatelessWidget {
  const _OngoingList({
    required this.babyId,
    required this.babyInitial,
    required this.allergens,
    required this.statuses,
    required this.logs,
    required this.onAllergenTap,
    required this.onSeeAll,
  });

  final String babyId;
  final String babyInitial;
  final List<Allergen> allergens;
  final Map<String, AllergenStatus> statuses;
  final List<AllergenLog> logs;
  final void Function(Allergen) onAllergenTap;
  final VoidCallback onSeeAll;

  List<Allergen> get _exposed => allergens
      .where(
        (a) =>
            (statuses[a.key] ?? AllergenStatus.notStarted) !=
            AllergenStatus.notStarted,
      )
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final exposed = _exposed;

    // Section scaffolding ALWAYS renders (Figma 1089:17373). Empty data
    // is shown as a per-section placeholder INSIDE the section, never as a
    // full-screen flower illustration.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      sliver: SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          _SectionHeader(
            title: 'Allergen Exposure',
            trailing: _SeeAllLink(onPressed: onSeeAll),
          ),
          if (exposed.isEmpty)
            const _SectionPlaceholder(text: 'No exposures yet')
          else
            for (final a in exposed) ...[
              AllergenProgressCard(
                allergen: a,
                status: statuses[a.key] ?? AllergenStatus.notStarted,
                cleanLogCount: logs
                    .where((l) => l.allergenKey == a.key && !l.hadReaction)
                    .length,
                totalLogCount: logs.where((l) => l.allergenKey == a.key).length,
                onTap: () => onAllergenTap(a),
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          const SizedBox(height: AppSizes.md),
          const _SectionHeader(title: 'Reaction Log'),
          if (logs.isEmpty)
            const _SectionPlaceholder(text: 'No reactions logged yet')
          else
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

/// Lightweight per-section empty placeholder. Sits inside a section card slot
/// without the full-screen Quatrefoil mark — section scaffolding (header)
/// stays visible above it. Matches Figma's section-level empty treatment.
class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.fgFaint),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Big 11 tab — 3 labelled sections (Already Tried / Ongoing / Not Tried).
// ---------------------------------------------------------------------------

class _Big11Sections extends StatelessWidget {
  const _Big11Sections({
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

  /// "Already Tried" = safe or flagged (introduction concluded one way or
  /// another). Matches Figma 1116:18287 which groups completed-Safe under
  /// this header (no separate "Flagged" group; flagged still surfaces a
  /// Flagged chip on the card).
  List<Allergen> get _alreadyTried => allergens
      .where((a) {
        final s = statuses[a.key] ?? AllergenStatus.notStarted;
        return s == AllergenStatus.safe || s == AllergenStatus.flagged;
      })
      .toList(growable: false);

  List<Allergen> get _ongoing => allergens
      .where(
        (a) =>
            (statuses[a.key] ?? AllergenStatus.notStarted) ==
            AllergenStatus.inProgress,
      )
      .toList(growable: false);

  List<Allergen> get _notTried => allergens
      .where(
        (a) =>
            (statuses[a.key] ?? AllergenStatus.notStarted) ==
            AllergenStatus.notStarted,
      )
      .toList(growable: false);

  AllergenProgressCard _progressCard(Allergen allergen) {
    final status = statuses[allergen.key] ?? AllergenStatus.notStarted;
    return AllergenProgressCard(
      allergen: allergen,
      status: status,
      cleanLogCount: logs
          .where((l) => l.allergenKey == allergen.key && !l.hadReaction)
          .length,
      totalLogCount: logs.where((l) => l.allergenKey == allergen.key).length,
      onTap: () => onAllergenTap(allergen),
    );
  }

  StartIntroduceCard _notTriedCard(Allergen allergen) {
    return StartIntroduceCard(
      allergen: allergen,
      onStartIntroduce: () => onStartIntroduce(allergen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tried = _alreadyTried;
    final ongoing = _ongoing;
    final notTried = _notTried;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      sliver: SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          if (tried.isNotEmpty) ...[
            const _SectionHeader(title: 'Already Tried'),
            for (final a in tried) ...[
              _progressCard(a),
              const SizedBox(height: AppSizes.sm),
            ],
            const SizedBox(height: AppSizes.sm),
          ],
          if (ongoing.isNotEmpty) ...[
            const _SectionHeader(title: 'Ongoing'),
            for (final a in ongoing) ...[
              _progressCard(a),
              const SizedBox(height: AppSizes.sm),
            ],
            const SizedBox(height: AppSizes.sm),
          ],
          if (notTried.isNotEmpty) ...[
            const _SectionHeader(title: 'Not Tried'),
            for (final a in notTried) ...[
              _notTriedCard(a),
              const SizedBox(height: AppSizes.sm),
            ],
          ],
        ]),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_contextual_banner.dart';
import 'package:nibbles/src/features/allergen/log/reaction_log_sheet.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_state.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_exposure_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_progress_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/confetti_celebration.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/reaction_log_row.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/start_introduce_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/start_introduce_sheet.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/tracker_header.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Redesigned Allergen Tracker board (NIB-79).
///
/// Ongoing tab (Figma 1089:17373): burgundy "Allergen Exposure" hero for the
/// currently-ongoing allergen + a Reaction Log feed of its logs.
/// Big 11 tab (Figma 2780:13178): grouped "Already Tried" / "Ongoing" /
/// "Not Tried" sections; "Not Tried" opens the pre-introduce sheet.
class AllergenTrackerScreen extends ConsumerWidget {
  const AllergenTrackerScreen({this.initialSegmentIndex = 0, super.key});

  /// 0 = Ongoing, 1 = Big 11. Set via the `?tab=big11` query param so a
  /// "Start New Allergen" CTA can land straight on the Big 11 picker.
  final int initialSegmentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        body: Center(child: BrandFlowerLoader.small()),
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
        return _TrackerBody(
          babyId: babyId,
          initialSegmentIndex: initialSegmentIndex,
        );
      },
    );
  }
}

class _TrackerBody extends ConsumerStatefulWidget {
  const _TrackerBody({required this.babyId, this.initialSegmentIndex = 0});

  final int initialSegmentIndex;

  final String babyId;

  @override
  ConsumerState<_TrackerBody> createState() => _TrackerBodyState();
}

class _TrackerBodyState extends ConsumerState<_TrackerBody> {
  // 0 = Ongoing, 1 = Big 11. Seeded from the route, then held locally.
  late int _segmentIndex = widget.initialSegmentIndex;

  @override
  Widget build(BuildContext context) {
    final trackerAsync = ref.watch(
      allergenTrackerControllerProvider(widget.babyId),
    );

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: AppDurations.fade,
          switchInCurve: AppCurves.standard,
          switchOutCurve: AppCurves.standard,
          child: trackerAsync.when(
            loading: () => const Center(
              key: ValueKey('loading'),
              child: BrandFlowerLoader.small(),
            ),
            error: (err, _) => _ErrorState(
              key: const ValueKey('error'),
              onRetry: () => ref.invalidate(
                allergenTrackerControllerProvider(widget.babyId),
              ),
            ),
            data: (state) => _TrackerContent(
              key: const ValueKey('data'),
              babyId: widget.babyId,
              state: state,
              segmentIndex: _segmentIndex,
              onSegmentChanged: _onSegmentChanged,
              onStartIntroduce: _startIntroduce,
              onAddReaction: _addReaction,
              onStartNew: _startNew,
            ),
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

  /// "Start New Allergen" — jump to the Big 11 tab to pick the next allergen.
  void _startNew() => _onSegmentChanged(1);

  Future<void> _addReaction(String allergenKey) async {
    final saved = await showReactionLogSheet(context, allergenKey: allergenKey);
    if (!mounted || !(saved ?? false)) return;
    ref.invalidate(allergenTrackerControllerProvider(widget.babyId));
  }

  Future<void> _startIntroduce(Allergen allergen) async {
    final started = await showStartIntroduceSheet(
      context,
      allergen: allergen,
      babyId: widget.babyId,
    );
    if (!mounted || !started) return;

    unawaited(
      Analytics.instance.logAllergenStartIntroduce(allergenKey: allergen.key),
    );
    setState(() => _segmentIndex = 0);
    ref.invalidate(allergenTrackerControllerProvider(widget.babyId));
    await showConfettiCelebration(context);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, super.key});

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
    required this.onAddReaction,
    required this.onStartNew,
    super.key,
  });

  final String babyId;
  final AllergenTrackerState state;
  final int segmentIndex;
  final ValueChanged<int> onSegmentChanged;
  final void Function(Allergen allergen) onStartIntroduce;
  final void Function(String allergenKey) onAddReaction;
  final VoidCallback onStartNew;

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
    return BrandRefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allergenTrackerControllerProvider(babyId));
        await ref.read(allergenTrackerControllerProvider(babyId).future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _TrackerAppBar(onBack: () => context.pop()),
          ),
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
              child: AppSlidingSegmentedControl(
                segments: const ['Ongoing', 'Big 11'],
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
              allergens: state.allergens,
              statuses: state.statuses,
              logs: state.logs,
              selectedAllergenKey: state.selectedAllergenKey,
              onAllergenTap: (a) =>
                  unawaited(_openAllergenDetail(context, ref, a.key)),
              onAddReaction: onAddReaction,
              onStartNew: onStartNew,
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
        ],
      ),
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
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.fgStrong,
            ),
            tooltip: 'Back',
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

class _AddReactionButton extends StatelessWidget {
  const _AddReactionButton({required this.onPressed, this.enabled = true});

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Add reaction log',
        child: Material(
          color: AppColors.greenDeep,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: AppSizes.roundButton,
              height: AppSizes.roundButton,
              child: Icon(
                Icons.add_rounded,
                size: AppSizes.iconMd,
                color: AppColors.cream,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ongoing tab — burgundy "Allergen Exposure" hero + Reaction Log feed.
// ---------------------------------------------------------------------------

class _OngoingList extends StatelessWidget {
  const _OngoingList({
    required this.allergens,
    required this.statuses,
    required this.logs,
    required this.selectedAllergenKey,
    required this.onAllergenTap,
    required this.onAddReaction,
    required this.onStartNew,
  });

  final List<Allergen> allergens;
  final Map<String, AllergenStatus> statuses;
  final List<AllergenLog> logs;
  final String? selectedAllergenKey;
  final void Function(Allergen) onAllergenTap;
  final void Function(String allergenKey) onAddReaction;
  final VoidCallback onStartNew;

  /// The allergen shown in the "Allergen Exposure" hero + Reaction Log feed.
  ///
  /// Priority:
  ///  1. the actively-selected ("Start Introduce") allergen — which persists
  ///     here even after it flags / goes safe, until a new one is started;
  ///  2. an allergen currently `inProgress` from its logs (1–2 clean);
  ///  3. the most-recently logged allergen — so logging an unsafe reaction
  ///     never clears the feed; it stays until a new introduction replaces it.
  Allergen? get _displayAllergen {
    Allergen? byKey(String? key) {
      if (key == null) return null;
      for (final a in allergens) {
        if (a.key == key) return a;
      }
      return null;
    }

    final selected = byKey(selectedAllergenKey);
    if (selected != null) return selected;

    for (final a in allergens) {
      if ((statuses[a.key] ?? AllergenStatus.notStarted) ==
          AllergenStatus.inProgress) {
        return a;
      }
    }

    if (logs.isNotEmpty) return byKey(logs.last.allergenKey);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ongoing = _displayAllergen;
    final ongoingLogs = ongoing == null
        ? const <AllergenLog>[]
        : (logs.where((l) => l.allergenKey == ongoing.key).toList()
            ..sort((a, b) {
              final byDate = a.logDate.compareTo(b.logDate);
              return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
            }));

    final status = ongoing == null
        ? AllergenStatus.notStarted
        : statuses[ongoing.key] ?? AllergenStatus.notStarted;
    final finished =
        status == AllergenStatus.safe || status == AllergenStatus.flagged;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      sliver: SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          const _SectionHeader(title: 'Allergen Exposure'),
          if (ongoing == null)
            const _SectionPlaceholder(
              text: 'No allergen is being introduced right now.',
            )
          else ...[
            AllergenExposureCard(
                  allergen: ongoing,
                  reactionFlags: ongoingLogs
                      .map((l) => l.hadReaction)
                      .toList(growable: false),
                  heroTag: 'allergen-icon-${ongoing.key}',
                  onTap: () => onAllergenTap(ongoing),
                )
                .animate()
                .fadeIn(duration: AppDurations.fade)
                .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: AppDurations.slide,
                  curve: AppCurves.emphasized,
                ),
            const SizedBox(height: AppSizes.sm),
            DetailContextualBanner(status: status, allergenName: ongoing.name),
          ],
          const SizedBox(height: AppSizes.md),
          _SectionHeader(
            title: 'Reaction Log',
            trailing: ongoing == null
                ? null
                : _AddReactionButton(
                    enabled: !finished,
                    onPressed: () => onAddReaction(ongoing.key),
                  ),
          ),
          if (ongoingLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: AppSizes.xl),
              child: EmptyState(
                title: 'No reactions logged yet',
                subtitle: 'Tap + to log your first introduction.',
              ),
            )
          else
            for (final (position, entry) in _reverseIndexed(
              ongoingLogs,
            ).indexed) ...[
              _staggeredEntrance(
                Builder(
                  builder: (context) => ReactionLogRow(
                    log: entry.log,
                    logIndex: entry.index,
                    onTap: () => context.pushNamed(
                      AppRoute.allergenLogDetail.name,
                      pathParameters: {
                        'allergenKey': entry.log.allergenKey,
                        'logId': entry.log.id,
                      },
                    ),
                  ),
                ),
                position,
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          if (finished) ...[
            const SizedBox(height: AppSizes.md),
            StartAllergenButton(onPressed: onStartNew),
          ],
        ]),
      ),
    );
  }

  /// Newest-first with a stable 1-based "Log N" numbering (N = position in the
  /// original oldest-first sequence).
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

/// Per-section empty placeholder — header stays visible above it.
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

Widget _staggeredEntrance(Widget child, int position) {
  final delay = (position * 40).ms;
  return child
      .animate()
      .fadeIn(delay: delay, duration: AppDurations.fade)
      .slideY(
        begin: 0.06,
        end: 0,
        delay: delay,
        duration: AppDurations.slide,
        curve: AppCurves.emphasized,
      );
}

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

  static const int _total = 11;

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
      totalLogCount: logs.where((l) => l.allergenKey == allergen.key).length,
      onTap: () => onAllergenTap(allergen),
    );
  }

  StartIntroduceCard _notTriedCard(Allergen allergen, {required bool enabled}) {
    // notStarted allergens have no detail to show — only the "Start Introduce"
    // CTA acts. The card body is intentionally not tappable (no onTap).
    return StartIntroduceCard(
      allergen: allergen,
      enabled: enabled,
      onStartIntroduce: () => onStartIntroduce(allergen),
    );
  }

  /// Single-active rule: while any allergen is in progress, no new
  /// introduction can start until that one becomes Safe or Flagged.
  bool get _introductionLocked =>
      statuses.values.any((s) => s == AllergenStatus.inProgress);

  @override
  Widget build(BuildContext context) {
    final tried = _alreadyTried;
    final ongoing = _ongoing;
    final notTried = _notTried;
    final canStart = !_introductionLocked;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      sliver: SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          if (tried.isNotEmpty) ...[
            _Big11SectionHeader(
              title: 'Already Tried',
              count: tried.length,
              total: _total,
              dotColor: AppColors.greenDeep,
            ),
            for (final (i, a) in tried.indexed) ...[
              _staggeredEntrance(_progressCard(a), i),
              const SizedBox(height: AppSizes.sm),
            ],
            const SizedBox(height: AppSizes.sm),
          ],
          if (ongoing.isNotEmpty) ...[
            _Big11SectionHeader(
              title: 'Ongoing',
              count: ongoing.length,
              total: _total,
              dotColor: AppColors.coral,
            ),
            for (final (i, a) in ongoing.indexed) ...[
              _staggeredEntrance(_progressCard(a), i),
              const SizedBox(height: AppSizes.sm),
            ],
            const SizedBox(height: AppSizes.sm),
          ],
          if (notTried.isNotEmpty) ...[
            _Big11SectionHeader(
              title: 'Not Tried',
              count: notTried.length,
              total: _total,
              dotColor: AppColors.borderMuted,
            ),
            for (final (i, a) in notTried.indexed) ...[
              _staggeredEntrance(_notTriedCard(a, enabled: canStart), i),
              const SizedBox(height: AppSizes.sm),
            ],
          ],
        ]),
      ),
    );
  }
}

class _Big11SectionHeader extends StatelessWidget {
  const _Big11SectionHeader({
    required this.title,
    required this.count,
    required this.total,
    required this.dotColor,
  });

  final String title;
  final int count;
  final int total;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(color: AppColors.fgStrong),
            ),
          ),
          Text(
            '$count/$total',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.fgFaint),
          ),
        ],
      ),
    );
  }
}

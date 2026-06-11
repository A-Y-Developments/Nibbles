import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_contextual_banner.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_dates_block.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_header_card.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_segment_bar.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/log_entry_card.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/reaction_log_header.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class AllergenDetailScreen extends ConsumerWidget {
  const AllergenDetailScreen({required this.allergenKey, super.key});

  final String allergenKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(allergenDetailControllerProvider(allergenKey));

    return asyncState.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
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
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.fgMuted),
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

  int get _cleanCount =>
      state.logs.where((AllergenLog l) => !l.hadReaction).length;

  String get _babyInitial => state.babyName.isEmpty
      ? '?'
      : state.babyName.characters.first.toUpperCase();

  Future<void> _onAddPressed(BuildContext context, WidgetRef ref) async {
    final saved = await context.pushNamed<bool>(
      AppRoute.allergenLogCreate.name,
      pathParameters: {'allergenKey': state.allergen.key},
    );
    if (saved ?? false) {
      ref.invalidate(allergenDetailControllerProvider(allergenKey));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLogs = state.logs.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(state.allergen.name),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.pagePaddingV,
        ),
        children: [
          DetailHeaderCard(
            emoji: state.allergen.emoji,
            name: state.allergen.name,
            cleanCount: _cleanCount,
            status: state.status,
          ),

          if (hasLogs) ...[
            const SizedBox(height: AppSizes.lg),
            DetailDatesBlock(
              firstIntroduced: state.firstIntroduced!,
              lastGiven: state.lastGiven!,
            ),
          ],

          const SizedBox(height: AppSizes.lg),
          DetailSegmentBar(cleanCount: _cleanCount, status: state.status),

          const SizedBox(height: AppSizes.lg),
          DetailContextualBanner(
            status: state.status,
            allergenName: state.allergen.name,
          ),

          const SizedBox(height: AppSizes.lg),
          ReactionLogHeader(onAddPressed: () => _onAddPressed(context, ref)),
          const SizedBox(height: AppSizes.sm),

          if (hasLogs)
            ...state.logs.asMap().entries.map(
              (e) => LogEntryCard(
                key: ValueKey(e.value.id),
                log: e.value,
                logNumber: e.key + 1,
                babyInitial: _babyInitial,
                onTap: () => context.pushNamed(
                  AppRoute.allergenLogDetail.name,
                  pathParameters: {
                    'allergenKey': allergenKey,
                    'logId': e.value.id,
                  },
                ),
              ),
            )
          else
            const _EmptyLogsHint(),

          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}

class _EmptyLogsHint extends StatelessWidget {
  const _EmptyLogsHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Text(
        'No logs yet. Tap + to log the first introduction.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.fgFaint),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_contextual_banner.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_header_card.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/log_entry_card.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/reaction_log_header.dart';
import 'package:nibbles/src/features/allergen/log/reaction_log_sheet.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class AllergenDetailScreen extends ConsumerWidget {
  const AllergenDetailScreen({required this.allergenKey, super.key});

  final String allergenKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(allergenDetailControllerProvider(allergenKey));

    return asyncState.when(
      loading: () => GradientScaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => GradientScaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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

  int get _cleanLogCount => state.logs.where((l) => !l.hadReaction).length;

  Future<void> _onAddPressed(BuildContext context, WidgetRef ref) async {
    final saved = await showReactionLogSheet(
      context,
      allergenKey: state.allergen.key,
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
      body: Column(
        children: [
          AllergenDetailHeader(
            name: state.allergen.name,
            status: state.status,
            cleanLogCount: _cleanLogCount,
            firstIntroduced: state.firstIntroduced,
            lastGiven: state.lastGiven,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Stack(
              children: [
                const _BodyBackdrop(),
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePaddingH,
                    AppSizes.lg,
                    AppSizes.pagePaddingH,
                    AppSizes.xxl,
                  ),
                  children: [
                    ReactionLogHeader(
                      onAddPressed: () => _onAddPressed(context, ref),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    if (hasLogs)
                      ...state.logs.asMap().entries.map(
                        (e) => LogEntryCard(
                          key: ValueKey(e.value.id),
                          log: e.value,
                          logNumber: e.key + 1,
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
                    const SizedBox(height: AppSizes.lg),
                    DetailContextualBanner(
                      status: state.status,
                      allergenName: state.allergen.name,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft cream blob decoration behind the detail body — same organic shape as
/// the Home hero background, recoloured to a pale butter tone over the cream
/// body. Non-interactive (taps pass through to the list).
class _BodyBackdrop extends StatelessWidget {
  const _BodyBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(top: -40, right: -60, child: _blob(220)),
              Positioned(top: 150, left: -70, child: _blob(170)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double size) => Opacity(
    opacity: 0.6,
    child: ColorFiltered(
      colorFilter: const ColorFilter.mode(
        AppColors.butterSoft,
        BlendMode.srcIn,
      ),
      child: Assets.images.allergen.allergenBlob.image(
        width: size,
        fit: BoxFit.contain,
      ),
    ),
  );
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_controller.dart';
import 'package:nibbles/src/features/starting_guide/widgets/article_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_back_button.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Starting Guide hub — the content index reachable from the Recipe Library
/// 'Read Guide' banner and bookmark button (NIB-53 wires both).
///
/// Renders a butter-wash header + a vertical list of [ArticleCard]s, one per
/// entry in [kStartingGuideArticles]. Tapping a card pushes the article
/// screen routed by slug.
class StartingGuideHubScreen extends ConsumerStatefulWidget {
  const StartingGuideHubScreen({super.key});

  @override
  ConsumerState<StartingGuideHubScreen> createState() =>
      _StartingGuideHubScreenState();
}

class _StartingGuideHubScreenState
    extends ConsumerState<StartingGuideHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // TODO(NIB-53): pass `source` via GoRouter `extra` so we can distinguish
      // hub vs article entry points instead of always firing 'unknown'.
      unawaited(Analytics.instance.logStartingGuideOpened(source: 'unknown'));
      unawaited(
        Analytics.instance.logScreenView(screenName: 'starting_guide_hub'),
      );
    });
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.recipeLibrary.name);
    }
  }

  void _openArticle(String slug) {
    context.pushNamed(
      AppRoute.startingGuideArticle.name,
      pathParameters: {'slug': slug},
    );
  }

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(startingGuideControllerProvider);

    final header = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            GuideBackButton(onTap: _onBack),
            const SizedBox(width: AppSizes.xs),
            Expanded(
              child: Text(
                'Starting Guide',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.fgStrong,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return GradientScaffold(
      body: guideAsync.when(
        loading: () => Column(
          children: [
            header,
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (_, __) => Column(
          children: [
            header,
            Expanded(
              child: Center(
                child: EmptyState(
                  title: "Couldn't load the Starting Guide.",
                  subtitle: 'Pull down or tap retry to try again.',
                  ctaLabel: 'Retry',
                  onCtaPressed: () =>
                      ref.invalidate(startingGuideControllerProvider),
                ),
              ),
            ),
          ],
        ),
        data: (state) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: header),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.xl,
              ),
              sliver: SliverList.separated(
                itemCount: state.articles.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.md),
                itemBuilder: (context, index) {
                  final article = state.articles[index];
                  return ArticleCard(
                    article: article,
                    onTap: () => _openArticle(article.slug),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

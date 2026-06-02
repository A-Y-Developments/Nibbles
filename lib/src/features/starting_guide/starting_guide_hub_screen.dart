import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/feedback/empty_state.dart';
import 'package:nibbles/src/common/components/navigation/app_header.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
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
///
/// First-launch dismiss (build rule 9): on mount, marks the Starting Guide
/// as seen via [LocalFlagService.markStartingGuideSeen] so the library
/// banner stops showing on subsequent visits.
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
      unawaited(ref.read(localFlagServiceProvider).markStartingGuideSeen());
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
      child: AppHeader(
        title: 'Starting Guide',
        leading: GuideBackButton(onTap: _onBack),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          // Grad-1 (matches profile_screen): CSS
          // linear-gradient(152.612deg, #FFFCD5 19.168%, #F5F5F5 50%).
          gradient: LinearGradient(
            begin: Alignment(-0.460, -0.888),
            end: Alignment(0.460, 0.888),
            stops: [0.19168, 0.5],
            colors: [AppColors.butterSoft, Color(0xFFF5F5F5)],
          ),
        ),
        child: guideAsync.when(
          loading: () => Column(
            children: [
              header,
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
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
                  AppSizes.pagePaddingH,
                  AppSizes.md,
                  AppSizes.pagePaddingH,
                  AppSizes.xl,
                ),
                sliver: SliverList.separated(
                  itemCount: state.articles.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.sp12),
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
      ),
    );
  }
}

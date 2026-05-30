import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_controller.dart';
import 'package:nibbles/src/features/starting_guide/widgets/article_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_back_button.dart';
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

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: guideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Text(
              "Couldn't load the Starting Guide.",
              style: AppTypography.emptyStateTitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (state) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(onBack: _onBack)),
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
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.butter, AppColors.butterSoft],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        AppSizes.lg,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GuideBackButton(onTap: onBack),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: Text(
                    'Starting Guide',
                    style: AppTypography.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Bite-sized reads to help you start solids with confidence.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

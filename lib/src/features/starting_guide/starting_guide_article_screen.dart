import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_controller.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_back_button.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_cta_pill.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_hero_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/numbered_step.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Single Starting Guide article screen.
///
/// Resolves the article by [slug] via [StartingGuideController]. Renders the
/// hero card, the article's numbered sections, and a single terminal CTA at
/// the bottom that routes to one of the existing top-level routes
/// (`recipe-library`, `meal-plan`, `allergen-tracker`, etc.).
///
/// If the slug doesn't match any article we fall back to a tiny not-found
/// scaffold rather than crashing — protects against a malformed deeplink.
class StartingGuideArticleScreen extends ConsumerWidget {
  const StartingGuideArticleScreen({required this.slug, super.key});

  final String slug;

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.startingGuide.name);
    }
  }

  void _onCta(BuildContext context, GuideCta cta) {
    // 'Get Free Weekly Baby Recipes' has no destination flow yet — see the
    // placeholder note in `constants/articles.dart`. The article routes back
    // to the hub (placeholder targets `AppRoute.startingGuide.name`); doing
    // the same for unknown route names keeps us crash-safe if the list is
    // extended with a target that isn't registered yet.
    final isKnown = AppRoute.values.any((r) => r.name == cta.routeName);
    if (!isKnown || cta.routeName == AppRoute.startingGuide.name) {
      _onBack(context);
      return;
    }
    context.goNamed(cta.routeName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideAsync = ref.watch(startingGuideControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: guideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _NotFound(onBack: () => _onBack(context)),
        data: (state) {
          GuideArticle? article;
          for (final a in state.articles) {
            if (a.slug == slug) {
              article = a;
              break;
            }
          }
          if (article == null) {
            return _NotFound(onBack: () => _onBack(context));
          }
          return _ArticleBody(
            article: article,
            onBack: () => _onBack(context),
            onCta: (cta) => _onCta(context, cta),
          );
        },
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({
    required this.article,
    required this.onBack,
    required this.onCta,
  });

  final GuideArticle article;
  final VoidCallback onBack;
  final ValueChanged<GuideCta> onCta;

  @override
  Widget build(BuildContext context) {
    final cta = article.terminalCta;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(onBack: onBack)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.md,
            AppSizes.pagePaddingH,
            AppSizes.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: GuideHeroCard(
              title: article.title,
              subtitle: article.subtitle,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            0,
            AppSizes.pagePaddingH,
            AppSizes.lg,
          ),
          sliver: SliverList.separated(
            itemCount: article.sections.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.lg),
            itemBuilder: (context, index) {
              final section = article.sections[index];
              return NumberedStep(
                stepNumber: section.stepNumber,
                heading: section.heading,
                body: section.body,
              );
            },
          ),
        ),
        if (cta != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.sm,
              AppSizes.pagePaddingH,
              AppSizes.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: GuideCtaPill(
                label: cta.label,
                onTap: () => onCta(cta),
              ),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
      ],
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
        AppSizes.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
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
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideBackButton(onTap: onBack),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Article not found',
              style: AppTypography.emptyStateTitle,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              "We couldn't find that guide article.",
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

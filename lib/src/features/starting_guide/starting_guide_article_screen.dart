import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/components/navigation/app_header.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_controller.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_checklist_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_chip_grid_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_hero_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_icon_tile_grid.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_info_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_numbered_list_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_philosophy_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_ready_to_start_card.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_section_heading.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Single Starting Guide article screen.
///
/// Resolves the article by [slug] via [StartingGuideController] and renders
/// its [GuideBlock] sequence. Each block is mapped to the matching guide
/// widget via the sealed-class switch in [_buildBlock].
///
/// If the slug doesn't match any article we fall back to a tiny not-found
/// scaffold rather than crashing — protects against a malformed deeplink.
class StartingGuideArticleScreen extends ConsumerStatefulWidget {
  const StartingGuideArticleScreen({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<StartingGuideArticleScreen> createState() =>
      _StartingGuideArticleScreenState();
}

class _StartingGuideArticleScreenState
    extends ConsumerState<StartingGuideArticleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Analytics.instance.logStartingGuideArticleViewed(slug: widget.slug),
      );
      unawaited(
        Analytics.instance.logScreenView(screenName: 'starting_guide_article'),
      );
    });
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.startingGuide.name);
    }
  }

  void _onCta(BuildContext context, GuideCta cta) {
    // 'Get Free Weekly Baby Recipes' currently has no destination flow (NIB-94
    // pending). Until it lands, that CTA's `routeName` is `starting-guide` —
    // routing to it just pops the article so the user stays in context.
    // Defensive guard for any unknown future route names: do the same thing
    // instead of crashing.
    final isKnown = AppRoute.values.any((r) => r.name == cta.routeName);
    if (!isKnown || cta.routeName == AppRoute.startingGuide.name) {
      _onBack(context);
      return;
    }
    context.goNamed(cta.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(startingGuideControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: guideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _NotFound(onBack: () => _onBack(context)),
        data: (state) {
          GuideArticle? article;
          for (final a in state.articles) {
            if (a.slug == widget.slug) {
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: AppHeader(
              title: article.title,
              wash: AppHeaderWash.cream,
              leading: AppRoundButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tone: AppRoundButtonTone.ghost,
                size: AppRoundButtonSize.small,
                semanticLabel: 'Back',
                onPressed: onBack,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.md,
            AppSizes.pagePaddingH,
            AppSizes.xl,
          ),
          sliver: SliverList.separated(
            itemCount: article.blocks.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.lg),
            itemBuilder: (context, index) =>
                _buildBlock(article.blocks[index], onCta),
          ),
        ),
      ],
    );
  }
}

Widget _buildBlock(GuideBlock block, ValueChanged<GuideCta> onCta) {
  switch (block) {
    case HeroCardBlock():
      return GuideHeroCard(title: block.title, subtitle: block.body);
    case SectionHeadingBlock():
      return GuideSectionHeading(block.text);
    case ParagraphBlock():
      return Text(
        block.text,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.fgDefault,
        ),
      );
    case LabelChipBlock():
      return Align(
        alignment: Alignment.centerLeft,
        child: AppChip(label: block.label),
      );
    case InfoCardBlock():
      return GuideInfoCard(title: block.title, body: block.body);
    case IconTileGridBlock():
      return GuideIconTileGrid(labels: block.labels);
    case ChipGridCardBlock():
      return GuideChipGridCard(
        title: block.title,
        body: block.body,
        chips: block.chips,
      );
    case NumberedListCardBlock():
      return GuideNumberedListCard(
        title: block.title,
        body: block.body,
        items: block.items,
      );
    case PhilosophyCardBlock():
      return GuidePhilosophyCard(
        title: block.title,
        body: block.body,
        chips: block.chips,
      );
    case ReadyToStartCardBlock():
      return GuideReadyToStartCard(
        title: block.title,
        body: block.body,
        ctaLabel: block.cta.label,
        onCta: () => onCta(block.cta),
      );
    case InlineCtaPairBlock():
      return _InlineCtaPair(
        primary: block.primary,
        secondary: block.secondary,
        onCta: onCta,
      );
    case ChecklistCardBlock():
      return GuideChecklistCard(
        title: block.title,
        score: block.score,
        items: block.items,
      );
  }
}

class _InlineCtaPair extends StatelessWidget {
  const _InlineCtaPair({
    required this.primary,
    required this.secondary,
    required this.onCta,
  });

  final GuideCta primary;
  final GuideCta? secondary;
  final ValueChanged<GuideCta> onCta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPillButton(
          label: primary.label,
          onPressed: () => onCta(primary),
        ),
        if (secondary != null) ...[
          const SizedBox(height: AppSizes.sp12),
          AppPillButton(
            label: secondary!.label,
            variant: AppPillButtonVariant.ghost,
            onPressed: () => onCta(secondary!),
          ),
        ],
      ],
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
            AppRoundButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tone: AppRoundButtonTone.ghost,
              size: AppRoundButtonSize.small,
              semanticLabel: 'Back',
              onPressed: onBack,
            ),
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

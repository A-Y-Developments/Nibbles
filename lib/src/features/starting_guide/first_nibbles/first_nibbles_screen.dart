import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_section_heading.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Baby's First Nibbles — the lead Starting Guide page (Figma 971:8730).
///
/// Bespoke, fully static marketing page. Unlike the other guide articles it
/// is not driven by the generic block renderer, so it carries no controller
/// or AsyncNotifier — there is no async data to load.
class FirstNibblesScreen extends ConsumerStatefulWidget {
  const FirstNibblesScreen({super.key});

  @override
  ConsumerState<FirstNibblesScreen> createState() => _FirstNibblesScreenState();
}

class _FirstNibblesScreenState extends ConsumerState<FirstNibblesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Analytics.instance.logStartingGuideArticleViewed(slug: 'first-nibbles'),
      );
      unawaited(
        Analytics.instance.logScreenView(screenName: 'starting_guide_article'),
      );
    });
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.startingGuide.name);
    }
  }

  void _onExplore() => context.goNamed(AppRoute.recipeLibrary.name);

  // 'Get Free Weekly Baby Recipes' has no destination flow yet (NIB-94). Until
  // it lands, the CTA keeps the user in context by returning to the guide.
  void _onWeeklyRecipes() => _onBack();

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Assets.images.guide.blobHero.svg(width: 178),
          ),
          Column(
            children: [
              _Header(onBack: _onBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePaddingH,
                    AppSizes.md,
                    AppSizes.pagePaddingH,
                    AppSizes.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Assets.images.guide.firstNibblesCover.image(
                          height: 258,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        'What would I have wanted in my hands when I started '
                        'this journey?',
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          color: AppColors.greenDeep,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const _Quote(
                        'Baby’s First Nibbles is designed to be simple, '
                        'practical, evidence-informed, and realistic for busy '
                        'parents.',
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const GuideSectionHeading('We focuses on'),
                      const SizedBox(height: AppSizes.md),
                      const _FocusCard(
                        horizontal: true,
                        title: 'SIMPLE AND PRACTICAL',
                        body:
                            'Designed for busy parents with realistic '
                            'recipes and actionable steps.',
                      ),
                      const SizedBox(height: AppSizes.sp12),
                      const IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _FocusCard(
                                title: 'EVIDENCE INFORMED',
                                body:
                                    'Based on current pediatric nutrition '
                                    'guidelines.',
                              ),
                            ),
                            SizedBox(width: AppSizes.sp12),
                            Expanded(
                              child: _FocusCard(
                                title: 'No Fluf',
                                body:
                                    'No overcomplication. Just food that '
                                    'makes sense for you.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const GuideSectionHeading('Nibbles Goals'),
                      const SizedBox(height: AppSizes.md),
                      _GoalsCard(
                        onExplore: _onExplore,
                        onWeeklyRecipes: _onWeeklyRecipes,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            AppRoundButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tone: AppRoundButtonTone.ghost,
              size: AppRoundButtonSize.small,
              semanticLabel: 'Back',
              onPressed: onBack,
            ),
            const SizedBox(width: AppSizes.xs),
            Expanded(
              child: Text(
                'BABY’S FIRST NIBBLES',
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
  }
}

class _Quote extends StatelessWidget {
  const _Quote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3, color: AppColors.green),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.fgMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.title,
    required this.body,
    this.horizontal = false,
  });

  final String title;
  final String body;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final glyph = Assets.images.guide.babyGlyph.svg(width: 44, height: 43);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headline.copyWith(color: AppColors.fgStrong),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          body,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSizes.sp12),
      ),
      child: horizontal
          ? Row(
              children: [
                glyph,
                const SizedBox(width: AppSizes.sp12),
                Expanded(child: text),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                glyph,
                const SizedBox(height: AppSizes.sp12),
                text,
              ],
            ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.onExplore, required this.onWeeklyRecipes});

  final VoidCallback onExplore;
  final VoidCallback onWeeklyRecipes;

  static const List<String> _goals = [
    'Help parents feel confident, not overwhelmed',
    'To help your baby explore food',
    'Develop feeding skills',
    'Build a strong foundation for lifelong health',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.sp12),
      child: ColoredBox(
        color: AppColors.cardCream,
        child: Stack(
          children: [
            Positioned(
              top: -24,
              right: -12,
              child: Assets.images.guide.blobGoals.svg(width: 145),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sp12,
                vertical: AppSizes.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _goals.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSizes.sp12),
                    _GoalRow(number: i + 1, text: _goals[i]),
                  ],
                  const SizedBox(height: AppSizes.lg),
                  AppPillButton(label: 'Explore Recipes', onPressed: onExplore),
                  const SizedBox(height: AppSizes.sp12),
                  AppPillButton(
                    label: 'Get Free Weekly Baby Recipes',
                    variant: AppPillButtonVariant.ghost,
                    onPressed: onWeeklyRecipes,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$number',
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(color: AppColors.green),
          ),
        ),
        const SizedBox(width: AppSizes.sp12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Important Feeding Principles — bespoke Starting Guide article
/// (Figma 1474:50514).
///
/// Like FirstNibblesScreen and the Introduction view, this page bypasses the
/// generic block renderer: its layout (hero banner, iron-rich tile grid,
/// salmon-ghost allergen chips, burgundy "Items to Avoid" card, numbered
/// badges) is too specific to express through shared GuideBlocks. Fully
/// static, so no controller.
class FeedingPrinciplesScreen extends ConsumerStatefulWidget {
  const FeedingPrinciplesScreen({super.key});

  @override
  ConsumerState<FeedingPrinciplesScreen> createState() =>
      _FeedingPrinciplesScreenState();
}

class _FeedingPrinciplesScreenState
    extends ConsumerState<FeedingPrinciplesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Analytics.instance.logStartingGuideArticleViewed(
          slug: 'feeding-principles',
        ),
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

  void _onStartAllergens() => context.goNamed(AppRoute.allergenTracker.name);

  static const List<String> _ironFoods = [
    'Beef',
    'Lamb',
    'Chicken',
    'Fish',
    'Eggs',
    'Lentils',
    'Tofu',
  ];

  static const List<String> _allergens = [
    'Almond',
    'Cashew',
    'Egg',
    'Wheat',
    'Fish',
    'Peanut',
    'Milk',
    'Prawn',
    'Wallnut',
    'Soy',
    'Sesame',
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
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
                  const _HeroBanner(),
                  const SizedBox(height: AppSizes.lg),
                  const _IronRichSection(foods: _ironFoods),
                  const SizedBox(height: AppSizes.lg),
                  const _CommonAllergenSection(allergens: _allergens),
                  const SizedBox(height: AppSizes.lg),
                  const _VarietySection(),
                  const SizedBox(height: AppSizes.lg),
                  const _ItemsToAvoidCard(),
                  const SizedBox(height: AppSizes.lg),
                  _ReadyToStartCard(onStart: _onStartAllergens),
                ],
              ),
            ),
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
                'Feeding Principles',
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

/// Hero card — the supplied banner PNG already bakes in the title, subtitle,
/// wash, decorative blob and the meatball-plate photo, so it renders as one
/// full-width image. [Semantics] restores the (baked-in) text to screen
/// readers since the pixels carry no accessible label of their own.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          'Important Feeding Principles. Weaning is more than just calories; '
          "it's a foundation for lifelong health.",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.sp12),
        child: Assets.images.guide.feedingPrinciplesBanner.image(
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class _IronRichSection extends StatelessWidget {
  const _IronRichSection({required this.foods});

  final List<String> foods;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionHeading('Iron-Rich Essentials'),
            _GuidePill('6+ Months'),
          ],
        ),
        const SizedBox(height: AppSizes.sp12),
        Text(
          'Baby’s iron needs increase significantly at 6 months. Example '
          'iron-rich foods :',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
        const SizedBox(height: AppSizes.sp12),
        Wrap(
          spacing: AppSizes.sp12,
          runSpacing: AppSizes.sp12,
          alignment: WrapAlignment.center,
          children: [for (final food in foods) _IronTile(label: food)],
        ),
      ],
    );
  }
}

class _IronTile extends StatelessWidget {
  const _IronTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Assets.images.guide.ironFoodGlyph.svg(width: 44, height: 43),
          const SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommonAllergenSection extends StatelessWidget {
  const _CommonAllergenSection({required this.allergens});

  final List<String> allergens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Common Allergen'),
        const SizedBox(height: AppSizes.sp12),
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.sp12),
            child: ColoredBox(
              color: AppColors.cream,
              child: Stack(
                children: [
                  Positioned(
                    top: -66,
                    right: -42,
                    child: Assets.images.guide.feedingPrinciplesBlob.svg(
                      width: 156,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.sp12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Assets.images.guide.bulbBadge.svg(
                          width: 38,
                          height: 37,
                        ),
                        const SizedBox(height: AppSizes.sp12),
                        Text(
                          'The Big 11',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.fgStrong,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sp12),
                        Text(
                          'Introduce early and often within the first year.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.fgStrong,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sp12),
                        Wrap(
                          spacing: AppSizes.xs,
                          runSpacing: AppSizes.xs,
                          children: [
                            for (final allergen in allergens)
                              _GuidePill(allergen),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VarietySection extends StatelessWidget {
  const _VarietySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Offering a Variety of Foods'),
        const SizedBox(height: AppSizes.sp12),
        Text(
          'Repeated exposure to a wide range of foods can help babies develop '
          'acceptance of different flavours and textures. It is normal for '
          'babies to need several exposures to a new food before accepting it.',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
      ],
    );
  }
}

class _ItemsToAvoidCard extends StatelessWidget {
  const _ItemsToAvoidCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardBurgundy,
        borderRadius: BorderRadius.circular(AppSizes.sp12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items to Avoid',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          const _AvoidItem(
            number: 1,
            heading: 'No Added Salt or Sugar',
            body:
                'Foods prepared for infants should not contain added salt or '
                'sugar. Babies’s kidneys are still developing, and limiting '
                'salt intake is recommended.',
          ),
          const SizedBox(height: AppSizes.sp12),
          const _AvoidItem(
            number: 2,
            heading: 'Avoid Honey Before 12 Months',
            body:
                'Honey should not be given to infants under 12 months of age '
                'due to the risk of infant botulism.',
          ),
        ],
      ),
    );
  }
}

class _AvoidItem extends StatelessWidget {
  const _AvoidItem({
    required this.number,
    required this.heading,
    required this.body,
  });

  final int number;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Assets.images.guide.numberBadge.svg(width: 26, height: 26),
              Text(
                '$number',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.coralSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: AppTypography.headline.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                body,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadyToStartCard extends StatelessWidget {
  const _ReadyToStartCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Start Introduce Allergens?',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          Text(
            'Introduce allergens with confidence using simple guidance and '
            'easy tracking.',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          AppPillButton(
            label: 'Start Introducing Allergens',
            expand: false,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

/// Bold 17px Parkinsans section title (Figma Title 3/Bold). Local rather than
/// shared GuideSectionHeading (20px) because this screen's headings are 17px.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.fgStrong,
      ),
    );
  }
}

/// Salmon-ghost label chip (Figma `Label`): coral-soft fill, coral-deep
/// Parkinsans SemiBold 13. Larger than AppChip, so bespoke.
class _GuidePill extends StatelessWidget {
  const _GuidePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: AppColors.coralDeep,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/routing/route_enums.dart';

const double _cardRadius = AppSizes.radiusFull;

/// Skill-card decorative quatrefoil — natural render size of the cropped
/// `blob_hero.svg` window, nudged off the top-right corner so only the inner
/// curve peeks in (Figma 1474:49921 sits the 266px blob mostly outside).
const double _skillBlobSize = 150;

/// Yellow baby icon dimensions (Figma Group 79 — 44×43).
const double _babyIconW = 44;
const double _babyIconH = 43;

/// Current baby, used only for the Ready-to-Start greeting. A missing baby is
/// not an error — the card falls back to generic copy.
final _introBabyProvider = FutureProvider.autoDispose<Baby?>((ref) async {
  return ref.watch(babyProfileServiceProvider).getBaby();
});

/// Bespoke Introduction article (Figma 971:8744). Rendered in place of the
/// generic block renderer for the `introduction` slug. Wrapped by the caller's
/// [GradientScaffold]; this widget owns the header + scrolling body only.
class IntroductionView extends ConsumerWidget {
  const IntroductionView({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyName = ref.watch(_introBabyProvider).valueOrNull?.name;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(onBack: onBack)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeroBanner(),
                const SizedBox(height: AppSizes.lg),
                const _MilestoneSection(),
                const SizedBox(height: AppSizes.lg),
                const _NutrientsSection(),
                const SizedBox(height: AppSizes.lg),
                _SkillBuildingCard(
                  onExplore: () => context.goNamed(AppRoute.recipeLibrary.name),
                  onWeeklyRecipes: onBack,
                ),
                const SizedBox(height: AppSizes.lg),
                const _PhilosophyCard(),
                const SizedBox(height: AppSizes.lg),
                _ReadyToStartCard(
                  babyName: babyName,
                  onCreateFirstMeal: () =>
                      context.goNamed(AppRoute.mealPlan.name),
                ),
              ],
            ),
          ),
        ),
      ],
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
                'Introduction',
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardRadius),
      child: Assets.images.guide.introSolidsBanner.image(
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

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

class _MilestoneSection extends StatelessWidget {
  const _MilestoneSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('The 6 Month Milestone'),
        const SizedBox(height: AppSizes.sp12),
        Text(
          'Babies begin transitioning from an exclusively milk-based diet to '
          'a combination of breast milk or formula and complementary foods.',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
        const SizedBox(height: AppSizes.sp12),
        Text(
          'Perfect time to growth!',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _NutrientsSection extends StatelessWidget {
  const _NutrientsSection();

  static const _labels = ['Iron', 'Minerals', 'Vitamins', 'Zinc'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Essential Nutrients'),
        const SizedBox(height: AppSizes.sp12),
        Row(
          children: [
            for (var i = 0; i < _labels.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.sp12),
              Expanded(child: _NutrientTile(label: _labels[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _NutrientTile extends StatelessWidget {
  const _NutrientTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Assets.images.guide.nutrientBabyIcon.svg(
          width: _babyIconW,
          height: _babyIconH,
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
      ],
    );
  }
}

class _SkillBuildingCard extends StatelessWidget {
  const _SkillBuildingCard({
    required this.onExplore,
    required this.onWeeklyRecipes,
  });

  final VoidCallback onExplore;
  final VoidCallback onWeeklyRecipes;

  static const _steps = [
    (
      heading: 'Developing Coordination',
      body: 'Hand-to-mouth movements and tongue control.',
    ),
    (
      heading: 'Exploring Textures',
      body: 'Learning to manipulate different mouthfeels.',
    ),
    (
      heading: 'Learning to Eat',
      body: 'Transitioning from sucking to chewing and swallowing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardRadius),
      child: ColoredBox(
        color: AppColors.bgCardTint,
        child: Stack(
          children: [
            Positioned(
              top: -AppSizes.lg,
              right: -AppSizes.lg,
              child: Assets.images.guide.blobHero.svg(
                width: _skillBlobSize,
                height: _skillBlobSize,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'Feeding is Skill-Building',
                      style: AppTypography.headline,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Beyond nutrients, every meal is a sensory workout for '
                    'your little one.',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.fgStrong,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  for (var i = 0; i < _steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSizes.sp12),
                    _SkillStep(
                      number: i + 1,
                      heading: _steps[i].heading,
                      body: _steps[i].body,
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  AppPillButton(label: 'Explore Recipes', onPressed: onExplore),
                  const SizedBox(height: AppSizes.sp12),
                  _LimePillButton(
                    label: 'Get Free Weekly Baby Recipes',
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

class _SkillStep extends StatelessWidget {
  const _SkillStep({
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
          width: AppSizes.lg,
          child: Text(
            '$number',
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(color: AppColors.green),
          ),
        ),
        const SizedBox(width: AppSizes.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(heading, style: AppTypography.headline),
              const SizedBox(height: AppSizes.xs),
              Text(
                body,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lime CTA pill ("Get Free Weekly Baby Recipes"). [AppPillButton] has no lime
/// variant, so this mirrors its shape/metrics with a lime fill + forest label.
class _LimePillButton extends StatelessWidget {
  const _LimePillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.lime,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: AppSizes.buttonHeight,
            width: double.infinity,
            child: Center(
              child: Text(
                label,
                style: AppTypography.button.copyWith(
                  color: AppColors.greenDeep,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhilosophyCard extends StatelessWidget {
  const _PhilosophyCard();

  static const _chips = ['Nurturing', 'Evidence-based', 'Simple'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sp12,
        vertical: AppSizes.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.images.guide.babyGlyph.svg(
            width: _babyIconW,
            height: _babyIconH,
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Philosophy',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Simple, nutrient-dense meals that support both nutrition '
                  'and development, without overcomplicating the process.',
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.xs,
                  runSpacing: AppSizes.xs,
                  children: [for (final chip in _chips) AppChip(label: chip)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyToStartCard extends StatelessWidget {
  const _ReadyToStartCard({
    required this.babyName,
    required this.onCreateFirstMeal,
  });

  final String? babyName;
  final VoidCallback onCreateFirstMeal;

  @override
  Widget build(BuildContext context) {
    final name = babyName?.trim();
    final lead = (name != null && name.isNotEmpty)
        ? "Begin $name's"
        : "Begin your baby's";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xl,
      ),
      child: Column(
        children: [
          Text(
            'Ready to Start?',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          Text(
            '$lead food journey by creating your first meal prep and '
            'introducing allergens safely.',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          AppPillButton(
            label: 'Create First Meal',
            onPressed: onCreateFirstMeal,
            expand: false,
          ),
        ],
      ),
    );
  }
}

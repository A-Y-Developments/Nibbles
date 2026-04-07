import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [_OB01Welcome(), _OB02ValueProp()],
              ),
            ),
            _BottomSection(
              currentPage: _currentPage,
              onGetStarted: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              onNext: () => context.goNamed(AppRoute.onboardingReadiness.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _OB01Welcome extends StatelessWidget {
  const _OB01Welcome();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: AppColors.onPrimary,
              size: AppSizes.iconXl,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            'Nibbles',
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'Your guide to introducing solids — safely, '
            'confidently, one bite at a time.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
          ),
        ],
      ),
    );
  }
}

class _OB02ValueProp extends StatelessWidget {
  const _OB02ValueProp();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you need to get started',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          const _FeatureRow(
            icon: Icons.track_changes_rounded,
            title: 'Allergen tracking',
            subtitle: 'Introduce the top 9 allergens safely with guided steps.',
          ),
          const SizedBox(height: AppSizes.lg),
          const _FeatureRow(
            icon: Icons.calendar_month_rounded,
            title: 'Meal planning',
            subtitle: "Plan weekly meals tailored to your baby's progress.",
          ),
          const SizedBox(height: AppSizes.lg),
          const _FeatureRow(
            icon: Icons.menu_book_rounded,
            title: 'Recipe library',
            subtitle: 'Age-appropriate recipes your whole family will love.',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: AppColors.subtext),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.currentPage,
    required this.onGetStarted,
    required this.onNext,
  });

  final int currentPage;
  final VoidCallback onGetStarted;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: currentPage == 0 ? onGetStarted : onNext,
              child: Text(currentPage == 0 ? 'Get Started' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

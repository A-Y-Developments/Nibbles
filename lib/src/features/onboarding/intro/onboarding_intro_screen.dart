import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Intro carousel — 3 butter-gradient slides with device-mockup illustrations.
///
/// Per NIB-60: butter-soft -> cream gradient bg, title2 heading, body sub,
/// AppPillButton sage primary CTA, AppRoundButton butter back. Inline dot
/// indicator (sage greenDeep widened pill on active). Last slide advances to
/// /onboarding/name (route hoisted by NIB-51).
class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen> {
  static const _slides = <_IntroSlideData>[
    _IntroSlideData(
      title: 'Meal Prep Guidance',
      subtitle:
          'Step-by-step guidance to plan, prep, and serve baby-safe meals '
          'with confidence.',
    ),
    _IntroSlideData(
      title: 'Grocery Shopping',
      subtitle:
          'Auto-generated shopping lists from your meal plan, organized by '
          'aisle so nothing gets missed.',
    ),
    _IntroSlideData(
      title: 'Recipes & Meal Planning',
      subtitle:
          'A library of age-appropriate recipes, ready to drop into a weekly '
          'plan tailored to your baby.',
    ),
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _currentPage == _slides.length - 1;

  void _onPrimaryPressed() {
    if (_isLast) {
      context.goNamed(AppRoute.onboardingName.name);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _onBackPressed() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.butterSoft, AppColors.cream],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                showBack: _currentPage > 0,
                onBack: _onBackPressed,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) => _IntroSlide(
                    data: _slides[index],
                    slideIndex: index,
                  ),
                ),
              ),
              _BottomSection(
                currentPage: _currentPage,
                slideCount: _slides.length,
                primaryLabel: _isLast ? "Let's Go" : 'Continue',
                onPrimary: _onPrimaryPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroSlideData {
  const _IntroSlideData({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showBack, required this.onBack});

  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        0,
      ),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: showBack ? 1 : 0,
            child: IgnorePointer(
              ignoring: !showBack,
              child: AppRoundButton(
                icon: const Icon(Icons.arrow_back),
                tone: AppRoundButtonTone.butter,
                onPressed: onBack,
                semanticLabel: 'Back',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.data, required this.slideIndex});

  final _IntroSlideData data;
  final int slideIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _DeviceMockupPlaceholder(slideIndex: slideIndex),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.greenDeep,
            ),
          ),
          const SizedBox(height: AppSizes.sp12),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.fgDefault,
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

/// Styled placeholder for the device-frame illustration.
// TODO(NIB-60): replace with device-frame illustration from Figma export
class _DeviceMockupPlaceholder extends StatelessWidget {
  const _DeviceMockupPlaceholder({required this.slideIndex});

  final int slideIndex;

  static const _accents = <Color>[
    AppColors.coralSoft,
    AppColors.greenTint,
    AppColors.butter,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Device-frame mockup proportions ~ iPhone 9:19.5.
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final widthFromHeight = maxHeight * 9 / 19.5;
        final width = widthFromHeight.clamp(0.0, maxWidth * 0.72);
        final height = width * 19.5 / 9;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(AppSizes.radius2xl),
            border: Border.all(
              color: AppColors.greenDeep.withAlpha(38),
              width: 1.5,
            ),
            boxShadow: AppSizes.shadowCardLifted,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _accents[slideIndex % _accents.length],
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Center(
                child: Text(
                  'Preview',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.greenDeep,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.currentPage,
    required this.slideCount,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final int currentPage;
  final int slideCount;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.pagePaddingV,
      ),
      child: Column(
        children: [
          _DotIndicator(
            count: slideCount,
            currentIndex: currentPage,
          ),
          const SizedBox(height: AppSizes.lg),
          AppPillButton(
            label: primaryLabel,
            onPressed: onPrimary,
          ),
        ],
      ),
    );
  }
}

/// Inline animated dot indicator. Active dot widens into a sage pill.
/// Spec forbids extracting this into a shared widget.
class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          width: active ? AppSizes.sp20 : AppSizes.sm,
          height: AppSizes.sm,
          decoration: BoxDecoration(
            color: active ? AppColors.greenDeep : AppColors.borderMuted,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
        );
      }),
    );
  }
}

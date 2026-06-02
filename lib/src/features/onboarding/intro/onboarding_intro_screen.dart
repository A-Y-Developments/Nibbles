import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/common/components/controls/app_checkbox.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Pre-auth value-prop carousel — 3 device-mockup slides per NIB-60.
///
/// Layout per Figma frames 971:10019 / 1242:10897 / 1242:11124:
///   - shared eyebrow "We'll Help You with" + per-slide Parkinsans bold title
///   - per-slide phone-mockup illustration (flattened PNGs exported from Figma)
///   - per-slide Figtree body copy (verbatim from spec; slide-3 duplicates
///     slide-2 body per audit — PO open question, do not paraphrase)
///   - bottom row: lime round back-arrow + forestDarkn "Let's Go" pill,
///     always visible (back is no-op on slide 1).
///
/// Behavior:
///   - PageView of 3 slides; auto-advance every 10s while no user interaction
///   - dot indicator (active = greenDeep / forestDarkn widened pill) stays
///     in sync with the live page index
///   - "Let's Go" on slides 1/2 advances PageView; on slide 3 it flips
///     app_has_launched and pushes /auth/login
class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen> {
  // Verbatim copy from .figma-audit/onboarding/{meal-prep-guidance,
  // grocery-shopping,recipes-meal-planning}/report.md. Straight apostrophes
  // intentional (ticket explicit). Slide-3 body duplicates slide-2 — flagged
  // as PO open question on NIB-60.
  static const _slides = <_IntroSlideData>[
    _IntroSlideData(
      title: 'Meal Prep Guidance',
      body: "We'll help you plan, prepare, and stay consistent with "
          'smarter daily meal choices.',
    ),
    _IntroSlideData(
      title: 'Grocery Shopping',
      body: "We'll help you organize your grocery shopping based on your "
          'meal plan, preferences, and daily needs.',
    ),
    _IntroSlideData(
      title: 'Recipes & Meal Planning',
      body: "We'll help you organize your grocery shopping based on your "
          'meal plan, preferences, and daily needs.',
    ),
  ];

  static const Duration _autoAdvanceInterval = Duration(seconds: 10);
  static const Duration _pageAnimDuration = Duration(milliseconds: 280);

  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _scheduleAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _currentPage == _slides.length - 1;

  void _scheduleAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    // Last slide does not auto-advance — never auto-navigate into auth.
    if (_isLast) return;
    _autoAdvanceTimer = Timer(_autoAdvanceInterval, _advanceFromTimer);
  }

  void _advanceFromTimer() {
    if (!mounted || _isLast) return;
    _pageController.nextPage(
      duration: _pageAnimDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _scheduleAutoAdvance();
  }

  Future<void> _onPrimaryPressed() async {
    _autoAdvanceTimer?.cancel();
    if (_isLast) {
      // Ensure GoRouter redirect step 1 doesn't bounce us back to intro.
      ref.read(localFlagServiceProvider).setHasLaunched();
      if (!mounted) return;
      context.goNamed(AppRoute.login.name);
      return;
    }
    await _pageController.nextPage(
      duration: _pageAnimDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onBackPressed() {
    if (_currentPage == 0) return;
    _autoAdvanceTimer?.cancel();
    _pageController.previousPage(
      duration: _pageAnimDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          // Grad-1 ≈ butter-soft -> cream top->bottom per design_context.md.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.butterSoft, AppColors.cream],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    // Pause auto-advance while the user is dragging.
                    if (n is ScrollStartNotification) {
                      _autoAdvanceTimer?.cancel();
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) => _IntroSlide(
                      data: _slides[index],
                      slideIndex: index,
                    ),
                  ),
                ),
              ),
              _BottomSection(
                currentPage: _currentPage,
                slideCount: _slides.length,
                onPrimary: _onPrimaryPressed,
                onBack: _onBackPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroSlideData {
  const _IntroSlideData({required this.title, required this.body});

  final String title;
  final String body;
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.data, required this.slideIndex});

  final _IntroSlideData data;
  final int slideIndex;

  static const _eyebrow = "We'll Help You with";

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Title 1/Bold per variables.json — Parkinsans 22/34 (height 1.5454…).
    final titleStyle = textTheme.titleLarge?.copyWith(
      color: AppColors.text,
      height: 34 / 22,
    );
    // Body/Regular per variables.json — Figtree 15/22 (height 1.4666…).
    final bodyStyle = textTheme.bodyLarge?.copyWith(
      color: AppColors.text,
      height: 22 / 15,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.lg,
      ),
      child: Column(
        children: [
          // Headline block — eyebrow + per-slide title, centered, top of slide.
          Text(
            _eyebrow,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          if (slideIndex == 1) ...[
            const SizedBox(height: AppSizes.xl),
            const _AppleShoplistRow(),
          ],
          Expanded(
            child: _SlideIllustration(slideIndex: slideIndex),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
            ),
            child: Text(
              data.body,
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

/// Slide-2 animated shoplist demo row — checkbox + "Apple" + cancel chip on
/// `#fffeea`. Spec source: grocery-shopping/report.md "Shoplist-animation".
class _AppleShoplistRow extends StatelessWidget {
  const _AppleShoplistRow();

  // Spec literal — `bg #fffeea` per audit. No matching token in app_colors.
  static const Color _bg = Color(0xFFFFFEEA);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: const Key('onboarding_intro_apple_row'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          AppCheckbox(value: false, onChanged: (_) {}),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Text(
              'Apple',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
            ),
          ),
          const Icon(
            Icons.cancel,
            color: AppColors.destructive,
            size: AppSizes.iconMd,
          ),
        ],
      ),
    );
  }
}

/// Per-slide phone-mockup illustration. Flattened transparent PNGs exported
/// from Figma (file ASB9HZLodbzJCo5bjkqjy6):
///   - slide 0 (Meal Prep): phone with the floating TODAY MEALS / ALLERGEN
///     stats card composited over it (Figma 971:10019)
///   - slides 1 & 2 (Grocery / Recipes): shared Shopping List mockup — slide 2
///     reuses slide 1's frame per Figma (duplicate body flagged on NIB-60)
///
/// Each PNG has a baked bottom alpha-fade; rendered top-aligned and clipped so
/// the phone dissolves into the background gradient like the Figma frames.
class _SlideIllustration extends StatelessWidget {
  const _SlideIllustration({required this.slideIndex});

  final int slideIndex;

  AssetGenImage get _asset => switch (slideIndex) {
    0 => Assets.images.onboarding.introMealPrep,
    _ => Assets.images.onboarding.introShoppingList,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: double.infinity,
            child: _asset.image(
              width: constraints.maxWidth * 0.92,
              fit: BoxFit.fitWidth,
              excludeFromSemantics: true,
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
    required this.onPrimary,
    required this.onBack,
  });

  final int currentPage;
  final int slideCount;
  final VoidCallback onPrimary;
  final VoidCallback onBack;

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
          Semantics(
            container: true,
            liveRegion: true,
            label: 'Page ${currentPage + 1} of $slideCount',
            excludeSemantics: true,
            child: _DotIndicator(
              count: slideCount,
              currentIndex: currentPage,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              AppRoundButton(
                key: const Key('onboarding_intro_back'),
                icon: const Icon(Icons.arrow_back),
                tone: AppRoundButtonTone.butter,
                // Disable on slide 1 — no previous slide.
                onPressed: currentPage == 0 ? null : onBack,
                semanticLabel: 'Back',
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: AppPillButton(
                  key: const Key('onboarding_intro_primary'),
                  label: "Let's Go",
                  onPressed: onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Inline animated dot indicator. Active dot widens into a forestDarkn pill.
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
          key: Key('onboarding_intro_dot_$i'),
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

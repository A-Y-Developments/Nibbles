import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen>
    with SingleTickerProviderStateMixin {
  static final _slides = <_SlideData>[
    _SlideData(
      title: 'Meal Prep Guidance',
      body:
          "We'll help you plan, prepare, and stay consistent with "
          'smarter daily meal choices.',
      image: Assets.images.onboarding.introMealPrep,
      popup: Assets.images.onboarding.introMealPrepOverlay,
      popupAlignment: const Alignment(0, -0.18),
      popupWidthFactor: 0.9,
    ),
    _SlideData(
      title: 'Grocery Shopping',
      body:
          "We'll help you organize your grocery shopping based on your "
          'meal plan, preferences, and daily needs.',
      image: Assets.images.onboarding.introShoppingList,
      popup: Assets.images.onboarding.introShoppingListOverlay,
      popupAlignment: const Alignment(0, -0.05),
      popupWidthFactor: 0.89,
    ),
    _SlideData(
      title: 'Recipes & Meal Planning',
      body:
          "We'll help you organize your grocery shopping based on your "
          'meal plan, preferences, and daily needs.',
      image: Assets.images.onboarding.introShoppingList,
    ),
  ];

  static const Duration _autoAdvanceInterval = Duration(seconds: 5);
  static const Duration _switchDuration = Duration(milliseconds: 400);
  static const Duration _popupAnimDuration = Duration(milliseconds: 400);
  static const Duration _popupStartDelay = Duration(milliseconds: 300);

  late final AnimationController _popupAnim;
  late final Animation<double> _popupOpacity;
  late final Animation<Offset> _popupSlide;

  int _currentSlide = 0;
  Timer? _autoAdvanceTimer;
  Timer? _popupDelayTimer;

  @override
  void initState() {
    super.initState();
    _popupAnim = AnimationController(vsync: this, duration: _popupAnimDuration);
    _popupOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _popupAnim, curve: Curves.easeOut));
    _popupSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _popupAnim, curve: Curves.easeOut));

    _scheduleAutoAdvance();
    _schedulePopupAnim();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _popupDelayTimer?.cancel();
    _popupAnim.dispose();
    super.dispose();
  }

  void _scheduleAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(_autoAdvanceInterval, _advanceSlide);
  }

  void _schedulePopupAnim() {
    _popupDelayTimer?.cancel();
    _popupAnim.reset();
    _popupDelayTimer = Timer(_popupStartDelay, () {
      if (mounted) _popupAnim.forward();
    });
  }

  void _advanceSlide() {
    if (!mounted) return;
    setState(() {
      _currentSlide = (_currentSlide + 1) % _slides.length;
    });
    _scheduleAutoAdvance();
    _schedulePopupAnim();
  }

  Future<void> _onPrimaryPressed() async {
    _autoAdvanceTimer?.cancel();
    ref.read(localFlagServiceProvider).setHasLaunched();
    if (!mounted) return;
    context.goNamed(AppRoute.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentSlide];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: _switchDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: _slideFadeTransition,
            child: _SlideImage(key: ValueKey(_currentSlide), slide: slide),
          ),
          if (slide.popup != null)
            _SlidePopup(
              slide: slide,
              opacity: _popupOpacity,
              offset: _popupSlide,
            ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSizes.lg),
                _TitleBlock(slide: slide),
                const Spacer(),
                _BottomContent(slide: slide, onPrimary: _onPrimaryPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slideFadeTransition(Widget child, Animation<double> animation) {
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.body,
    required this.image,
    this.popup,
    this.popupAlignment = Alignment.center,
    this.popupWidthFactor = 0.8,
  });

  final String title;
  final String body;
  final AssetGenImage image;
  final AssetGenImage? popup;
  final Alignment popupAlignment;
  final double popupWidthFactor;
}

class _SlidePopup extends StatelessWidget {
  const _SlidePopup({
    required this.slide,
    required this.opacity,
    required this.offset,
  });

  final _SlideData slide;
  final Animation<double> opacity;
  final Animation<Offset> offset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: slide.popupAlignment,
        child: FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: offset,
            child: FractionallySizedBox(
              widthFactor: slide.popupWidthFactor,
              child: slide.popup!.image(
                fit: BoxFit.fitWidth,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideImage extends StatelessWidget {
  const _SlideImage({required this.slide, super.key});

  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: slide.image.image(
        width: double.infinity,
        fit: BoxFit.fitWidth,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.slide});

  final _SlideData slide;

  static const _eyebrow = "We'll Help You with";

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: AppColors.text, height: 34 / 22);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey(slide.title),
          children: [
            Text(_eyebrow, textAlign: TextAlign.center, style: style),
            Text(slide.title, textAlign: TextAlign.center, style: style),
          ],
        ),
      ),
    );
  }
}

class _BottomContent extends StatelessWidget {
  const _BottomContent({required this.slide, required this.onPrimary});

  final _SlideData slide;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: AppColors.text, height: 22 / 15);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        0,
        AppSizes.pagePaddingH,
        AppSizes.pagePaddingV,
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              slide.body,
              key: ValueKey(slide.body),
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppPillButton(
            key: const Key('onboarding_intro_primary'),
            label: "Let's Go!",
            onPressed: onPrimary,
          ),
        ],
      ),
    );
  }
}

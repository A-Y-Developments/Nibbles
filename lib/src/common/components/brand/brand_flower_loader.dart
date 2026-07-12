import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';

/// Shared brand loader — the Nibbles brand flower rotating gently over a soft
/// pulsing glow, with a gold dot orbiting the bloom. Used by every passive
/// loading transition (post-onboarding baby setup, Give Feedback submit,
/// meal-plan AI generation).
///
/// Self-contained: owns its rotation / pulse / orbit controllers so callers
/// just drop it in. Purely presentational — no routing, analytics, or
/// surrounding layout. The quatrefoil rotates rigidly (linear) so the spin
/// reads as a steady bloom with no wobble.
///
/// Default constructor = the full-screen passive-transition loader (360px,
/// ~9s/rev). [BrandFlowerLoader.small] is the in-place page/list loader that
/// replaces stock spinners: smaller, and spun faster (~1.6s/rev) so at small
/// scale it reads as a lively loader rather than a frozen bloom.
class BrandFlowerLoader extends StatefulWidget {
  const BrandFlowerLoader({this.blobKey, super.key})
    : size = 360,
      rotationPeriod = const Duration(seconds: 9);

  const BrandFlowerLoader.small({this.blobKey, this.size = 72, super.key})
    : rotationPeriod = const Duration(milliseconds: 1600);

  final Key? blobKey;
  final double size;
  final Duration rotationPeriod;

  @override
  State<BrandFlowerLoader> createState() => _BrandFlowerLoaderState();
}

class _BrandFlowerLoaderState extends State<BrandFlowerLoader>
    with TickerProviderStateMixin {
  static const Duration _pulsePeriod = Duration(milliseconds: 1800);
  static const Duration _orbitPeriod = Duration(milliseconds: 4000);

  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationPeriod,
    )..repeat();
    _pulseController = AnimationController(vsync: this, duration: _pulsePeriod)
      ..repeat(reverse: true);
    _orbitController = AnimationController(vsync: this, duration: _orbitPeriod)
      ..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size * 0.06;

    return SizedBox.square(
      key: widget.blobKey,
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _GlowPulse(controller: _pulseController, size: widget.size * 0.72),
          RotationTransition(
            turns: _rotationController,
            child: BrandFlower(size: widget.size * 0.78),
          ),
          RotationTransition(
            turns: _orbitController,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowPulse extends StatelessWidget {
  const _GlowPulse({required this.controller, required this.size});

  final AnimationController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(curved),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 0.65).animate(curved),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.gold, Color(0x00E3B341)],
            ),
          ),
        ),
      ),
    );
  }
}

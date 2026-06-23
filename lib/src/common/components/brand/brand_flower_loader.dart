import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

/// Shared brand loader — the Nibbles petal flower with its outer petals
/// rotating and the center glow gently pulsing. Used by every passive loading
/// transition (post-onboarding baby setup, Give Feedback submit).
///
/// Self-contained: owns its rotation + pulse controllers so callers just drop
/// it in. Purely presentational — no routing, analytics, or surrounding layout.
///   - Outer butter [Quatrefoil] rotates continuously (~9s/rev, linear).
///   - Inner sage [Quatrefoil] stays static.
///   - Soft butter glow dot pulses gently (~1.2s, reverse-repeat).
class BrandFlowerLoader extends StatefulWidget {
  const BrandFlowerLoader({this.blobKey, super.key});

  final Key? blobKey;

  @override
  State<BrandFlowerLoader> createState() => _BrandFlowerLoaderState();
}

class _BrandFlowerLoaderState extends State<BrandFlowerLoader>
    with TickerProviderStateMixin {
  /// Full revolution of the outer petals — linear so the spin reads as a steady
  /// bloom, never a jolt.
  static const Duration _rotationPeriod = Duration(seconds: 9);

  /// Center-glow pulse half-cycle. Reverse-repeats so the dot breathes gently
  /// between [_glowPulseMin] and full scale.
  static const Duration _pulsePeriod = Duration(milliseconds: 1200);

  /// Lower bound of the glow pulse scale (full scale = 1.0).
  static const double _glowPulseMin = 0.85;

  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: _rotationPeriod,
    )..repeat();
    _pulseController = AnimationController(vsync: this, duration: _pulsePeriod);
    _glowPulse = Tween<double>(begin: 1, end: _glowPulseMin).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedPetalBlob(
      key: widget.blobKey,
      rotation: _rotationController,
      glowPulse: _glowPulse,
    );
  }
}

/// Brand flower — a decomposed `PetalBlob` so the outer petals can rotate
/// independently of the pulsing center.
///
/// Geometry mirrors `PetalBlob` byte-for-byte (outer = avatarXl*1.84, inner
/// ~52% of outer, glow ratio sp12*1.4/outer) so the static frame is visually
/// identical to the consent screen's cluster.
class _AnimatedPetalBlob extends StatelessWidget {
  const _AnimatedPetalBlob({
    required this.rotation,
    required this.glowPulse,
    super.key,
  });

  final Animation<double> rotation;
  final Animation<double> glowPulse;

  @override
  Widget build(BuildContext context) {
    const outerSize = AppSizes.avatarXl * 1.84;
    const baseInner = AppSizes.avatarXl * 0.96;
    const baseGlow = AppSizes.sp12 * 1.4;
    const innerSize = outerSize * (baseInner / outerSize);
    const glowSize = outerSize * (baseGlow / outerSize);

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: rotation,
            child: const Quatrefoil(
              size: outerSize,
              coreColor: AppColors.butter,
            ),
          ),
          const Quatrefoil(
            size: innerSize,
            petalColor: AppColors.green,
            coreColor: AppColors.greenDeep,
          ),
          ScaleTransition(
            scale: glowPulse,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.butter,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.butter.withValues(alpha: 0.9),
                    blurRadius: AppSizes.sm,
                    spreadRadius: AppSizes.xs,
                  ),
                ],
              ),
              child: const SizedBox(width: glowSize, height: glowSize),
            ),
          ),
        ],
      ),
    );
  }
}

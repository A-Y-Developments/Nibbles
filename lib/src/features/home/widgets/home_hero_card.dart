import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/greeting_card.dart';
import 'package:nibbles/src/features/home/widgets/hero_allergen_section.dart';

/// Lime hero card — greeting, two coral stat rings (today's meals + allergen
/// progress), status chips, a bleeding food bowl and the allergen hero
/// section. Composed once per Home render; all data is passed in.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    required this.babyName,
    required this.ageMonths,
    required this.dateOfBirth,
    required this.mealCount,
    required this.mealTarget,
    required this.introducedCount,
    required this.ironRich,
    required this.hasActiveProgramAllergen,
    required this.heroState,
    required this.allergenKey,
    required this.allergenDisplayName,
    required this.allergenReactionFlags,
    required this.onStartTracker,
    required this.onOpenDetail,
    super.key,
  });

  final String babyName;
  final int ageMonths;
  final DateTime dateOfBirth;
  final int mealCount;
  final int mealTarget;
  final int introducedCount;
  final bool ironRich;
  final bool hasActiveProgramAllergen;
  final HomeAllergenHeroState heroState;
  final String? allergenKey;
  final String allergenDisplayName;
  final List<bool> allergenReactionFlags;
  final VoidCallback onStartTracker;
  final VoidCallback onOpenDetail;

  static const double _leftColumnWidth = 185;
  static const double _bowlImageWidth = 185;
  static const double _bowlOverhang = 24;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (ironRich)
        const AppChip(
          label: 'Iron Rich',
          icon: Icon(Icons.check_rounded, size: 12),
        ),
      if (hasActiveProgramAllergen)
        const AppChip(
          label: 'Active Program Allergens',
          icon: Icon(Icons.check_rounded, size: 12),
        ),
    ];

    final radius = BorderRadius.circular(AppSizes.radiusXl);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: radius,
        boxShadow: AppSizes.shadowCard,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onStartTracker,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bowlLeftEdge =
                  constraints.maxWidth - _bowlImageWidth + _bowlOverhang;
              final greetingMaxWidth =
                  (bowlLeftEdge - AppSizes.md - AppSizes.sm).clamp(
                    120.0,
                    _leftColumnWidth,
                  );

              return Stack(
                children: [
                  Positioned(
                    top: -8,
                    right: -_bowlOverhang,
                    child: Assets.images.home.heroBowl.image(
                      width: _bowlImageWidth,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: _leftColumnWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: greetingMaxWidth,
                                child: GreetingCard(
                                  babyName: babyName,
                                  ageMonths: ageMonths,
                                  dateOfBirth: dateOfBirth,
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              _StatRing(
                                label: 'TODAY MEALS',
                                max: '/$mealTarget',
                                numerator: mealCount,
                                denominator: mealTarget,
                              ),
                              const SizedBox(height: AppSizes.sp12),
                              _StatRing(
                                label: 'ALLERGEN',
                                max: '/${kAllergenKeys.length}',
                                numerator: introducedCount,
                                denominator: kAllergenKeys.length,
                              ),
                            ],
                          ),
                        ),
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.md),
                          Wrap(
                            spacing: AppSizes.sm,
                            runSpacing: AppSizes.sm,
                            children: chips
                                .animate(interval: AppDurations.fast)
                                .fadeIn(duration: AppDurations.fade)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                  duration: AppDurations.base,
                                  curve: AppCurves.emphasized,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppSizes.md),
                        HeroAllergenSection(
                          heroState: heroState,
                          allergenKey: allergenKey,
                          displayName: allergenDisplayName,
                          reactionFlags: allergenReactionFlags,
                          onStartTracker: onStartTracker,
                          onOpenDetail: onOpenDetail,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Coral progress ring beside a stacked label + value. Folded in from the
/// retired `stat_ring_card.dart`.
class _StatRing extends StatelessWidget {
  const _StatRing({
    required this.label,
    required this.max,
    required this.numerator,
    required this.denominator,
  });

  final String label;
  final String max;
  final int numerator;
  final int denominator;

  static const double _ringSize = 54;
  static const double _holeSize = 40;
  static const double _creamGap = 8;

  double get _fraction {
    if (denominator <= 0) return 0;
    final raw = numerator / denominator;
    return raw.isFinite ? raw.clamp(0.0, 1.0) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: _ringSize + _creamGap * 2,
          height: _ringSize + _creamGap * 2,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.cardCream,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _fraction),
              duration: AppDurations.slow,
              curve: AppCurves.emphasized,
              builder: (context, fraction, _) => CustomPaint(
                painter: _RingPainter(
                  fraction: fraction,
                  fillColor: AppColors.coralDeep,
                  trackColor: AppColors.coral.withValues(alpha: 0.18),
                  strokeWidth: (_ringSize - _holeSize) / 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.fgFaint,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: numerator),
                    duration: AppDurations.slow,
                    curve: AppCurves.emphasized,
                    builder: (context, count, _) => Text(
                      '$count',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sp2),
                  Text(
                    max,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.fgFaint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.fillColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color fillColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (fraction > 0) {
      final paint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * fraction, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

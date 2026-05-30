import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';

/// NIB-65 — Butter-soft stat card.
///
/// Two coral progress rings (TODAY MEALS + ALLERGEN) sit above a wrap of
/// summary chips. The ALLERGEN denominator is locked to 9 — the canonical
/// board length — overriding the JSX preview's `/11`. The TODAY MEALS ring
/// renders against an optional target supplied by the caller; until the
/// home controller wires meals into this card it shows `0/0` (track only).
///
/// Existing required params from NIB-86 are kept untouched. The optional
/// [hasIronRichRecipes], [todayMealCount] and [todayMealTarget] are
/// additive so future call-sites can light up the full design without
/// `home_screen.dart` having to change today.
class StatRingCard extends StatelessWidget {
  const StatRingCard({
    required this.safeCount,
    required this.flaggedCount,
    required this.notStartedCount,
    required this.inProgressCount,
    this.todayMealCount = 0,
    this.todayMealTarget = 0,
    this.hasIronRichRecipes = false,
    super.key,
  });

  // Allergen counts (NIB-86 wired). [safeCount] drives the ring numerator.
  final int safeCount;
  final int flaggedCount;
  final int notStartedCount;
  final int inProgressCount;

  // Meals — optional. The home controller does not yet expose these so the
  // ring renders the empty track when both default to 0.
  final int todayMealCount;
  final int todayMealTarget;

  // Gates the '✓ Iron Rich' chip; hidden by default per spec.
  final bool hasIronRichRecipes;

  /// Canonical allergen board length — see `.claude/rules/domain.md`.
  static const int _allergenTotal = 9;

  @override
  Widget build(BuildContext context) {
    // Chip tone matches `HomeScreen.jsx` (neutral / coral-soft) — the
    // screen-level composition outranks the generic catalogue here.
    // 'Active Program Allergens' renders unconditionally per spec — only
    // 'Iron Rich' is gated on the optional [hasIronRichRecipes] arg.
    final chips = <Widget>[
      if (hasIronRichRecipes) const AppChip(label: '✓ Iron Rich'),
      const AppChip(label: '✓ Active Program Allergens'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md - 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatRing(
                  label: 'TODAY MEALS',
                  value: '$todayMealCount',
                  max: '/$todayMealTarget',
                  numerator: todayMealCount,
                  denominator: todayMealTarget,
                ),
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: _StatRing(
                  label: 'ALLERGEN',
                  value: '$safeCount',
                  max: '/$_allergenTotal',
                  numerator: safeCount,
                  denominator: _allergenTotal,
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sp12),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}

/// Local stat-ring widget — 44px conic coral-deep ring over a 32px
/// butter-soft hole, beside a stacked label + value.
///
/// Kept private to this file: it is a one-off composition that nothing
/// else in the codebase needs to consume.
class _StatRing extends StatelessWidget {
  const _StatRing({
    required this.label,
    required this.value,
    required this.max,
    required this.numerator,
    required this.denominator,
  });

  final String label;
  final String value;
  final String max;
  final int numerator;
  final int denominator;

  static const double _ringSize = 44;
  static const double _holeSize = 32;

  double get _fraction {
    if (denominator <= 0) return 0;
    final raw = numerator / denominator;
    return raw.isFinite ? raw.clamp(0.0, 1.0) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _ringSize,
          height: _ringSize,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: _fraction,
              fillColor: AppColors.coralDeep,
              trackColor: AppColors.coral.withValues(alpha: 0.18),
              holeColor: AppColors.butterSoft,
              holeSize: _holeSize,
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
                  Text(
                    value,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      height: 1,
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
    required this.holeColor,
    required this.holeSize,
  });

  final double fraction;
  final Color fillColor;
  final Color trackColor;
  final Color holeColor;
  final double holeSize;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Track — full circle, soft coral.
    canvas.drawCircle(centre, radius, Paint()..color = trackColor);

    // Fill arc — coral-deep, starting at 12 o'clock.
    if (fraction > 0) {
      final paint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        true,
        paint,
      );
    }

    // Hole — butter-soft inner disc to leave only the ring band visible.
    canvas.drawCircle(centre, holeSize / 2, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.holeColor != holeColor ||
      oldDelegate.holeSize != holeSize;
}

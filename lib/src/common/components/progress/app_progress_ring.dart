import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

/// Conic progress ring. Mirrors components-progress preview `.ring`:
/// coralDeep sweep over a coralSoft track, white center hole showing value/max.
class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    required this.value,
    required this.max,
    this.diameter = 110,
    this.thickness = 15,
    super.key,
  }) : assert(max > 0, 'max must be positive');

  final int value;
  final int max;
  final double diameter;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final progress = (value / max).clamp(0.0, 1.0);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          thickness: thickness,
          fill: AppColors.coralDeep,
          track: AppColors.coralSoft,
        ),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$value',
                  style: const TextStyle(
                    fontFamily: FontFamily.parkinsans,
                    // Figma "Large/Bold" 28 (report 1089:17373 line 56).
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: AppColors.coralDeep,
                  ),
                ),
                TextSpan(
                  text: '/$max',
                  style: const TextStyle(
                    fontFamily: FontFamily.parkinsans,
                    fontSize: 12,
                    height: 1,
                    color: AppColors.fgFaint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.thickness,
    required this.fill,
    required this.track,
  });

  final double progress;
  final double thickness;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      // Start at 12 o'clock, sweep clockwise.
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.thickness != thickness ||
      oldDelegate.fill != fill ||
      oldDelegate.track != track;
}

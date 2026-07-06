import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

/// Full-screen confetti burst shown after an allergen introduction starts.
/// Auto-dismisses after ~2.6s; tapping anywhere dismisses early.
Future<void> showConfettiCelebration(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => const _ConfettiCelebration(),
  );
}

class _ConfettiCelebration extends StatefulWidget {
  const _ConfettiCelebration();

  @override
  State<_ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<_ConfettiCelebration> {
  late final ConfettiController _controller;
  Timer? _dismissTimer;

  static const List<Color> _colors = <Color>[
    AppColors.greenDeep,
    AppColors.lime,
    AppColors.salmon,
    AppColors.butter,
    AppColors.coral,
  ];

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    )..play();
    _dismissTimer = Timer(const Duration(milliseconds: 2600), _dismiss);
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismiss,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.28,
              emissionFrequency: 0.05,
              numberOfParticles: 24,
              maxBlastForce: 22,
              minBlastForce: 8,
              colors: _colors,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: pi / 3,
              gravity: 0.28,
              emissionFrequency: 0.05,
              numberOfParticles: 14,
              colors: _colors,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: 2 * pi / 3,
              gravity: 0.28,
              emissionFrequency: 0.05,
              numberOfParticles: 14,
              colors: _colors,
            ),
          ),
        ],
      ),
    );
  }
}

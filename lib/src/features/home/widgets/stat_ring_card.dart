import 'package:flutter/material.dart';

/// Placeholder for NIB-65 (allergen progress stat ring). Wave 2 will replace.
class StatRingCard extends StatelessWidget {
  const StatRingCard({
    required this.safeCount,
    required this.flaggedCount,
    required this.notStartedCount,
    required this.inProgressCount,
    super.key,
  });

  final int safeCount;
  final int flaggedCount;
  final int notStartedCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-65): implement stat ring card per redesign.
    return const SizedBox.shrink();
  }
}

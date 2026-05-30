import 'package:flutter/material.dart';

/// Placeholder for NIB-65 (greeting card). Wave 2 will replace.
class GreetingCard extends StatelessWidget {
  const GreetingCard({
    required this.babyName,
    required this.ageMonths,
    super.key,
  });

  final String babyName;
  final int ageMonths;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-65): implement greeting card per redesign.
    return const SizedBox.shrink();
  }
}

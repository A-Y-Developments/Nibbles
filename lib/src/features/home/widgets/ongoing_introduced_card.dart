import 'package:flutter/material.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Placeholder for NIB-77 (ongoing-introduced card). Wave 2 will replace.
class OngoingIntroducedCard extends StatelessWidget {
  const OngoingIntroducedCard({
    required this.allergenStatuses,
    super.key,
  });

  final Map<String, AllergenStatus> allergenStatuses;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-77): implement ongoing-introduced card per redesign.
    return const SizedBox.shrink();
  }
}

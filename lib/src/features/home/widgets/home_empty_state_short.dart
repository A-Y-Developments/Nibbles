import 'package:flutter/material.dart';

/// Placeholder for NIB-96 (short empty-state variant — some logs but no meals
/// today, etc.). Wave 2 will replace.
class HomeEmptyStateShort extends StatelessWidget {
  const HomeEmptyStateShort({this.babyName, super.key});

  final String? babyName;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-96): implement short empty state per redesign.
    return const SizedBox.shrink();
  }
}

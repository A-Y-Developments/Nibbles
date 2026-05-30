import 'package:flutter/material.dart';

/// Placeholder for NIB-96 (no-meals-today empty-state variant). Wave 2 will
/// replace.
class HomeNoMealsState extends StatelessWidget {
  const HomeNoMealsState({this.babyName, super.key});

  final String? babyName;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-96): implement no-meals state per redesign.
    return const SizedBox.shrink();
  }
}

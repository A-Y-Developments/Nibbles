import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Meal Plan (MP-01)')));
}

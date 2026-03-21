import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllergenTrackerScreen extends ConsumerWidget {
  const AllergenTrackerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Allergen Tracker (AL-01/02)')));
}

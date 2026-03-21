import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllergenDetailScreen extends ConsumerWidget {
  const AllergenDetailScreen({required this.allergenKey, super.key});
  final String allergenKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(body: Center(child: Text('Allergen Detail — $allergenKey')));
}

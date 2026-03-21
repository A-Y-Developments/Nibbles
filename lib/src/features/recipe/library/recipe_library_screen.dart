import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeLibraryScreen extends ConsumerWidget {
  const RecipeLibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Recipe Library (RC-01)')));
}

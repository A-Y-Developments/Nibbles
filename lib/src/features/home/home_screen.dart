import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Home Dashboard (HM-01)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '⚠️ TEMP: QA nav buttons — remove before merging HM-01',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.goNamed(
                    AppRoute.allergenDetail.name,
                    pathParameters: {'allergenKey': 'peanut'},
                  ),
                  child: const Text('AL-03 Allergen Detail (Peanut)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.goNamed(AppRoute.allergenTracker.name),
                  child: const Text('AL-01/02 Allergen Tracker'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.goNamed(AppRoute.allergenComplete.name),
                  child: const Text('AL-08 Program Complete'),
                ),
              ],
            ),
          ),
        ),
      );
}

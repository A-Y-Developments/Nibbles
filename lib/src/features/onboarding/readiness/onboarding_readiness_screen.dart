import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingReadinessScreen extends ConsumerWidget {
  const OnboardingReadinessScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Readiness Check (OB-03–09)')));
}

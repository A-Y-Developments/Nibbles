import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingBabySetupScreen extends ConsumerWidget {
  const OnboardingBabySetupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Baby Setup (OB-11–13)')));
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingIntroScreen extends ConsumerWidget {
  const OnboardingIntroScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Center(child: Text('Onboarding Intro (OB-01/02)')));
}

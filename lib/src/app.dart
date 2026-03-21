import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_theme.dart';

/// Root widget — router wired in NIB-9.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Nibbles',
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(child: Text('Nibbles')),
      ),
    );
  }
}

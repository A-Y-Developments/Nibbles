import 'package:flutter/material.dart';

/// Root widget — router and theme wired in NIB-9 and NIB-10.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nibbles',
      home: Scaffold(
        body: Center(child: Text('Nibbles')),
      ),
    );
  }
}

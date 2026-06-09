import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('harness smoke check', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('smoke'))),
    );
    expect(find.text('smoke'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/brand/brand_logo.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

void main() {
  group('BrandLogo (NIB-117)', () {
    testWidgets('renders default lockup: Quatrefoil + nibbles wordmark',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BrandLogo()),
        ),
      );

      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.byType(Quatrefoil), findsOneWidget);
      expect(find.text('nibbles'), findsOneWidget);
    });

    testWidgets('honors size param on the mark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BrandLogo(size: 48)),
        ),
      );

      final quatrefoil = tester.widget<Quatrefoil>(find.byType(Quatrefoil));
      expect(quatrefoil.size, 48);
    });
  });
}

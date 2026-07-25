// Firebase platform-interface packages are transitive deps; the public
// barrels do not re-export FirebaseAnalyticsPlatform / setupFirebaseCoreMocks.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/legal/constants/legal_document.dart';
import 'package:nibbles/src/features/legal/legal_document_screen.dart';

/// Coverage for the in-app legal reader.
///
/// Pins:
///   - Both documents resolve by slug and render their heading/body blocks.
///   - An unknown slug renders the not-found fallback instead of crashing.
///   - The Privacy Policy stays gated while its source doc has unfilled
///     placeholders.
Future<void> _pump(WidgetTester tester, String slug) async {
  await tester.pumpWidget(MaterialApp(home: LegalDocumentScreen(slug: slug)));
  await tester.pump();
}

// Firebase no-op platform — drops the screen-view call in initState.
class _NoopAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  _NoopAnalyticsPlatform() : super();

  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) => this;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {}
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  testWidgets('renders the Medical & Safety Disclaimer', (tester) async {
    await _pump(tester, kLegalDisclaimerSlug);

    expect(find.text('Medical & Safety Disclaimer'), findsOneWidget);
    expect(find.text('1. General educational information'), findsOneWidget);
    expect(
      find.text(
        'Nibbles provides general educational information and practical '
        'resources relating to infant and toddler feeding, nutrition, food '
        'preparation, food exposure and family mealtimes.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders the Privacy Policy when reached directly', (
    tester,
  ) async {
    await _pump(tester, kLegalPrivacyPolicySlug);

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('1. About this Privacy Policy'), findsOneWidget);
  });

  testWidgets('unknown slug renders the not-found fallback', (tester) async {
    await _pump(tester, 'nope');

    expect(find.text('Document not found'), findsOneWidget);
    expect(find.byKey(const Key('legal_document_back')), findsOneWidget);
  });

  test('every document resolves by its own slug', () {
    for (final document in kLegalDocuments) {
      expect(legalDocumentForSlug(document.slug), same(document));
    }
    expect(legalDocumentForSlug('nope'), isNull);
  });

  test('Privacy Policy stays gated while its source has placeholders', () {
    final hasPlaceholder = legalPrivacyPolicyBlockText().any(
      (t) => t.contains('[INSERT'),
    );

    expect(
      hasPlaceholder,
      isTrue,
      reason: 'guard is meaningless once the placeholders are filled',
    );
    expect(
      kPrivacyPolicyPublished,
      isFalse,
      reason: 'flip this only after every [INSERT …] placeholder is resolved',
    );
  });
}

/// Flattens every string in the Privacy Policy for placeholder scanning.
Iterable<String> legalPrivacyPolicyBlockText() sync* {
  final document = legalDocumentForSlug(kLegalPrivacyPolicySlug)!;
  for (final block in document.blocks) {
    switch (block) {
      case LegalHeading():
        yield block.text;
      case LegalParagraph():
        yield block.text;
      case LegalBullets():
        yield* block.items;
    }
  }
}

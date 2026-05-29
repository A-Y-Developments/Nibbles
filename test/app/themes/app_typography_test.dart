import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

void main() {
  // GoogleFonts.figtree() touches ServicesBinding to register the bundled
  // font, so the test binding must exist before AppTypography is evaluated.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTypography role → family mapping (NIB-121)', () {
    final textTheme = AppTypography.textTheme;

    test('display/title/headline slots use Parkinsans', () {
      final parkinsansSlots = <String, TextStyle?>{
        'displayLarge': textTheme.displayLarge,
        'displayMedium': textTheme.displayMedium,
        'displaySmall': textTheme.displaySmall,
        'headlineLarge': textTheme.headlineLarge,
        'headlineMedium': textTheme.headlineMedium,
        'headlineSmall': textTheme.headlineSmall,
        'titleLarge': textTheme.titleLarge,
        'titleMedium': textTheme.titleMedium,
        'titleSmall': textTheme.titleSmall,
      };

      for (final entry in parkinsansSlots.entries) {
        expect(
          entry.value?.fontFamily,
          FontFamily.parkinsans,
          reason: '${entry.key} should render in Parkinsans',
        );
      }
    });

    test('body/label slots use Figtree', () {
      final figtreeSlots = <String, TextStyle?>{
        'bodyLarge': textTheme.bodyLarge,
        'bodyMedium': textTheme.bodyMedium,
        'bodySmall': textTheme.bodySmall,
        'labelLarge': textTheme.labelLarge,
        'labelMedium': textTheme.labelMedium,
        'labelSmall': textTheme.labelSmall,
      };

      for (final entry in figtreeSlots.entries) {
        expect(
          entry.value?.fontFamily,
          contains('Figtree'),
          reason: '${entry.key} should render in Figtree',
        );
      }
    });

    test('helper styles split by role: sectionTitle Parkinsans, body Figtree',
        () {
      expect(AppTypography.sectionTitle.fontFamily, FontFamily.parkinsans);
      expect(AppTypography.caption.fontFamily, contains('Figtree'));
      expect(AppTypography.button.fontFamily, contains('Figtree'));
      expect(AppTypography.bodyBold.fontFamily, contains('Figtree'));
    });

    test('ramp metrics preserved on swapped body slots', () {
      expect(textTheme.bodyLarge?.fontSize, 15);
      expect(textTheme.bodyLarge?.fontWeight, FontWeight.w400);
      expect(textTheme.bodyLarge?.height, 1.467);
      expect(textTheme.labelSmall?.letterSpacing, 0.6);
    });
  });
}

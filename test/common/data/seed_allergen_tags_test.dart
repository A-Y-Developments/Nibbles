import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// NIB-181 guard: a seeded recipe whose ingredient carries an allergen via a
/// processed/derived form (butter/milk/cheese -> dairy, sesame oil -> sesame,
/// soy sauce/tofu -> soy) must list that allergen in `allergen_tags`. The UI
/// renders the stored tags verbatim, so an under-tagged seed row is a
/// user-facing safety defect. Scoped to the three derived-ingredient allergens
/// this class of bug covers; whole-food allergens are tagged at authoring time.
void main() {
  final excludedFromDairy = <String>[
    'breast milk',
    'formula',
    'almond milk',
    'oat milk',
    'coconut milk',
    'soy milk',
    'rice milk',
    'cashew milk',
    'hemp milk',
    'pea milk',
    'peanut butter',
    'almond butter',
    'cashew butter',
    'pecan butter',
    'walnut butter',
    'hazelnut butter',
    'sunflower butter',
    'seed butter',
    'nut butter',
  ];

  bool impliesDairy(String name) {
    if (excludedFromDairy.any(name.contains)) return false;
    return name.contains('butter') ||
        name.contains('cheese') ||
        name.contains('milk') ||
        name.contains('cream') ||
        name.contains('yogurt') ||
        name.contains('yoghurt') ||
        name.contains('ghee');
  }

  bool impliesSesame(String name) =>
      name.contains('sesame') || name.contains('tahini');

  bool impliesSoy(String name) =>
      name.contains('soy') ||
      name.contains('tofu') ||
      name.contains('edamame') ||
      name.contains('miso');

  final derivedRules = <String, bool Function(String)>{
    'dairy': impliesDairy,
    'sesame': impliesSesame,
    'soy': impliesSoy,
  };

  test(
    'every seeded recipe tags dairy/sesame/soy implied by its ingredients',
    () {
      final seed = File('supabase/seed.sql').readAsStringSync();

      final rowPattern = RegExp(
        r"'([^']*)',\s*'[^']*',\s*ARRAY\[([^\]]*)\],\s*'(\[.*?\])'",
        dotAll: true,
      );

      final matches = rowPattern.allMatches(seed).toList();
      expect(
        matches,
        isNotEmpty,
        reason: 'no recipe rows parsed from seed.sql',
      );

      final violations = <String>[];

      for (final m in matches) {
        final title = m.group(1)!;
        final tags = RegExp(
          "'([^']*)'",
        ).allMatches(m.group(2)!).map((t) => t.group(1)!).toSet();
        final ingredients = (jsonDecode(m.group(3)!) as List)
            .map((e) => (e as Map)['name'].toString().toLowerCase())
            .toList();

        derivedRules.forEach((allergen, implies) {
          final hit = ingredients.firstWhere(implies, orElse: () => '');
          if (hit.isNotEmpty && !tags.contains(allergen)) {
            violations.add('$title: "$hit" implies $allergen but tags=$tags');
          }
        });
      }

      expect(
        violations,
        isEmpty,
        reason: 'under-tagged allergen(s):\n${violations.join('\n')}',
      );
    },
  );
}

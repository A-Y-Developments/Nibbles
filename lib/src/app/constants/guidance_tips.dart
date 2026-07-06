import 'package:nibbles/src/common/domain/entities/guidance_tip.dart';

/// Catalog of weaning / solids guidance tips surfaced on Home.
///
/// Copy is educational (aligned with NHS / AAP / CDC weaning guidance) and
/// deliberately non-medical. Titles stay <= ~28 chars and bodies stay to a
/// single line to match the design. `GuidanceService` owns which tips apply
/// for a given day; this file only owns the copy + stable ids.
abstract final class GuidanceTips {
  static const milkPriority = GuidanceTip(
    id: 'milk_priority',
    iconKey: 'milk',
    title: 'Milk feeds still the priority',
    body: 'Breastmilk or formula remains the main nutrition before age 1.',
  );

  static const offerWater = GuidanceTip(
    id: 'offer_water',
    iconKey: 'water',
    title: 'Offer water with each meal',
    body: 'Small sips from an open cup help from 6 months.',
  );

  static const noFruitToday = GuidanceTip(
    id: 'no_fruit_today',
    iconKey: 'fruit',
    title: 'No fruit yet today',
    body: 'Round out the day with a soft fruit alongside a meal.',
  );

  static const includeIron = GuidanceTip(
    id: 'include_iron',
    iconKey: 'iron',
    title: 'Add an iron-rich food',
    body: 'Iron stores dip from 6 months — offer meat, lentils or cereal.',
  );

  static const skipSaltSugar = GuidanceTip(
    id: 'skip_salt_sugar',
    iconKey: 'salt',
    title: 'Skip added salt and sugar',
    body: "Baby's kidneys can't handle much salt before age 1.",
  );

  static const tryFingerFoods = GuidanceTip(
    id: 'try_finger_foods',
    iconKey: 'hand',
    title: 'Try soft finger foods',
    body: 'Soft, graspable strips build self-feeding from 8 months.',
  );

  static const offerVariety = GuidanceTip(
    id: 'offer_variety',
    iconKey: 'texture',
    title: 'Offer varied textures',
    body: 'Mashed, lumpy and soft pieces encourage chewing from 7 months.',
  );

  static const introduceAllergens = GuidanceTip(
    id: 'introduce_allergens',
    iconKey: 'shield',
    title: 'Introduce allergens early',
    body: 'Offer common allergens one at a time, a few days apart.',
  );

  /// Fixed, non-catalog copy rendered by the UI as a separate disclaimer
  /// element — never returned by `GuidanceService.tipsFor`.
  static const healthDisclaimerBody =
      'Our recommendations are intended for educational purposes only and '
      'should not be considered medical advice.';
}

/// Lowercase fruit terms used to decide whether a day already includes a
/// fruit. Matched against recipe category, nutrition tags and ingredient
/// names. Kept intentionally small.
const List<String> kFruitTerms = [
  'fruit',
  'apple',
  'banana',
  'pear',
  'berry',
  'blueberry',
  'strawberry',
  'mango',
  'peach',
  'plum',
  'apricot',
  'melon',
  'orange',
];

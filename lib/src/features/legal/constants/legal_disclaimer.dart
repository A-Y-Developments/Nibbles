// Bullet items must be single-line string literals: `no_adjacent_strings_in_list`
// forbids wrapping them across lines and `prefer_adjacent_string_concatenation`
// forbids joining them with `+`. Some legal sentences are simply longer than 80
// characters, so the width rule is waived for this data-only file.
// ignore_for_file: lines_longer_than_80_chars

import 'package:nibbles/src/features/legal/constants/legal_document.dart';

/// Medical and Safety Disclaimer — verbatim from the source document.
const LegalDocument legalDisclaimerDocument = LegalDocument(
  slug: kLegalDisclaimerSlug,
  title: 'Medical & Safety Disclaimer',
  blocks: [
    LegalHeading('1. General educational information'),
    LegalParagraph(
      'Nibbles provides general educational information and practical '
      'resources relating to infant and toddler feeding, nutrition, food '
      'preparation, food exposure and family mealtimes.',
    ),
    LegalParagraph(
      'The information made available through Nibbles is provided for general '
      'educational and informational purposes only.',
    ),

    LegalHeading('2. Not medical or healthcare advice'),
    LegalParagraph(
      'Nibbles does not provide medical advice, diagnosis, treatment, therapy, '
      'emergency assistance or personalised healthcare services.',
    ),
    LegalParagraph(
      'Nothing available through Nibbles should be interpreted as medical, '
      'nutritional, developmental or therapeutic advice tailored to an '
      'individual child.',
    ),
    LegalParagraph(
      'Use of Nibbles does not establish a doctor–patient, dietitian–client, '
      'nutritionist–client or other healthcare professional relationship '
      'between the user and First Nibbles Pty Ltd, its officers, employees, '
      'contractors, contributors or content reviewers.',
    ),
    LegalParagraph(
      'Nibbles is not a substitute for advice from a doctor, paediatrician, '
      'accredited practising dietitian, speech pathologist, child and family '
      'health nurse or other appropriately qualified health professional who '
      "can assess the child's individual circumstances.",
    ),

    LegalHeading('3. Every child is different'),
    LegalParagraph(
      'Every child has different health, developmental, nutritional, sensory '
      'and feeding needs.',
    ),
    LegalParagraph(
      'Content available through Nibbles may not be suitable for every child, '
      'including children who:',
    ),
    LegalBullets([
      'Were born prematurely.',
      'Have known or suspected food allergies.',
      'Have feeding or swallowing difficulties.',
      'Have developmental delays or disabilities.',
      'Have growth or weight concerns.',
      'Have nutritional deficiencies.',
      'Have medical conditions.',
      'Have oral-motor or sensory difficulties.',
      'Have special dietary requirements.',
      'Have been advised to delay or modify the introduction of solid foods.',
    ]),
    LegalParagraph(
      'Users should obtain advice from an appropriately qualified health '
      'professional before relying on Nibbles where any of these circumstances '
      "apply or whenever they are uncertain about a child's readiness, health, "
      'development or feeding requirements.',
    ),

    LegalHeading('4. Parent and caregiver responsibility'),
    LegalParagraph(
      "The child's parent, legal guardian or authorised caregiver remains "
      "responsible for all decisions relating to the child's feeding and care.",
    ),
    LegalParagraph(
      'This includes deciding whether particular foods, ingredients, recipes, '
      'portions, textures, preparation methods, cooking methods, serving '
      'methods or feeding approaches are appropriate for the child.',
    ),
    LegalParagraph('Users are responsible for:'),
    LegalBullets([
      'Checking all ingredients and allergen information.',
      "Considering the child's known and suspected allergies.",
      'Ensuring food is fresh and safe to consume.',
      'Preparing, cooking and storing food safely.',
      'Checking serving temperatures.',
      "Modifying foods for the child's age and developmental abilities.",
      'Providing suitable seating and positioning.',
      'Actively supervising the child while eating.',
      'Obtaining professional advice when required.',
    ]),
    LegalParagraph(
      'Users should not rely on Nibbles as the sole basis for making decisions '
      "concerning a child's health, nutrition, development or safety.",
    ),

    LegalHeading('5. Readiness for solid foods'),
    LegalParagraph(
      'Any readiness checklist, questionnaire, score, recommendation or result '
      'provided through Nibbles is a general educational tool only.',
    ),
    LegalParagraph(
      'It is not a medical or developmental assessment and cannot confirm that '
      'a child is medically, physically or developmentally ready to begin '
      'solid foods.',
    ),
    LegalParagraph(
      'A checklist result does not guarantee that starting solid foods is '
      'appropriate or safe for an individual child.',
    ),
    LegalParagraph(
      "Users remain responsible for considering the child's age, development, "
      'health and individual circumstances and for seeking qualified '
      'professional advice where appropriate.',
    ),

    LegalHeading('6. Choking and gagging'),
    LegalParagraph(
      'Eating involves inherent risks, including gagging, choking, aspiration '
      'and injury.',
    ),
    LegalParagraph(
      'Nibbles cannot eliminate these risks and does not guarantee that any '
      'food, recipe, texture, shape, preparation method or serving suggestion '
      'will be safe for every child.',
    ),
    LegalParagraph(
      'A responsible adult must actively supervise the child whenever the '
      'child is eating.',
    ),
    LegalParagraph('Users are responsible for ensuring that:'),
    LegalBullets([
      'The child is positioned appropriately.',
      "Food is prepared for the child's age and developmental abilities.",
      'The child is not left unattended while eating.',
      'Appropriate choking first-aid knowledge is obtained from a qualified provider.',
      'Emergency assistance is sought immediately when required.',
    ]),
    LegalParagraph(
      'Information provided by Nibbles should not be treated as a substitute '
      'for accredited first-aid training.',
    ),

    LegalHeading('7. Food allergies'),
    LegalParagraph(
      'Introducing foods may cause an allergic reaction, including a '
      'potentially severe allergic reaction.',
    ),
    LegalParagraph(
      'Users are responsible for checking ingredients, labels and allergen '
      'information before offering any food to a child.',
    ),
    LegalParagraph(
      'Ingredient and allergen information may change, particularly for '
      'packaged or third-party products. Users must check the current '
      'packaging and manufacturer information each time a product is used.',
    ),
    LegalParagraph(
      'Users should obtain individual professional advice before introducing '
      'foods where a child has a known or suspected allergy, eczema, previous '
      'reaction or other relevant medical history.',
    ),

    LegalHeading('8. Food preparation and food safety'),
    LegalParagraph(
      'Users are responsible for following appropriate hygiene, food handling, '
      'cooking, cooling, refrigeration, freezing, defrosting, reheating and '
      'storage practices.',
    ),
    LegalParagraph(
      'Nibbles does not guarantee that a recipe will be safe where ingredients '
      'have been substituted, incorrectly measured, inadequately cooked, '
      'improperly stored or prepared using equipment or conditions different '
      'from those described.',
    ),
    LegalParagraph(
      'Users must discard food where they are uncertain about its freshness, '
      'storage history or safety.',
    ),

    LegalHeading('9. Recipes and nutritional information'),
    LegalParagraph(
      'Recipes, serving suggestions and meal ideas are general guides only.',
    ),
    LegalParagraph(
      'Ingredient sizes, cooking times, appliance performance and results may '
      'vary. Users should ensure that food is thoroughly and safely cooked '
      'before serving it to a child.',
    ),
    LegalParagraph(
      'Any nutritional values, iron values, serving sizes, dietary '
      'classifications or other calculations displayed through Nibbles are '
      'estimates only.',
    ),
    LegalParagraph(
      'Actual values may vary depending on the ingredients, brands, quantities, '
      'substitutions, preparation methods, cooking methods and serving sizes '
      'used.',
    ),
    LegalParagraph(
      'Nibbles does not guarantee that any recipe or meal will meet a '
      "child's complete nutritional requirements or produce any particular "
      'health, growth or developmental outcome.',
    ),

    LegalHeading('10. Emergency situations'),
    LegalParagraph(
      'Nibbles is not an emergency service and must not be used to diagnose, '
      'manage or respond to a medical emergency.',
    ),
    LegalParagraph(
      'Users must not delay seeking professional or emergency assistance '
      'because of information provided through Nibbles.',
    ),
    LegalParagraph(
      'If a child has difficulty breathing, becomes unresponsive, appears to '
      'be choking, experiences a suspected severe allergic reaction or displays '
      'other signs of a medical emergency, contact local emergency services '
      'immediately.',
    ),

    LegalHeading('11. Accuracy and currency of information'),
    LegalParagraph(
      'First Nibbles Pty Ltd takes reasonable steps to provide useful and '
      'accurate educational information.',
    ),
    LegalParagraph(
      'However, health, nutrition, feeding and safety guidance may change over '
      'time, and individual circumstances vary.',
    ),
    LegalParagraph(
      'To the maximum extent permitted by law, First Nibbles Pty Ltd does not '
      'guarantee that all information will always be complete, accurate, '
      'current, error-free or suitable for every child or circumstance.',
    ),
    LegalParagraph(
      'Users should confirm important health and safety information with an '
      'appropriately qualified professional.',
    ),

    LegalHeading('12. Third-party content and products'),
    LegalParagraph(
      'Nibbles may refer to third-party products, brands, websites, resources '
      'or services.',
    ),
    LegalParagraph(
      'Unless expressly stated otherwise, these references do not constitute a '
      'guarantee, endorsement or representation that the product or service is '
      'safe, suitable or appropriate for an individual child.',
    ),
    LegalParagraph(
      'First Nibbles Pty Ltd does not control third-party content, '
      'manufacturing processes, ingredients, labelling or product changes.',
    ),
    LegalParagraph(
      'Users remain responsible for independently checking the suitability and '
      'safety of any third-party product or service.',
    ),

    LegalHeading('13. No guaranteed outcomes'),
    LegalParagraph(
      'First Nibbles Pty Ltd does not guarantee that using Nibbles will:',
    ),
    LegalBullets([
      'Prevent choking or allergic reactions.',
      'Prevent feeding difficulties or selective eating.',
      "Improve a child's health, growth or development.",
      'Result in a child accepting particular foods.',
      "Meet all of a child's nutritional requirements.",
      'Produce any particular feeding or health outcome.',
    ]),
    LegalParagraph('Results will vary between children and families.'),

    LegalHeading('14. Limitation of liability'),
    LegalParagraph(
      'To the maximum extent permitted by law, First Nibbles Pty Ltd and its '
      'directors, officers, employees, contractors and contributors exclude '
      'liability for loss, damage, injury, cost or expense arising from or '
      'relating to:',
    ),
    LegalBullets([
      'The use of or reliance on information provided through Nibbles.',
      "A user's food selection, preparation, storage or serving decisions.",
      "A user's failure to supervise a child appropriately.",
      "A child's allergy, intolerance, gagging, choking or other adverse reaction.",
      'Inaccurate or incomplete information entered by a user.',
      'The use of third-party products, services, links or information.',
      'The temporary unavailability, interruption or malfunction of Nibbles.',
    ]),
    LegalParagraph(
      'Where liability cannot legally be excluded, First Nibbles Pty Ltd '
      'limits its liability to the maximum extent permitted by applicable law.',
    ),

    LegalHeading('15. Non-excludable consumer rights'),
    LegalParagraph(
      'Nothing in this Medical and Safety Disclaimer or the Terms of Use '
      'excludes, restricts or modifies any consumer guarantee, right, remedy '
      'or other protection provided by the Australian Consumer Law or any '
      'other applicable law that cannot legally be excluded, restricted or '
      'modified.',
    ),

    LegalHeading('16. Professional advice'),
    LegalParagraph(
      'Users should contact an appropriately qualified health professional '
      "where they have questions or concerns about a child's:",
    ),
    LegalBullets([
      'Readiness to begin solid foods.',
      'Growth or weight.',
      'Food intake or nutritional requirements.',
      'Allergies or suspected reactions.',
      'Chewing or swallowing.',
      'Gagging or choking.',
      'Development.',
      'Medical conditions.',
      'Feeding behaviour.',
      'Special dietary requirements.',
    ]),
  ],
);

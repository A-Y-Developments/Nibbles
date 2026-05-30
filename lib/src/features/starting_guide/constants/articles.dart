import 'package:flutter/foundation.dart';

/// Static content model for the Starting Guide.
///
/// Articles are hardcoded. The hub renders one card per [GuideArticle];
/// tapping a card opens the article screen routed by [slug].
@immutable
class GuideArticle {
  const GuideArticle({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.terminalCta,
  });

  final String slug;
  final String title;
  final String subtitle;
  final List<GuideSection> sections;
  final GuideCta? terminalCta;
}

/// A numbered (or unnumbered) content block inside an article.
///
/// [stepNumber] is rendered as a leading pill (e.g. '1', '2'). When null the
/// section renders as a plain heading + body (used for intros/outros).
@immutable
class GuideSection {
  const GuideSection({
    required this.heading,
    required this.body,
    this.stepNumber,
  });

  final int? stepNumber;
  final String heading;
  final String body;
}

/// Terminal action at the bottom of an article. [routeName] is one of the
/// `AppRoute.<route>.name` literals — the article screen routes via
/// `context.goNamed(routeName)` so the bottom-nav shell is restored.
@immutable
class GuideCta {
  const GuideCta({required this.label, required this.routeName});

  final String label;
  final String routeName;
}

/// Hardcoded Starting Guide articles. Copy is a placeholder approximation of
/// the Figma frames (the live Figma was unreachable at build time — content
/// fidelity is a follow-up).
const List<GuideArticle> kStartingGuideArticles = [
  GuideArticle(
    slug: 'first-nibbles',
    title: "Baby's First Nibbles",
    subtitle: 'A gentle introduction to your baby starting solid foods.',
    sections: [
      GuideSection(
        stepNumber: 1,
        heading: 'Start with single ingredients',
        body: 'Offer one new food at a time so you can spot reactions early. '
            'Mashed avocado, soft banana, or oatmeal are gentle first picks.',
      ),
      GuideSection(
        stepNumber: 2,
        heading: 'Keep portions tiny',
        body: 'A teaspoon is plenty for a first taste. Babies learn the '
            'mechanics of eating before they learn to eat for fuel.',
      ),
      GuideSection(
        stepNumber: 3,
        heading: 'Follow their lead',
        body: 'A turned head or pressed lips means done. Never force a bite — '
            'mealtimes should feel calm, curious, and unhurried.',
      ),
      GuideSection(
        stepNumber: 4,
        heading: 'Make it a daily ritual',
        body: 'Aim for one consistent solid meal a day to start. Routine helps '
            'your baby (and you) build confidence around the table.',
      ),
    ],
    terminalCta: GuideCta(
      label: 'Explore Recipes',
      routeName: 'recipe-library',
    ),
  ),
  GuideArticle(
    slug: 'introduction',
    title: 'Introduction to Solids',
    subtitle: 'How to plan your first weeks of solid food meals.',
    sections: [
      GuideSection(
        stepNumber: 1,
        heading: 'Pick a calm time of day',
        body: 'Mid-morning often works best — baby is alert but not overtired. '
            'Avoid the witching-hour fussiness window.',
      ),
      GuideSection(
        stepNumber: 2,
        heading: 'Plan three soft foods to rotate',
        body: 'Two veg and one fruit purée, or a simple grain, give variety '
            'without overwhelming a new eater.',
      ),
      GuideSection(
        stepNumber: 3,
        heading: 'Pair with a familiar bottle or feed',
        body: 'Milk feeds stay primary in the first months of solids. Offer '
            'milk before or after a meal, not as a reward.',
      ),
      GuideSection(
        stepNumber: 4,
        heading: 'Track tastes in the app',
        body: 'Logging reactions helps you spot favourites — and gives you a '
            'record if you ever need to share notes with your pediatrician.',
      ),
    ],
    terminalCta: GuideCta(
      label: 'Create First Meal',
      routeName: 'meal-plan',
    ),
  ),
  GuideArticle(
    slug: 'feeding-principles',
    title: 'Feeding Principles',
    subtitle: 'The simple rules that make mealtimes work for both of you.',
    sections: [
      GuideSection(
        stepNumber: 1,
        heading: 'You decide what, when, and where',
        body: 'Your baby decides whether and how much. This split keeps power '
            'struggles out of the high chair.',
      ),
      GuideSection(
        stepNumber: 2,
        heading: 'Expose, do not pressure',
        body: 'It can take ten or more tries before a new food is accepted. '
            'Keep offering without commentary.',
      ),
      GuideSection(
        stepNumber: 3,
        heading: 'Eat together when you can',
        body: 'Babies learn to chew, swallow, and enjoy food by watching you. '
            'Share even a small bite of what they are having.',
      ),
      GuideSection(
        stepNumber: 4,
        heading: 'Stay flat and supported',
        body: 'Upright posture with feet supported makes safe swallowing '
            'easier. A wobbly seat = a stressful meal.',
      ),
      GuideSection(
        stepNumber: 5,
        heading: 'Introduce allergens early and often',
        body: 'Current guidance is to introduce common allergens between '
            '4-6 months, then keep them in the rotation regularly.',
      ),
    ],
    terminalCta: GuideCta(
      label: 'Start Introducing Allergens',
      routeName: 'allergen-tracker',
    ),
  ),
  GuideArticle(
    slug: 'readiness-signs',
    title: '5 Signs of Readiness',
    subtitle: 'How to know your baby is ready to start solids.',
    sections: [
      GuideSection(
        stepNumber: 1,
        heading: 'Sits with little help',
        body: 'Your baby can hold their head steady and sit upright in a high '
            'chair with minimal support.',
      ),
      GuideSection(
        stepNumber: 2,
        heading: 'Has lost the tongue-thrust reflex',
        body: 'When you offer a spoon, food goes back instead of being pushed '
            'straight out by the tongue.',
      ),
      GuideSection(
        stepNumber: 3,
        heading: 'Shows interest in food',
        body: 'Watches you eat, opens their mouth toward your spoon, or '
            'reaches for what is on your plate.',
      ),
      GuideSection(
        stepNumber: 4,
        heading: 'Can bring objects to mouth',
        body: 'Grabbing a toy and getting it to their mouth signals the '
            'hand-eye coordination needed for self-feeding.',
      ),
      GuideSection(
        stepNumber: 5,
        heading: 'Is around 6 months old',
        body: 'Most babies are ready around six months. Always check with '
            'your pediatrician before introducing solids.',
      ),
    ],
    // TODO(NIB-94): wire a real mailto / weekly recipe sign-up flow once
    //  copywriting + ESP integration land. For now, pop back to the hub.
    terminalCta: GuideCta(
      label: 'Get Free Weekly Baby Recipes',
      routeName: 'starting-guide',
    ),
  ),
];

/// Returns the article whose [GuideArticle.slug] equals [slug], or `null`.
GuideArticle? findArticleBySlug(String slug) {
  for (final article in kStartingGuideArticles) {
    if (article.slug == slug) return article;
  }
  return null;
}

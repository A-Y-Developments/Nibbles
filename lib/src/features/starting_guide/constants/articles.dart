import 'package:flutter/foundation.dart';

/// Static content model for the Starting Guide.
///
/// Articles are hardcoded. The hub renders one card per [GuideArticle];
/// tapping a card opens the article screen routed by [slug]. Body content is
/// modelled as a sequence of [GuideBlock]s so each article can mix headings,
/// info cards, chip grids, numbered lists, checklists, and inline CTAs while
/// staying typed end-to-end.
///
/// Copy is verbatim from the Figma audit reports
/// (`.figma-audit/recipe-library/recipe-library-*`). Typos surfaced by the
/// audit (e.g. "No Fluf", "We focuses on", "Wallnut", "Babies's kidneys",
/// "Asther readiness result") are preserved on purpose — flagged with PO in
/// the PR body.
@immutable
class GuideArticle {
  const GuideArticle({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.blocks,
  });

  final String slug;

  /// Hub card title.
  final String title;

  /// Hub card subtitle.
  final String subtitle;

  /// Ordered list of body blocks rendered by the article screen.
  final List<GuideBlock> blocks;
}

/// Sealed base for every renderable block inside a [GuideArticle].
@immutable
sealed class GuideBlock {
  const GuideBlock();
}

/// Hero card at the top of an article — title + body sit on a tinted card
/// with a baby-face glyph stand-in for the Figma hero illustration.
class HeroCardBlock extends GuideBlock {
  const HeroCardBlock({required this.title, required this.body});

  final String title;
  final String body;
}

/// Section title (e.g. "The 6 Month Milestone", "Essential Nutrients").
class SectionHeadingBlock extends GuideBlock {
  const SectionHeadingBlock(this.text);

  final String text;
}

/// Free-form paragraph rendered with the body type ramp.
class ParagraphBlock extends GuideBlock {
  const ParagraphBlock(this.text);

  final String text;
}

/// Single salmon-ghost label chip (e.g. "Perfect time to growth", "6+ Months").
class LabelChipBlock extends GuideBlock {
  const LabelChipBlock(this.label);

  final String label;
}

/// Cream tip-style info card — title + body, butter-soft fill, baby-face
/// glyph hero. Used for the "SIMPLE AND PRACTICAL" / "EVIDENCE INFORMED" /
/// "No Fluf" tiles on Baby's First Nibbles.
class InfoCardBlock extends GuideBlock {
  const InfoCardBlock({required this.title, required this.body});

  final String title;
  final String body;
}

/// Grid of small icon tiles (e.g. Iron / Minerals / Vitamins / Zinc; or the
/// 7 iron-rich foods grid on Feeding Principles). Renders as a wrap of
/// rounded tiles with a green-deep baby-face glyph above each label.
class IconTileGridBlock extends GuideBlock {
  const IconTileGridBlock(this.labels);

  final List<String> labels;
}

/// White card titled e.g. "The Big 11" + body + a wrap of salmon-ghost chips.
class ChipGridCardBlock extends GuideBlock {
  const ChipGridCardBlock({
    required this.title,
    required this.body,
    required this.chips,
  });

  final String title;
  final String body;
  final List<String> chips;
}

/// Cream card with a numbered list (1..n) of heading + body rows. Used for
/// "Nibbles Goals" on First Nibbles, "Feeding is Skill-Building" on
/// Introduction, and "Items to Avoid" on Feeding Principles.
class NumberedListCardBlock extends GuideBlock {
  const NumberedListCardBlock({
    required this.title,
    required this.items,
    this.body,
  });

  final String title;
  final String? body;
  final List<NumberedItem> items;
}

@immutable
class NumberedItem {
  const NumberedItem({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// "Our Philosophy" style card — white card, baby glyph, title, body, trailing
/// label chips.
class PhilosophyCardBlock extends GuideBlock {
  const PhilosophyCardBlock({
    required this.title,
    required this.body,
    required this.chips,
  });

  final String title;
  final String body;
  final List<String> chips;
}

/// "Ready to Start?" style closing card — white card with title, body, and a
/// single primary CTA pinned inside it.
class ReadyToStartCardBlock extends GuideBlock {
  const ReadyToStartCardBlock({
    required this.title,
    required this.body,
    required this.cta,
  });

  final String title;
  final String body;
  final GuideCta cta;
}

/// Pair of inline CTAs (primary + optional secondary) rendered mid-article.
/// Used after the numbered Nibbles Goals / Feeding-Skill-Building lists.
class InlineCtaPairBlock extends GuideBlock {
  const InlineCtaPairBlock({required this.primary, this.secondary});

  final GuideCta primary;
  final GuideCta? secondary;
}

/// Checklist card (lime fill) — title + score pill (e.g. "3/5") + check rows.
class ChecklistCardBlock extends GuideBlock {
  const ChecklistCardBlock({
    required this.title,
    required this.score,
    required this.items,
  });

  final String title;
  final String score;
  final List<String> items;
}

/// CTA leaf. [routeName] is one of the `AppRoute.<route>.name` literals —
/// the article screen routes via `context.goNamed(routeName)` so the bottom
/// nav shell is restored. [variant] picks the pill style.
@immutable
class GuideCta {
  const GuideCta({
    required this.label,
    required this.routeName,
    this.variant = GuideCtaVariant.primary,
  });

  final String label;
  final String routeName;
  final GuideCtaVariant variant;
}

enum GuideCtaVariant { primary, secondary }

/// Hardcoded Starting Guide articles. Copy is verbatim from the Figma audit
/// reports (`.figma-audit/recipe-library/recipe-library-*`). Typos preserved
/// on purpose — PO-flagged in the PR body.
const List<GuideArticle> kStartingGuideArticles = [
  // ── Baby's First Nibbles (Figma 971:8730) ────────────────────────────────
  GuideArticle(
    slug: 'first-nibbles',
    title: 'BABY’S FIRST NIBBLES',
    subtitle:
        'What would I have wanted in my hands when I started this journey?',
    blocks: [
      HeroCardBlock(
        title: 'BABY’S FIRST NIBBLES',
        body: 'What would I have wanted in my hands when I started this '
            'journey?',
      ),
      ParagraphBlock(
        'Baby’s First Nibbles is designed to be simple, practical, '
        'evidence-informed, and realistic for busy parents.',
      ),
      SectionHeadingBlock('We focuses on'),
      InfoCardBlock(
        title: 'SIMPLE AND PRACTICAL',
        body:
            'Designed for busy parents with realistic recipes and actionable '
            'steps.',
      ),
      InfoCardBlock(
        title: 'EVIDENCE INFORMED',
        body: 'Based on current pediatric nutrition guidelines.',
      ),
      InfoCardBlock(
        title: 'No Fluf',
        body: 'No overcomplication. Just food that makes sense for you.',
      ),
      SectionHeadingBlock('Nibbles Goals'),
      NumberedListCardBlock(
        title: 'Nibbles Goals',
        items: [
          NumberedItem(
            heading: 'Help parents feel confident, not overwhelmed',
            body: '',
          ),
          NumberedItem(
            heading: 'To help your baby explore food',
            body: '',
          ),
          NumberedItem(
            heading: 'Develop feeding skills',
            body: '',
          ),
          NumberedItem(
            heading: 'Build a strong foundation for lifelong health',
            body: '',
          ),
        ],
      ),
      InlineCtaPairBlock(
        primary: GuideCta(
          label: 'Explore Recipes',
          routeName: 'recipe-library',
        ),
        secondary: GuideCta(
          label: 'Get Free Weekly Baby Recipes',
          routeName: 'starting-guide',
          variant: GuideCtaVariant.secondary,
        ),
      ),
    ],
  ),
  // ── Introduction (Figma 971:8744) ────────────────────────────────────────
  GuideArticle(
    slug: 'introduction',
    title: 'Introductions',
    subtitle:
        'Introducing solids is a major milestone in a baby’s development',
    blocks: [
      HeroCardBlock(
        title: 'Introducing Solids',
        body: 'Introducing solids is a major milestone in a baby’s '
            'development',
      ),
      SectionHeadingBlock('The 6 Month Milestone'),
      LabelChipBlock('Perfect time to growth'),
      ParagraphBlock(
        'Babies begin transitioning from an exclusively milk-based diet to a '
        'combination of breast milk or formula and complementary foods.',
      ),
      SectionHeadingBlock('Essential Nutrients'),
      IconTileGridBlock(['Iron', 'Minerals', 'Vitamins', 'Zinc']),
      NumberedListCardBlock(
        title: 'Feeding is Skill-Building',
        body: 'Beyond nutrients, every meal is a sensory workout for your '
            'little one.',
        items: [
          NumberedItem(
            heading: 'Developing Coordination',
            body: 'Hand-to-mouth movements and tongue control.',
          ),
          NumberedItem(
            heading: 'Exploring Textures',
            body: 'Learning to manipulate different mouthfeels.',
          ),
          NumberedItem(
            heading: 'Learning to Eat',
            body: 'Transitioning from sucking to chewing and swallowing.',
          ),
        ],
      ),
      InlineCtaPairBlock(
        primary: GuideCta(
          label: 'Explore Recipes',
          routeName: 'recipe-library',
        ),
        secondary: GuideCta(
          label: 'Get Free Weekly Baby Recipes',
          routeName: 'starting-guide',
          variant: GuideCtaVariant.secondary,
        ),
      ),
      PhilosophyCardBlock(
        title: 'Our Philosophy',
        body: 'Simple, nutrient-dense meals that support both nutrition and '
            'development, without overcomplicating the process.',
        chips: ['Nurturing', 'Nurturing', 'Simple'],
      ),
      ReadyToStartCardBlock(
        title: 'Ready to Start?',
        body:
            'Breast milk or formula remains primary, but let’s explore '
            'those first bites together.',
        cta: GuideCta(
          label: 'Create First Meal',
          routeName: 'meal-plan',
        ),
      ),
    ],
  ),
  // ── 5 Sign Readiness (Figma 1474:50031) ──────────────────────────────────
  GuideArticle(
    slug: 'readiness-signs',
    title: 'Signs Your Baby Is Ready for Solids',
    subtitle: 'Every baby develops at their own pace, so these signs are '
        'generally more important than the calendar.',
    blocks: [
      HeroCardBlock(
        title: '5 Sign Readiness',
        body: 'Every baby develops at their own pace, so these signs are '
            'generally more important than the calendar.',
      ),
      SectionHeadingBlock('Asther readiness result'),
      ParagraphBlock(
        'Most babies are ready at around six months, but these developmental '
        'signs are the most important indicators.',
      ),
      ChecklistCardBlock(
        title: 'Readiness Signs',
        score: '3/5',
        items: [
          // Long copy kept on a single line per item so the literals are
          // const (required by the outer `const List` constructor) and the
          // `no_adjacent_strings_in_list` lint stays happy.
          // ignore: lines_longer_than_80_chars
          'Can sit upright with minimal support. Good head and neck control (can hold head steady)',
          'Sits upright with minimal support',
          // See the comment above the first item — same reason.
          // ignore: lines_longer_than_80_chars
          'Loss of the tongue-thrust reflex (doesn’t automatically push food out).',
          'Shows interest in food (watching, reaching, opening mouth).',
          'Can bring objects to their mouth.',
        ],
      ),
    ],
  ),
  // ── Feeding Principles (Figma 1474:50514) ────────────────────────────────
  GuideArticle(
    slug: 'feeding-principles',
    title: 'Important Feeding Principles',
    subtitle:
        'Weaning is more than just calories; it’s a foundation for '
        'lifelong health',
    blocks: [
      HeroCardBlock(
        title: 'Important Feeding Principles',
        body: 'Weaning is more than just calories; it’s a foundation '
            'for lifelong health',
      ),
      SectionHeadingBlock('Iron-Rich Essentials'),
      LabelChipBlock('6+ Months'),
      ParagraphBlock(
        'Baby’s iron needs increase significantly at 6 months. Example '
        'iron-rich foods :',
      ),
      IconTileGridBlock([
        'Beef',
        'Lamb',
        'Chicken',
        'Fish',
        'Eggs',
        'Lentils',
        'Tofu',
      ]),
      SectionHeadingBlock('Common Allergen'),
      ChipGridCardBlock(
        title: 'The Big 11',
        body: 'Introduce early and often within the first year.',
        chips: [
          'Almond',
          'Cashew',
          'Egg',
          'Wheat',
          'Fish',
          'Peanut',
          'Milk',
          'Prawn',
          'Wallnut',
          'Soy',
          'Sesame',
        ],
      ),
      SectionHeadingBlock('Offering a Variety of Foods'),
      ParagraphBlock(
        'Repeated exposure to a wide range of foods can help babies develop '
        'acceptance of different flavours and textures. It is normal for '
        'babies to need several exposures to a new food before accepting it.',
      ),
      SectionHeadingBlock('Items to Avoid'),
      NumberedListCardBlock(
        title: 'Items to Avoid',
        items: [
          NumberedItem(
            heading: 'No Added Salt or Sugar',
            body: 'Foods prepared for infants should not contain added salt '
                'or sugar. Babies’s kidneys are still developing, and '
                'limiting salt intake is recommended.',
          ),
          NumberedItem(
            heading: 'Avoid Honey Before 12 Months',
            body: 'Honey should not be given to infants under 12 months of '
                'age due to the risk of infant botulism.',
          ),
        ],
      ),
      ReadyToStartCardBlock(
        title: 'Ready to Start Introduce Allergens?',
        body: 'Introduce allergens with confidence using simple guidance and '
            'easy tracking.',
        cta: GuideCta(
          label: 'Start Introducing Allergens',
          routeName: 'allergen-tracker',
        ),
      ),
    ],
  ),
];

/// Returns the article whose [GuideArticle.slug] equals [slug], or `null`.
GuideArticle? findArticleBySlug(String slug) {
  for (final article in kStartingGuideArticles) {
    if (article.slug == slug) return article;
  }
  return null;
}

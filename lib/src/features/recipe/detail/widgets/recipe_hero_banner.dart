import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/recipe_banner_card.dart';

/// Hero image with the [RecipeBannerCard] overlapping its bottom edge.
/// Image is full-bleed; the card is inset and pulled up so it stacks on
/// the lower portion of the photo. Figma nodes 971:9618 + 1129:13972.
class RecipeHeroBanner extends StatelessWidget {
  const RecipeHeroBanner({
    required this.imageUrl,
    required this.title,
    required this.ageRange,
    required this.nutritionTags,
    this.makes,
    super.key,
  });

  final String? imageUrl;
  final String title;
  final String ageRange;
  final List<String> nutritionTags;
  final String? makes;

  static const double _imageHeight = 210;
  static const double _overlap = 52;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: _imageHeight,
            width: double.infinity,
            child: _HeroImage(imageUrl: imageUrl),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: _imageHeight - _overlap,
            left: AppSizes.md,
            right: AppSizes.md,
          ),
          child: RecipeBannerCard(
            title: title,
            ageRange: ageRange,
            nutritionTags: nutritionTags,
            makes: makes,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _fallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() =>
      Assets.images.recipe.mockRecipe.image(fit: BoxFit.cover);
}

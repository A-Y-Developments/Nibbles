import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Full-bleed hero image used at the top of the recipe detail screen.
///
/// Renders [imageUrl] edge-to-edge with a 16:9 ratio and a soft butter-tint
/// fallback when the image is null or fails to load. The recipe banner card
/// sits below this in the parent layout.
class RecipeHero extends StatelessWidget {
  const RecipeHero({required this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: imageUrl == null || imageUrl!.isEmpty
          ? const _Fallback()
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _Fallback(),
              errorWidget: (_, __, ___) => const _Fallback(),
            ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.butterSoft,
      child: Center(
        child: Icon(
          Icons.restaurant_outlined,
          size: AppSizes.iconXl,
          color: AppColors.coralDeep,
        ),
      ),
    );
  }
}

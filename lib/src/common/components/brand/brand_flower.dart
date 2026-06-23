import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';

/// Brand flower illustration — the soft butter blossom used on the onboarding
/// consent screen. Single source of truth so every empty-state and
/// confirmation illustration across the app renders the same flower.
class BrandFlower extends StatelessWidget {
  const BrandFlower({this.size = 96, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      Assets.images.onboarding.consentFlower.svg(width: size, height: size);
}

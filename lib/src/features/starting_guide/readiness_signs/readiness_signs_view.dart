import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/onboarding/readiness/readiness_signs.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_section_heading.dart';

/// Figma cards on the guide use a 12px corner radius (no exact token).
const double _cardRadius = 12;

/// Figma readiness hero "Group 78" baby icon is 154×154; it punches through the
/// top edge of the signs card.
const double _heroSize = 154;

/// Bespoke 5 Sign Readiness article (Figma 1474:50031). Rendered in place of
/// the generic block renderer for the `readiness-signs` slug. Wrapped by the
/// caller's [GradientScaffold]; this widget owns the header + scrolling body.
///
/// Mirrors the onboarding readiness RESULT layout (baby-icon hero over a signs
/// card, score chip, per-sign check/cross) but in cream colors with the cream
/// baby icon. The score + checks reflect the baby's persisted readiness signs
/// ([Baby.readinessSigns] — index 0 = pediatrician gate, 1-5 = signs); a baby
/// with no captured answers reads 0/6.
class ReadinessSignsView extends ConsumerWidget {
  const ReadinessSignsView({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(currentBabyProvider).valueOrNull;

    // Ordering matches [kReadinessSignLabels] and the onboarding result.
    final signs = baby?.readinessSigns ?? const <bool>[];
    final signsMet = signs.where((a) => a).length;
    final firstName = _firstToken(baby?.name);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(onBack: onBack)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _BannerCard(),
                const SizedBox(height: AppSizes.lg),
                GuideSectionHeading('$firstName readiness result'),
                const SizedBox(height: AppSizes.sp12),
                Text(
                  'Most babies are ready at around six months, but these '
                  'developmental signs are the most important indicators.',
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                _SignsCard(signsMet: signsMet, signs: signs),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// First whitespace-separated token of the baby name, or "Your baby" when no
  /// baby/name is available. Mirrors the onboarding result copy.
  String _firstToken(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return 'Your baby';
    final idx = trimmed.indexOf(' ');
    return idx < 0 ? trimmed : trimmed.substring(0, idx);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            AppRoundButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tone: AppRoundButtonTone.ghost,
              size: AppRoundButtonSize.small,
              semanticLabel: 'Back',
              onPressed: onBack,
            ),
            const SizedBox(width: AppSizes.xs),
            Expanded(
              child: Text(
                '5 Sign Readiness',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.fgStrong,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed intro banner — the asset already bakes in the title, body, blob
/// and food composition (Figma 1474:51274), so render it as one image.
class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardRadius),
      child: Assets.images.guide.readinessBanner.image(
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

/// Cream signs card with the cream baby icon punching through its top edge,
/// a burgundy score chip, and the six readiness sign rows. Mirrors the
/// onboarding result `_HeroCard`/`_SignsCard` layering in cream.
class _SignsCard extends StatelessWidget {
  const _SignsCard({required this.signsMet, required this.signs});

  final int signsMet;
  final List<bool> signs;

  @override
  Widget build(BuildContext context) {
    // Overlap = half the hero so the lower hemisphere sits inside the card.
    const overlap = _heroSize / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: overlap),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(AppSizes.radius2xl),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                // Clear only the hero's lower chin so the header sits close
                // under the baby icon — Figma's tight hero/header gap.
                AppSizes.lg + (_heroSize * 0.30),
                AppSizes.lg,
                AppSizes.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Readiness Signs',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.fgDefault,
                          ),
                        ),
                      ),
                      _ScoreChip(signsMet: signsMet),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  for (var i = 0; i < kReadinessSignLabels.length; i++) ...[
                    _SignRow(
                      positive: i < signs.length && signs[i],
                      label: kReadinessSignLabels[i],
                    ),
                    if (i < kReadinessSignLabels.length - 1)
                      const SizedBox(height: AppSizes.md),
                  ],
                ],
              ),
            ),
          ),
        ),
        Assets.images.guide.babyIconCream.svg(
          width: _heroSize,
          height: _heroSize,
        ),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.signsMet});

  final int signsMet;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.burgundyDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Text(
          '$signsMet/${kReadinessSignLabels.length}',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.cream,
          ),
        ),
      ),
    );
  }
}

class _SignRow extends StatelessWidget {
  const _SignRow({required this.positive, required this.label});

  final bool positive;
  final String label;

  @override
  Widget build(BuildContext context) {
    final glyph = positive ? Icons.check_circle_outline : Icons.cancel_outlined;
    return Semantics(
      container: true,
      label: '${positive ? 'Met' : 'Not met'}: $label',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              glyph,
              size: AppSizes.iconMd,
              color: positive ? AppColors.greenDeep : AppColors.fgFaint,
            ),
            const SizedBox(width: AppSizes.sp12),
            Expanded(
              child: Padding(
                // Nudge label down to visually center against the icon.
                padding: const EdgeInsets.only(top: AppSizes.sp2),
                child: Text(
                  label,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgDefault,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

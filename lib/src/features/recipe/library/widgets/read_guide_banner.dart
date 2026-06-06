import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';

/// First-launch 'New to Starting Solids?' banner for the Recipe Library
/// (Figma 971:8644 → 1015:6820). Forest-green card with white title, white
/// 10/Regular supporting copy, and a full-width white-outlined 'Read Guide'
/// CTA.
///
/// Visibility is gated upstream by `LocalFlagService.isStartingGuideSeen()`;
/// the banner itself is a pure presentation widget — tapping the CTA fires
/// [onTap] and the caller is responsible for marking the flag and routing
/// to the Starting Guide.
class ReadGuideBanner extends StatelessWidget {
  const ReadGuideBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  // Token mapping for the Figma 'Banner' container (1015:6820):
  //   bg               -> Nibble-primary-Forest    (#5C7852)
  //   shadow           -> 0 4 10 rgba(92,120,82,0.04)
  //   radius           -> 12
  //   padding          -> 24 vertical / 12 horizontal
  //   inner column gap -> 12

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(AppSizes.sp12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A5C7852),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.sp12),
        child: Stack(
          children: [
            // Decorative brand quatrefoil blobs (Figma 1015:6820) — lighter
            // sage shapes clustered at the banner's top-right, clipped.
            const Positioned(
              top: -30,
              right: -22,
              child: Quatrefoil(
                size: 104,
                petalColor: AppColors.greenSoft,
                coreColor: AppColors.greenSoft,
              ),
            ),
            const Positioned(
              top: 26,
              right: -44,
              child: Quatrefoil(
                size: 76,
                petalColor: AppColors.greenSoft,
                coreColor: AppColors.greenSoft,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sp12,
                vertical: AppSizes.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'New to Starting Solids?',
                    style: _bannerTitleStyle,
                  ),
                  const SizedBox(height: AppSizes.sp12),
                  Text(
                    'Start your baby’s food journey the right way with simple '
                    'basics.',
                    style: _bannerBodyStyle,
                  ),
                  const SizedBox(height: AppSizes.sp12),
                  _ReadGuideCta(onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Figma Headline/SemiBold — Parkinsans SemiBold 15/22 white (1015:6812).
const TextStyle _bannerTitleStyle = TextStyle(
  fontFamily: FontFamily.parkinsans,
  fontSize: 15,
  fontWeight: FontWeight.w600,
  height: 22 / 15,
  color: AppColors.cream,
);

// Figma Caption/Regular — Figtree Regular 10/16 white (1015:6813).
final TextStyle _bannerBodyStyle = GoogleFonts.figtree(
  fontSize: 10,
  fontWeight: FontWeight.w400,
  height: 16 / 10,
  color: AppColors.cream,
);

// Figma button label — Parkinsans SemiBold 15/22 white (I1015:6814;1015:9925).
const TextStyle _ctaLabelStyle = TextStyle(
  fontFamily: FontFamily.parkinsans,
  fontSize: 15,
  fontWeight: FontWeight.w600,
  height: 22 / 15,
  color: AppColors.cream,
);

class _ReadGuideCta extends StatelessWidget {
  const _ReadGuideCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Read Guide',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.radiusMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cream),
              borderRadius: BorderRadius.circular(AppSizes.lg),
            ),
            alignment: Alignment.center,
            child: const Text('Read Guide', style: _ctaLabelStyle),
          ),
        ),
      ),
    );
  }
}

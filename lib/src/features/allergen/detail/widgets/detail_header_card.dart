import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_segment_bar.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_status_pill.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_icon_tile.dart';

/// Burgundy curved hero header on the allergen detail screen (Figma
/// 1116:19762 / 1525:20065 / 1525:20232). Back + title, allergen tile, name,
/// "N/3 times", status pill, First Introduced / Last Given and a 3-segment
/// progress bar — over a soft `allergenBlob` backdrop with a curved bottom.
class AllergenDetailHeader extends StatelessWidget {
  const AllergenDetailHeader({
    required this.name,
    required this.status,
    required this.reactionFlags,
    required this.firstIntroduced,
    required this.lastGiven,
    required this.onBack,
    super.key,
  });

  final String name;
  final AllergenStatus status;

  /// Per-exposure reaction flags, oldest-first — drives "N/3 times" + segments.
  final List<bool> reactionFlags;
  final DateTime? firstIntroduced;
  final DateTime? lastGiven;
  final VoidCallback onBack;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatOrDash(DateTime? d) =>
      d == null ? '-' : '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clamped = reactionFlags.length.clamp(0, 3);
    final cream70 = AppColors.cream.withValues(alpha: 0.7);

    return ClipPath(
      clipper: _HeaderArchClipper(),
      child: Container(
        width: double.infinity,
        color: AppColors.burgundyDark,
        child: Stack(
          children: [
            Positioned(
              right: -50,
              bottom: -20,
              child: Opacity(
                opacity: 0.06,
                child: Assets.images.allergen.allergenBlob.image(
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePaddingH,
                  AppSizes.sm,
                  AppSizes.pagePaddingH,
                  AppSizes.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _BackButton(onBack: onBack),
                        Expanded(
                          child: Text(
                            'Details Allergen',
                            textAlign: TextAlign.center,
                            style: textTheme.titleSmall?.copyWith(
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.roundButton),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        const AllergenIconTile(backing: Colors.white10),
                        const SizedBox(width: AppSizes.sp12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.cream,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSizes.sp2),
                              Text(
                                '$clamped/3 times',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: cream70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        DetailStatusPill(status: status),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _DateColumn(
                            label: 'First Introduced',
                            value: _formatOrDash(firstIntroduced),
                            labelColor: cream70,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: _DateColumn(
                            label: 'Last Given',
                            value: _formatOrDash(lastGiven),
                            labelColor: cream70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    DetailSegmentBar(
                      reactionFlags: reactionFlags,
                      onDark: true,
                    ),
                    const SizedBox(height: AppSizes.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onBack,
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.cream),
      tooltip: 'Back',
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.label,
    required this.value,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: labelColor,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.cream,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const arch = 60.0;
    return Path()
      ..lineTo(0, size.height - arch)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - arch,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_HeaderArchClipper oldClipper) => false;
}

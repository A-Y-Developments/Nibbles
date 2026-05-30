import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Three discrete progress segments (one per clean log, max 3).
///
/// Per spec 7 — filled segments = clean log count. When status == flagged,
/// all segments render in the flagged track tone (visually reset to 0 fill).
class DetailSegmentBar extends StatelessWidget {
  const DetailSegmentBar({
    required this.cleanCount,
    required this.status,
    super.key,
  });

  final int cleanCount;
  final AllergenStatus status;

  bool get _isFlagged => status == AllergenStatus.flagged;

  Color _fillColor() {
    if (_isFlagged) return AppColors.destructiveSoft;
    if (status == AllergenStatus.safe) return AppColors.green;
    return AppColors.coralDeep;
  }

  Color _emptyColor() {
    if (_isFlagged) return AppColors.destructiveSoft;
    return AppColors.coralSoft;
  }

  @override
  Widget build(BuildContext context) {
    final filledCount = _isFlagged ? 0 : cleanCount.clamp(0, 3);
    final fill = _fillColor();
    final empty = _emptyColor();
    return Row(
      children: List<Widget>.generate(3, (i) {
        final isFilled = i < filledCount;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : AppSizes.xs),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: isFilled ? fill : empty,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}

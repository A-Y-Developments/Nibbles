import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Two-column dates block — First Introduced / Last Given.
///
/// Per spec 6 — render two-column block; caller is responsible for hiding
/// when there are 0 logs.
class DetailDatesBlock extends StatelessWidget {
  const DetailDatesBlock({
    required this.firstIntroduced,
    required this.lastGiven,
    super.key,
  });

  final DateTime firstIntroduced;
  final DateTime lastGiven;

  static const _months = <String>[
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

  String _format(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Column(
            label: 'First Introduced',
            value: _format(firstIntroduced),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _Column(label: 'Last Given', value: _format(lastGiven)),
        ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.label, required this.value});

  final String label;
  final String value;

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
            color: AppColors.fgFaint,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.fgStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

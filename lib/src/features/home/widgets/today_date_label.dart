import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// NIB-96: "Today, May 10" date label used above the bottom section of the
/// Home dashboard in every variant.
///
/// In the `populated` variant the date label is rendered by
/// `TodaysMealsCard`; the empty + with-ongoing + no-meals-mapped variants
/// render this standalone widget so the date line is preserved verbatim
/// from Figma.
class TodayDateLabel extends StatelessWidget {
  const TodayDateLabel({this.date, super.key});

  /// Overridable for testing. Defaults to `DateTime.now()`.
  final DateTime? date;

  static const List<String> _shortMonths = [
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

  @override
  Widget build(BuildContext context) {
    final today = date ?? DateTime.now();
    return Text(
      'Today, ${_shortMonths[today.month - 1]} ${today.day}',
      style: AppTypography.sectionTitle,
    );
  }
}

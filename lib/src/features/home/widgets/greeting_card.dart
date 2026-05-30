import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

/// NIB-65 — Exact-age greeting line for the Home dashboard.
///
/// Renders the title2 line `{name} is {ageMonths} months {ageDays} days
/// today! 🎉` when [dateOfBirth] is supplied (preferred path), or the
/// `{name} is {ageMonths} months today! 🎉` fallback when only [ageMonths]
/// is wired (the current NIB-86 call-site).
///
/// [dateOfBirth] is optional so the existing call-site keeps compiling
/// without `home_screen.dart` having to change — the constructor only adds
/// the precise-age path on top of the wired signature.
class GreetingCard extends StatelessWidget {
  const GreetingCard({
    required this.babyName,
    required this.ageMonths,
    this.dateOfBirth,
    super.key,
  });

  final String babyName;
  final int ageMonths;
  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(
        _greeting(DateTime.now()),
        style: AppTypography.textTheme.titleLarge,
      ),
    );
  }

  String _greeting(DateTime now) {
    final dob = dateOfBirth;
    if (dob == null) {
      return '$babyName is $ageMonths months today! 🎉';
    }
    final months = ageInMonths(dob, now: now);
    final days = _daysIntoCurrentMonth(dob, now, months);
    return '$babyName is $months months $days days today! 🎉';
  }

  /// Days elapsed since the most recent month anniversary of [dob].
  /// Mirrors `ageInMonths` semantics so the months + days breakdown is
  /// internally consistent (e.g. dob = Jan 31 / now = Feb 15 → 0 months,
  /// 15 days; dob = Jan 15 / now = Feb 16 → 1 month, 1 day).
  int _daysIntoCurrentMonth(DateTime dob, DateTime now, int months) {
    if (!now.isAfter(dob)) return 0;
    final anniversary = DateTime(dob.year, dob.month + months, dob.day);
    final diff = now.difference(anniversary).inDays;
    return diff < 0 ? 0 : diff;
  }
}

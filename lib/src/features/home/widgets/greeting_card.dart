import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

/// NIB-65 / NIB-77 — Exact-age greeting line for the Home dashboard.
///
/// Renders the title2 line as three styled runs per the Figma audit
/// (home-populated, node 1242:10567):
///   - `"{name} is "` — body color (fgStrong)
///   - `"{ageMonths} months {ageDays} days "` — green-deep accent
///   - `"today!🎉"` — body color (fgStrong)
///
/// When [dateOfBirth] is null we fall back to a months-only middle run
/// (`"{ageMonths} months "`) so the test fixture call-site (which only
/// passes `ageMonths`) keeps compiling and reading naturally.
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
    final now = DateTime.now();
    final dob = dateOfBirth;
    final targetMonths = dob == null ? ageMonths : ageInMonths(dob, now: now);
    final days = dob == null
        ? null
        : _daysIntoCurrentMonth(dob, now, targetMonths);
    final base = AppTypography.textTheme.titleLarge ?? const TextStyle();

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: targetMonths),
      duration: AppDurations.slow,
      curve: AppCurves.emphasized,
      builder: (context, months, _) {
        final accent = days == null
            ? '$months months '
            : '$months months $days days ';
        return AutoSizeText.rich(
          TextSpan(
            style: base.copyWith(color: AppColors.fgStrong),
            children: [
              TextSpan(text: '$babyName is '),
              TextSpan(
                text: accent,
                style: base.copyWith(color: AppColors.greenDeep),
              ),
              // Word joiner (U+2060) glues the emoji to "today!" so it never
              // wraps onto its own line (NIB-172).
              const TextSpan(text: 'today!\u{2060}🎉'),
            ],
          ),
          maxLines: 3,
          minFontSize: 15,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
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

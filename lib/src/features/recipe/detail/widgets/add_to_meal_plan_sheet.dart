import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Shows the multi-day Add-to-Meal-Plan bottom sheet.
///
/// The sheet renders week-by-week accordions over the next 12 weeks (from
/// today). Each day inside a week shows a checkbox row; tapping toggles
/// selection. The header shows a live `X Days Selected` counter and the
/// bottom CTA (`Add to Meal Plan`) stays disabled while no day is picked.
///
/// Returns the set of selected dates on confirm, or `null` on cancel.
Future<Set<DateTime>?> showAddToMealPlanSheet(
  BuildContext context, {
  required String babyId,
}) {
  return showModalBottomSheet<Set<DateTime>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => const _AddToMealPlanSheet(),
  );
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// First Monday on-or-before [date]. Weeks are Monday-anchored.
DateTime _weekStart(DateTime date) {
  final d = _dateOnly(date);
  // DateTime.weekday: Monday == 1, Sunday == 7.
  return d.subtract(Duration(days: d.weekday - 1));
}

/// Number of accordion weeks shown (12 weeks ≈ 3 months ahead).
const int _kWeekCount = 12;

class _AddToMealPlanSheet extends StatefulWidget {
  const _AddToMealPlanSheet();

  @override
  State<_AddToMealPlanSheet> createState() => _AddToMealPlanSheetState();
}

class _AddToMealPlanSheetState extends State<_AddToMealPlanSheet> {
  final Set<DateTime> _selected = <DateTime>{};
  late final DateTime _today;
  late final DateTime _firstWeekStart;
  late final List<DateTime> _weekStarts;
  late int _expandedWeekIndex;

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _firstWeekStart = _weekStart(_today);
    _weekStarts = List<DateTime>.generate(
      _kWeekCount,
      (i) => _firstWeekStart.add(Duration(days: 7 * i)),
    );
    // Default-expand the current week.
    _expandedWeekIndex = 0;
  }

  void _toggleDay(DateTime day) {
    final normalized = _dateOnly(day);
    setState(() {
      if (_selected.contains(normalized)) {
        _selected.remove(normalized);
      } else {
        _selected.add(normalized);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final count = _selected.length;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            _SheetGrabber(),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              child: _SheetHeader(selectedCount: count),
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(height: 1, color: AppColors.borderSoft),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                  vertical: AppSizes.sm,
                ),
                itemCount: _weekStarts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.sm),
                itemBuilder: (context, weekIndex) {
                  final weekStart = _weekStarts[weekIndex];
                  return _WeekAccordion(
                    weekStart: weekStart,
                    today: _today,
                    selected: _selected,
                    expanded: _expandedWeekIndex == weekIndex,
                    onHeaderTap: () => setState(() {
                      _expandedWeekIndex =
                          _expandedWeekIndex == weekIndex ? -1 : weekIndex;
                    }),
                    onDayTap: _toggleDay,
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSoft),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.sp12,
                AppSizes.pagePaddingH,
                AppSizes.sp12,
              ),
              child: AppPillButton(
                label: 'Add to Meal Plan',
                onPressed: count == 0
                    ? null
                    : () => Navigator.of(context).pop(_selected),
                leading: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Meal Plan',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.fgDefault,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                '$selectedCount ${selectedCount == 1 ? 'Day' : 'Days'} '
                'Selected',
                style: AppTypography.caption.copyWith(
                  color: selectedCount == 0
                      ? AppColors.fgMuted
                      : AppColors.greenDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: AppSizes.iconMd),
          color: AppColors.fgMuted,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AppSizes.roundButtonSm,
            minHeight: AppSizes.roundButtonSm,
          ),
        ),
      ],
    );
  }
}

class _WeekAccordion extends StatelessWidget {
  const _WeekAccordion({
    required this.weekStart,
    required this.today,
    required this.selected,
    required this.expanded,
    required this.onHeaderTap,
    required this.onDayTap,
  });

  final DateTime weekStart;
  final DateTime today;
  final Set<DateTime> selected;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final ValueChanged<DateTime> onDayTap;

  static const List<String> _monthAbbr = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _monthDay(DateTime d) =>
      '${_monthAbbr[d.month - 1]} ${d.day}';

  String get _weekLabel {
    final end = weekStart.add(const Duration(days: 6));
    return '${_monthDay(weekStart)} – ${_monthDay(end)}';
  }

  int get _selectedInWeek {
    var n = 0;
    for (var i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      if (selected.contains(d)) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selectedInWeek;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onHeaderTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sp12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weekLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.fgDefault,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (selectedCount > 0) ...[
                          const SizedBox(height: AppSizes.sp2),
                          Text(
                            '$selectedCount selected',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.greenDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.fgMuted,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    children: [
                      const Divider(
                        height: 1,
                        color: AppColors.borderSoft,
                      ),
                      for (var i = 0; i < 7; i++)
                        _DayRow(
                          day: weekStart.add(Duration(days: i)),
                          isPast: weekStart
                              .add(Duration(days: i))
                              .isBefore(today),
                          isSelected: selected.contains(
                            weekStart.add(Duration(days: i)),
                          ),
                          onTap: onDayTap,
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.isPast,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime day;
  final bool isPast;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;

  static const List<String> _dowAbbr = <String>[
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static const List<String> _monthAbbr = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _label =>
      '${_dowAbbr[day.weekday - 1]}, ${_monthAbbr[day.month - 1]} ${day.day}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = isPast;
    final labelColor = disabled
        ? AppColors.fgFaint
        : AppColors.fgDefault;

    return InkWell(
      onTap: disabled ? null : () => onTap(day),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            _Checkbox(checked: isSelected, disabled: disabled),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                _label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.disabled});

  final bool checked;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    if (disabled) {
      fill = AppColors.bgInput;
      border = AppColors.borderMuted;
    } else if (checked) {
      fill = AppColors.greenDeep;
      border = AppColors.greenDeep;
    } else {
      fill = AppColors.surface;
      border = AppColors.borderMuted;
    }

    return Container(
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: border, width: 1.5),
      ),
      child: checked
          ? const Icon(
              Icons.check,
              size: AppSizes.iconSm,
              color: AppColors.cream,
            )
          : null,
    );
  }
}

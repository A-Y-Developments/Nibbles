import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';

/// Shows the multi-day Add-to-Meal-Plan bottom sheet (Figma 971:9346 / 971:9481).
///
/// The sheet renders day-by-day accordion cards for the next 14 days starting
/// today. Each day card shows a date label (e.g. `Tuesday, 14 Apr`) and two
/// forest-dark square chips: `more_horiz` (placeholder) and `keyboard_arrow_*`
/// (toggles expand). The expanded body shows an "Add" lime pill — tapping it
/// marks that day as selected (lime-filled card). The bottom forest-dark CTA
/// label flips to `X Days Selected` once at least one day is picked.
///
/// Returns the set of selected dates on confirm, or `null` on cancel.
Future<Set<DateTime>?> showAddToMealPlanSheet(
  BuildContext context, {
  required String babyId,
}) {
  return showModalBottomSheet<Set<DateTime>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const _AddToMealPlanSheet(),
  );
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Number of day rows shown (2 weeks ahead).
const int _kDayCount = 14;

const List<String> _kWeekdayFull = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _kMonthShort = <String>[
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

/// Verbatim format: `Tuesday, 14 Apr`.
String _formatDate(DateTime d) =>
    '${_kWeekdayFull[d.weekday - 1]}, ${d.day} ${_kMonthShort[d.month - 1]}';

class _AddToMealPlanSheet extends StatefulWidget {
  const _AddToMealPlanSheet();

  @override
  State<_AddToMealPlanSheet> createState() => _AddToMealPlanSheetState();
}

class _AddToMealPlanSheetState extends State<_AddToMealPlanSheet> {
  final Set<DateTime> _selected = <DateTime>{};
  late final DateTime _today;
  late final List<DateTime> _days;
  late int _expandedIndex;

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _days = List<DateTime>.generate(
      _kDayCount,
      (i) => _today.add(Duration(days: i)),
    );
    // Default-expand the first day so the "Add" pill is reachable.
    _expandedIndex = 0;
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

  void _toggleExpanded(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final count = _selected.length;

    return Padding(
      padding: EdgeInsets.only(top: media.padding.top + AppSizes.xxl),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radius2xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sp12,
              vertical: AppSizes.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHeader(onClose: () => Navigator.of(context).pop()),
                const SizedBox(height: AppSizes.sp12),
                _SelectedCounter(count: count),
                const SizedBox(height: AppSizes.sp12),
                Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _days.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sp12),
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final isSelected = _selected.contains(day);
                      return _DayAccordion(
                        day: day,
                        isSelected: isSelected,
                        isExpanded: _expandedIndex == index,
                        onHeaderTap: () => _toggleExpanded(index),
                        onAddTap: () => _toggleDay(day),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.sp12),
                _ConfirmCta(
                  count: count,
                  onConfirm: () => Navigator.of(context).pop(_selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppRoundButton(
          icon: const Icon(Icons.arrow_back),
          tone: AppRoundButtonTone.ghost,
          size: AppRoundButtonSize.small,
          onPressed: onClose,
          semanticLabel: 'Back',
        ),
        const SizedBox(width: AppSizes.sp12),
        Expanded(
          child: Text(
            'Meal Plan',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.fgStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppRoundButton(
          icon: const Icon(Icons.close),
          tone: AppRoundButtonTone.ghost,
          onPressed: onClose,
          semanticLabel: 'Close',
        ),
      ],
    );
  }
}

class _SelectedCounter extends StatelessWidget {
  const _SelectedCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$count selected',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.fgStrong,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DayAccordion extends StatelessWidget {
  const _DayAccordion({
    required this.day,
    required this.isSelected,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.onAddTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.green.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DayHeader(
            day: day,
            isSelected: isSelected,
            isExpanded: isExpanded,
            onTap: onHeaderTap,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.sp12,
                      0,
                      AppSizes.sp12,
                      AppSizes.sp12,
                    ),
                    child: AppPillButton(
                      label: isSelected ? 'Added' : 'Add',
                      size: AppPillButtonSize.small,
                      variant: AppPillButtonVariant.ghost,
                      onPressed: onAddTap,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _formatDate(day),
      hint: isExpanded ? 'Collapse day' : 'Expand day to add to meal plan',
      expanded: isExpanded,
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.sp12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _formatDate(day),
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.fgStrong,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppSizes.sm),
                        const _SelectedDayBadge(),
                      ],
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: _DayChip(
                    icon: isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lime-fill pill shown next to a selected day's date.
class _SelectedDayBadge extends StatelessWidget {
  const _SelectedDayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sp2,
      ),
      decoration: BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        'Added',
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.greenDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Forest-dark rounded-square chip — visual match to Figma 898:15848 +
/// 898:15849 (more_horiz and chevron buttons in each day-row header).
/// Decorative; pointer events fall through to the wrapping header InkWell.
class _DayChip extends StatelessWidget {
  const _DayChip({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.roundButtonSm,
      height: AppSizes.roundButtonSm,
      decoration: BoxDecoration(
        color: AppColors.greenDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Icon(icon, color: AppColors.onGreen, size: AppSizes.iconSm),
    );
  }
}

class _ConfirmCta extends StatelessWidget {
  const _ConfirmCta({required this.count, required this.onConfirm});

  final int count;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final label = count == 0
        ? 'Add to Meal Plan'
        : '$count ${count == 1 ? 'Day' : 'Days'} Selected';
    return AppPillButton(
      label: label,
      onPressed: count == 0 ? null : onConfirm,
    );
  }
}

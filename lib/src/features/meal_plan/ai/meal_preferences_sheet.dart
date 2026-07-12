import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/ai/meal_notes_sheet.dart';

/// Preset meal-preference options (Figma 2846:17404), in display order. Sent
/// verbatim to the AI generation prompt, so keep the strings stable.
const List<String> kMealPreferencePresets = <String>[
  'Quick to make',
  'Finger foods',
  'More veggies',
  'Light & simple',
  'Iron-rich puree',
  'Iron-rich finger foods',
  'Whipped bone marrow',
  'Stool softening meals',
  'High energy',
];

/// Runs the two-step AI preferences flow: [showMealPreferencesSheet] →
/// [showMealNotesSheet]. Returns the chosen preferences + notes, or `null`
/// if the user cancelled out of the preferences step.
///
/// "Back" on the notes step returns to the preferences step with selections
/// preserved; "Back" on the preferences step cancels the whole flow. The
/// caller owns launching the loading screen and calling generation — this
/// helper only collects input.
Future<({List<String> preferences, String notes})?> showAiPreferencesFlow(
  BuildContext context, {
  required String babyName,
}) async {
  var preferences = <String>[];
  var notes = '';
  while (true) {
    if (!context.mounted) return null;
    final chosen = await showMealPreferencesSheet(
      context,
      initialSelected: preferences,
    );
    if (chosen == null) return null;
    preferences = chosen;

    if (!context.mounted) return null;
    final enteredNotes = await showMealNotesSheet(
      context,
      preferences: preferences,
      babyName: babyName,
      initialNotes: notes,
    );
    if (enteredNotes == null) {
      // Back from notes → re-open preferences with the current selection.
      if (!context.mounted) return null;
      continue;
    }
    notes = enteredNotes;
    return (preferences: preferences, notes: notes);
  }
}

/// First AI step (Figma 2846:17404): multi-select preset preference chips.
/// "Continue" pops with the selected presets (preset order); "Back" pops with
/// `null` to cancel the flow.
Future<List<String>?> showMealPreferencesSheet(
  BuildContext context, {
  List<String> initialSelected = const <String>[],
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _MealPreferencesSheet(initialSelected: initialSelected),
  );
}

class _MealPreferencesSheet extends StatefulWidget {
  const _MealPreferencesSheet({required this.initialSelected});

  final List<String> initialSelected;

  @override
  State<_MealPreferencesSheet> createState() => _MealPreferencesSheetState();
}

class _MealPreferencesSheetState extends State<_MealPreferencesSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
  }

  void _toggle(String preset) {
    setState(() {
      if (!_selected.remove(preset)) _selected.add(preset);
    });
  }

  List<String> get _orderedSelection =>
      kMealPreferencePresets.where(_selected.contains).toList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.md,
          AppSizes.pagePaddingH,
          AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _GrabHandle()),
            const SizedBox(height: AppSizes.md),
            Text('Meal Preferences', style: textTheme.titleLarge),
            const SizedBox(height: AppSizes.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select all that apply',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppDurations.fade,
                  switchInCurve: AppCurves.standard,
                  child: Text(
                    '${_selected.length} selected',
                    key: ValueKey<int>(_selected.length),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greenDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                for (final preset in kMealPreferencePresets)
                  _PresetChip(
                    label: preset,
                    selected: _selected.contains(preset),
                    onTap: () => _toggle(preset),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    label: 'Back',
                    variant: AppPillButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: AppPillButton(
                    label: 'Continue',
                    onPressed: () =>
                        Navigator.of(context).pop(_orderedSelection),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable preference pill. Unselected: butter-outlined, greenDeep label.
/// Selected: forest fill, cream label.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: AppDurations.base,
            curve: AppCurves.standard,
            decoration: ShapeDecoration(
              color: selected ? AppColors.greenDeep : Colors.transparent,
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? AppColors.greenDeep : AppColors.butterDark,
                  width: 1.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 2,
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.base,
              curve: AppCurves.standard,
              style: TextStyle(
                fontFamily: FontFamily.parkinsans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1,
                color: selected ? AppColors.cream : AppColors.greenDeep,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    );
  }
}

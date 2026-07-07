import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';

/// Second AI step (Figma 2846:17466): free-text notes for the meal plan.
///
/// "Anything else?" heading + a butter-tinted multiline textarea and a
/// read-only "Preferences selected" recap of the chips picked in the previous
/// step. "Continue" pops with the trimmed notes (may be empty); "Back" pops
/// with `null` so the caller can return to the preferences step.
Future<String?> showMealNotesSheet(
  BuildContext context, {
  required List<String> preferences,
  required String babyName,
  String initialNotes = '',
}) {
  return showModalBottomSheet<String>(
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
    builder: (_) => _MealNotesSheet(
      preferences: preferences,
      babyName: babyName,
      initialNotes: initialNotes,
    ),
  );
}

class _MealNotesSheet extends StatefulWidget {
  const _MealNotesSheet({
    required this.preferences,
    required this.babyName,
    required this.initialNotes,
  });

  final List<String> preferences;
  final String babyName;
  final String initialNotes;

  @override
  State<_MealNotesSheet> createState() => _MealNotesSheetState();
}

class _MealNotesSheetState extends State<_MealNotesSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
              Text('Anything else?', style: textTheme.titleLarge),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Add any extra notes for the meal plan',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
              ),
              const SizedBox(height: AppSizes.md),
              _NotesField(controller: _controller, babyName: widget.babyName),
              if (widget.preferences.isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Preferences selected',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.fgStrong,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    for (final pref in widget.preferences)
                      AppChip(label: pref, tone: AppChipTone.green),
                  ],
                ),
              ],
              const SizedBox(height: AppSizes.lg),
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
                          Navigator.of(context).pop(_controller.text.trim()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller, required this.babyName});

  final TextEditingController controller;
  final String babyName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.butter),
      ),
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: AppColors.greenDeep,
        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.fgStrong),
        decoration: InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText:
              'e.g. $babyName loves sweet flavours, please avoid '
              'anything too spicy',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.greenSoft,
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

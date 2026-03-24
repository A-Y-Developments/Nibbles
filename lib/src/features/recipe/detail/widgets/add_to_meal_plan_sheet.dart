import 'package:flutter/material.dart';

/// Runs the Add to Meal Plan flow:
/// 1. Date picker
/// 2. Optional time picker dialog
///
/// Returns `({DateTime date, TimeOfDay? time})` on confirm, or null on cancel.
Future<({DateTime date, TimeOfDay? time})?> showAddToMealPlanFlow(
  BuildContext context,
) async {
  // Step 1: Date picker.
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
    helpText: 'Select a meal plan date',
  );

  if (picked == null) return null;
  if (!context.mounted) return null;

  // Step 2: Optional time picker.
  final wantTime = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add a time?'),
      content: const Text(
        'Would you like to add a specific meal time? (optional)',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Skip'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Add Time'),
        ),
      ],
    ),
  );

  if (!context.mounted) return null;

  TimeOfDay? mealTime;
  if (wantTime ?? false) {
    mealTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select meal time',
    );
  }

  if (!context.mounted) return null;

  return (date: picked, time: mealTime);
}

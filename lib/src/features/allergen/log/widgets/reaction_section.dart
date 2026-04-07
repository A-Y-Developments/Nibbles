import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/symptom_presets.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';

class ReactionSection extends StatelessWidget {
  const ReactionSection({
    required this.visible,
    required this.symptoms,
    required this.severity,
    required this.notes,
    required this.onToggleSymptom,
    required this.onSetSeverity,
    required this.onSetNotes,
    super.key,
  });

  final bool visible;
  final List<String> symptoms;
  final ReactionSeverity? severity;
  final String? notes;
  final ValueChanged<String> onToggleSymptom;
  final ValueChanged<ReactionSeverity> onSetSeverity;
  final ValueChanged<String> onSetNotes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: visible
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.md),
                // Symptom checklist
                Text('Symptoms', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                ...SymptomPresets.all.map(
                  (symptom) => CheckboxListTile(
                    value: symptoms.contains(symptom),
                    onChanged: (_) => onToggleSymptom(symptom),
                    title: Text(symptom, style: textTheme.bodyMedium),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                // Severity
                Text('Severity', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: ReactionSeverity.values.map((s) {
                    final selected = severity == s;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: s != ReactionSeverity.severe ? AppSizes.sm : 0,
                        ),
                        child: _SeverityChip(
                          severity: s,
                          selected: selected,
                          onTap: () => onSetSeverity(s),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.lg),
                // Notes
                Text('Notes (optional)', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  key: const Key('reaction_notes_field'),
                  onChanged: onSetNotes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe any other symptoms...',
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.severity,
    required this.selected,
    required this.onTap,
  });

  final ReactionSeverity severity;
  final bool selected;
  final VoidCallback onTap;

  Color get _selectedColor => switch (severity) {
    ReactionSeverity.mild => AppColors.success,
    ReactionSeverity.moderate => AppColors.warning,
    ReactionSeverity.severe => AppColors.error,
  };

  String get _label => switch (severity) {
    ReactionSeverity.mild => 'Mild',
    ReactionSeverity.moderate => 'Moderate',
    ReactionSeverity.severe => 'Severe',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
        decoration: BoxDecoration(
          color: selected
              ? _selectedColor.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? _selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          _label,
          style: textTheme.labelMedium?.copyWith(
            color: selected ? _selectedColor : AppColors.subtext,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

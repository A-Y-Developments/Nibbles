import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/symptom_presets.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_sheet.dart';

/// AL-06 — Reaction Log Modal.
///
/// Receives [ReactionLogArgs] via GoRouter `extra`.
class ReactionLogScreen extends ConsumerWidget {
  const ReactionLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = GoRouterState.of(context).extra as ReactionLogArgs?;

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('Missing reaction log context.')),
      );
    }

    return _ReactionLogView(args: args);
  }
}

class _ReactionLogView extends ConsumerWidget {
  const _ReactionLogView({required this.args});

  final ReactionLogArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allergenLogControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    // On successful save, pop back.
    ref.listen(allergenLogControllerProvider, (_, next) {
      if (next.isSaved && context.mounted) {
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Reaction Log', style: textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.pagePaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tell us what happened', style: textTheme.headlineSmall),
            const SizedBox(height: AppSizes.xs),
            Text(
              '${args.allergenName} ${args.allergenEmoji}',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
            ),
            const SizedBox(height: AppSizes.xl),
            // Symptom checklist
            Text('Symptoms', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            ...SymptomPresets.all.map(
              (symptom) => _SymptomCheckTile(
                label: symptom,
                checked: state.symptoms.contains(symptom),
                onChanged: (_) => ref
                    .read(allergenLogControllerProvider.notifier)
                    .toggleSymptom(symptom),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            // Other symptoms free text
            Text('Other symptoms noticed', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            TextField(
              key: const Key('reaction_notes_field'),
              onChanged: ref
                  .read(allergenLogControllerProvider.notifier)
                  .setNotes,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe any other symptoms (optional)',
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            // Severity selector
            Text('Severity', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: ReactionSeverity.values.map((severity) {
                final selected = state.severity == severity;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: severity != ReactionSeverity.severe
                          ? AppSizes.sm
                          : 0,
                    ),
                    child: _SeverityChip(
                      severity: severity,
                      selected: selected,
                      onTap: () => ref
                          .read(allergenLogControllerProvider.notifier)
                          .setSeverity(severity),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (state.errorMessage != null && !state.isDuplicateLog) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                state.errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              OutlinedButton(
                onPressed: () => _save(ref),
                child: const Text('Retry'),
              ),
            ],
            if (state.isDuplicateLog && state.errorMessage != null) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Text(
                  state.errorMessage!,
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('reaction_log_save_button'),
                onPressed: (state.severity != null &&
                        !state.isLoading &&
                        !state.isDuplicateLog)
                    ? () => _save(ref)
                    : null,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  void _save(WidgetRef ref) {
    final state = ref.read(allergenLogControllerProvider);
    final detail = ReactionDetail(
      id: '',
      logId: '',
      severity: state.severity!,
      symptoms: state.symptoms,
      notes: state.notes,
      createdAt: DateTime.now(),
    );
    ref
        .read(allergenLogControllerProvider.notifier)
        .saveLog(args.babyId, args.allergenKey, reactionDetail: detail);
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _SymptomCheckTile extends StatelessWidget {
  const _SymptomCheckTile({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: onChanged,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
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

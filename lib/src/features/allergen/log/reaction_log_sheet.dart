import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/symptom_presets.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';
import 'package:nibbles/src/features/allergen/log/widgets/attachment_photo_image.dart';
import 'package:nibbles/src/features/allergen/log/widgets/attachment_sheet.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Opens the Reaction Log capture / edit bottom sheet (Figma 2776:13131 —
/// reaction off, 2777:13374 — reaction on).
///
/// Handles both CREATE ([existingLog] null) and EDIT. Resolves to `true` when a
/// log was saved so callers can refresh their lists; `null` when dismissed.
///
/// The AL-08 program-completion gate is applied on save success: when the save
/// pushes every allergen to `safe` for the first time the sheet closes and
/// routes to /home/allergen/complete instead of returning normally.
Future<bool?> showReactionLogSheet(
  BuildContext context, {
  required String allergenKey,
  AllergenLog? existingLog,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radius3xl),
      ),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _ReactionLogSheet(
        allergenKey: allergenKey,
        existingLog: existingLog,
      ),
    ),
  );
}

class _ReactionLogSheet extends ConsumerStatefulWidget {
  const _ReactionLogSheet({required this.allergenKey, this.existingLog});

  final String allergenKey;
  final AllergenLog? existingLog;

  bool get isEdit => existingLog != null;

  @override
  ConsumerState<_ReactionLogSheet> createState() => _ReactionLogSheetState();
}

class _ReactionLogSheetState extends ConsumerState<_ReactionLogSheet> {
  final _notesCtrl = TextEditingController();
  String? _ctrlSyncKey;

  static const _months = <String>[
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(allergenLogControllerProvider.notifier);
      final existing = widget.existingLog;
      if (existing != null) {
        controller.hydrateFromLog(existing);
      } else {
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _syncNotesField(AllergenLogState state) {
    final key = widget.isEdit ? state.logId : 'create';
    if (key == null || _ctrlSyncKey == key) return;
    _ctrlSyncKey = key;
    _notesCtrl.text = widget.isEdit ? (state.notes ?? '') : '';
  }

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  Future<void> _pickDate(
    AllergenLogController controller,
    DateTime? current,
  ) async {
    final now = DateTime.now();
    final picked = await showCalendarDatePickerSheet(
      context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) controller.setLogDate(picked);
  }

  Future<void> _openAttachmentSheet(
    AllergenLogController controller,
    AllergenLogState state,
  ) async {
    final result = await showAttachmentSheet(
      context,
      initialPhotoPath: state.photoPath,
      initialExistingPhotoPath: state.existingPhotoPath,
      initialTitle: state.attachmentTitle,
      initialDescription: state.attachmentDescription,
    );
    if (result == null) return;
    controller
      ..setAttachmentPhoto(result.photoPath)
      ..setAttachmentTitle(result.title ?? '')
      ..setAttachmentDescription(result.description ?? '');
  }

  bool _hasAttachment(AllergenLogState state) {
    final photo = state.photoPath;
    final existingPhoto = state.existingPhotoPath;
    final title = state.attachmentTitle;
    final description = state.attachmentDescription;
    return (photo != null && photo.isNotEmpty) ||
        (existingPhoto != null && existingPhoto.isNotEmpty) ||
        (title != null && title.isNotEmpty) ||
        (description != null && description.isNotEmpty);
  }

  void _invalidateLists(String babyId) {
    ref
      ..invalidate(allergenTrackerControllerProvider(babyId))
      ..invalidate(allergenDetailControllerProvider(widget.allergenKey));
  }

  Future<void> _onSave(String babyId) async {
    final controller = ref.read(allergenLogControllerProvider.notifier);
    await controller.submit(babyId: babyId, allergenKey: widget.allergenKey);
    if (!mounted) return;

    final state = ref.read(allergenLogControllerProvider);
    if (!state.isSaved) return;

    if (state.photoUploadFailed) {
      AppToast.error(context, 'Log saved, but photo upload failed.');
    }

    // AL-08 reachability gate (NIB-128): if this save pushed every allergen to
    // `safe` for the first time, close the sheet and route to the completion
    // screen instead of returning normally. The once-only
    // `program_completion_shown_{babyId}` flag prevents re-showing it.
    final flagService = ref.read(localFlagServiceProvider);
    if (!flagService.isProgramCompletionShown(babyId)) {
      final statusesResult = await ref
          .read(allergenServiceProvider)
          .getAllergenStatuses(babyId);
      if (!mounted) return;
      final statuses = statusesResult.dataOrNull;
      final allSafe =
          statuses != null &&
          statuses.isNotEmpty &&
          statuses.values.every((AllergenStatus s) => s == AllergenStatus.safe);
      if (allSafe) {
        await flagService.markProgramCompletionShown(babyId);
        if (!mounted) return;
        final router = GoRouter.of(context);
        _invalidateLists(babyId);
        Navigator.of(context).pop(true);
        router.goNamed(AppRoute.allergenComplete.name);
        return;
      }
    }

    _invalidateLists(babyId);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allergenLogControllerProvider);
    final controller = ref.read(allergenLogControllerProvider.notifier);
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    _syncNotesField(state);

    final canSubmit =
        state.hydrated &&
        !state.isLoading &&
        babyIdAsync.valueOrNull != null &&
        (!state.hadReaction || state.severity != null);

    final logDate = state.logDate;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePaddingH,
                  AppSizes.lg,
                  AppSizes.pagePaddingH,
                  AppSizes.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reaction Log',
                      style: AppTypography.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    const _SectionLabel('Date'),
                    const SizedBox(height: AppSizes.sm),
                    _DateField(
                      value: logDate != null ? _formatDate(logDate) : null,
                      hint: _formatDate(DateTime.now()),
                      onTap: () => _pickDate(controller, logDate),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _ReactionToggleRow(
                      hadReaction: state.hadReaction,
                      onToggle: controller.toggleReaction,
                    ),
                    AnimatedSize(
                      duration: AppDurations.fade,
                      curve: AppCurves.emphasized,
                      alignment: Alignment.topCenter,
                      child: state.hadReaction
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: AppSizes.md),
                                const _SectionLabel('Symptoms'),
                                const SizedBox(height: AppSizes.sm),
                                for (final symptom in SymptomPresets.all) ...[
                                  _SymptomRow(
                                    label: symptom,
                                    checked: state.symptoms.contains(symptom),
                                    onTap: () =>
                                        controller.toggleSymptom(symptom),
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                ],
                                const SizedBox(height: AppSizes.xs),
                                const _SectionLabel('Severity'),
                                const SizedBox(height: AppSizes.sm),
                                for (final option in _severityOptions) ...[
                                  _SeverityCard(
                                    title: option.title,
                                    subtitle: option.subtitle,
                                    selected: state.severity == option.severity,
                                    onTap: () =>
                                        controller.setSeverity(option.severity),
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                ],
                              ],
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    const SizedBox(height: AppSizes.md),
                    const _SectionLabel('Notes'),
                    const SizedBox(height: AppSizes.sm),
                    AppTextField(
                      key: const Key('reaction_log_notes_field'),
                      controller: _notesCtrl,
                      onChanged: controller.setNotes,
                      minLines: 1,
                      maxLines: 3,
                      hintText: state.hadReaction
                          ? 'Describe the reaction (what, when, how long)…'
                          : 'My baby loves it, no reaction',
                    ),
                    const SizedBox(height: AppSizes.md),
                    const _SectionLabel('Attachment (Optional)'),
                    const SizedBox(height: AppSizes.sm),
                    _AttachmentBlock(
                      localPhotoPath: state.photoPath,
                      existingPhotoPath: state.existingPhotoPath,
                      attachmentTitle: state.attachmentTitle,
                      attachmentDescription: state.attachmentDescription,
                      hasAttachment: _hasAttachment(state),
                      onOpenSheet: () =>
                          _openAttachmentSheet(controller, state),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSizes.md),
                      Text(
                        state.errorMessage!,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.sm,
                AppSizes.pagePaddingH,
                AppSizes.md,
              ),
              child: AppPillButton(
                key: const Key('reaction_log_save_button'),
                label: 'Save Reaction',
                onPressed: canSubmit ? () => _onSave(babyIdAsync.value!) : null,
                leading: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cream,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityOption {
  const _SeverityOption(this.severity, this.title, this.subtitle);
  final ReactionSeverity severity;
  final String title;
  final String subtitle;
}

const _severityOptions = <_SeverityOption>[
  _SeverityOption(
    ReactionSeverity.mild,
    'Mild',
    'Minor symptoms, baby is okay',
  ),
  _SeverityOption(
    ReactionSeverity.moderate,
    'Moderate',
    'Noticeable discomfort, monitor closely',
  ),
  _SeverityOption(
    ReactionSeverity.severe,
    'Severe',
    'Seek medical attention immediately',
  ),
];

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.headline);
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Semantics(
      button: true,
      label: 'Log date',
      value: hasValue ? value! : 'Not set',
      hint: 'Opens date picker',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('reaction_log_date_field'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: Container(
            height: AppSizes.fieldHeight,
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: AppColors.borderSoft),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.fieldPaddingH,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              hasValue ? value! : hint,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: hasValue ? AppColors.fgStrong : AppColors.fgFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionToggleRow extends StatelessWidget {
  const _ReactionToggleRow({required this.hadReaction, required this.onToggle});

  final bool hadReaction;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'reaction_log_any_reaction_toggle',
      label: 'Any Reaction?',
      toggled: hadReaction,
      container: true,
      onTap: onToggle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Row(
          children: [
            const Expanded(child: _SectionLabel('Any Reaction?')),
            AppSwitch(
              key: const Key('reaction_log_switch'),
              value: hadReaction,
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  const _SymptomRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: checked,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 1,
            ),
            child: Row(
              children: [
                AppCheckbox(value: checked, onChanged: (_) => onTap()),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: AppDurations.quick,
                    curve: AppCurves.standard,
                    style:
                        AppTypography.textTheme.bodyLarge?.copyWith(
                          color: checked
                              ? AppColors.greenDeep
                              : AppColors.fgStrong,
                        ) ??
                        const TextStyle(),
                    child: Text(label),
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

class _SeverityCard extends StatelessWidget {
  const _SeverityCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.quick,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    key: ValueKey(selected),
                    size: AppSizes.iconMd - 2,
                    color: selected
                        ? AppColors.greenDeep
                        : AppColors.borderMuted,
                  ),
                ),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.headline),
                      const SizedBox(height: AppSizes.sp2),
                      Text(
                        subtitle,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.fgFaint,
                        ),
                      ),
                    ],
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

class _AttachmentBlock extends ConsumerWidget {
  const _AttachmentBlock({
    required this.localPhotoPath,
    required this.existingPhotoPath,
    required this.attachmentTitle,
    required this.attachmentDescription,
    required this.hasAttachment,
    required this.onOpenSheet,
  });

  final String? localPhotoPath;
  final String? existingPhotoPath;
  final String? attachmentTitle;
  final String? attachmentDescription;
  final bool hasAttachment;
  final VoidCallback onOpenSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPhoto =
        (localPhotoPath != null && localPhotoPath!.isNotEmpty) ||
        (existingPhotoPath != null && existingPhotoPath!.isNotEmpty);
    final title = attachmentTitle?.trim();
    final description = attachmentDescription?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final hasDescription = description != null && description.isNotEmpty;

    return AppCard(
      variant: AppCardVariant.dashed,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          if (hasPhoto)
            AttachmentPhotoImage(
              localPath: localPhotoPath,
              existingRemotePath: existingPhotoPath,
              height: 160,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            )
          else if (!hasAttachment) ...[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.butter,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: AppSizes.iconSm,
                color: AppColors.greenDeep,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text('Upload a photo', style: AppTypography.headline),
            const SizedBox(height: AppSizes.xs),
            Text(
              "This can help your doctor better assess your baby's condition.",
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.fgFaint,
              ),
            ),
          ],
          if (hasTitle || hasDescription) ...[
            if (hasPhoto) const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasTitle) Text(title, style: AppTypography.headline),
                  if (hasTitle && hasDescription)
                    const SizedBox(height: AppSizes.sp2),
                  if (hasDescription)
                    Text(
                      description,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.fgFaint,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: AppPillButton(
              key: const Key('reaction_log_add_picture'),
              label: hasAttachment ? 'Edit Picture' : 'Add Picture',
              variant: AppPillButtonVariant.ghost,
              onPressed: onOpenSheet,
            ),
          ),
        ],
      ),
    );
  }
}

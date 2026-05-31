import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';
import 'package:nibbles/src/features/allergen/log/widgets/attachment_sheet.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Full-screen Allergen Reaction Log capture / edit screen (NIB-56 / NIB-127).
///
/// Renders the redesigned form matching Figma frame `1525:28322` — Date,
/// Any Reaction? toggle, Notes, Attachment (Optional) container. The
/// "Add Picture" CTA inside the dashed attachment container opens the
/// Attachment bottom-sheet (Figma `1525:28629`) to capture photo + title +
/// description. Save commits the new log via [AllergenLogController].
///
/// CREATE mode — route `/home/allergen/:allergenKey/log`, [logId] null.
/// EDIT mode — route `/home/allergen/:allergenKey/log/:logId/edit`, [logId]
/// set; the controller hydrates state from the existing log on first build.
///
/// Pops with a [bool] result — `true` when a log was saved (caller should
/// invalidate upstream lists).
class AllergenLogScreen extends ConsumerStatefulWidget {
  const AllergenLogScreen({
    required this.allergenKey,
    this.logId,
    super.key,
  });

  final String allergenKey;
  final String? logId;

  bool get isEdit => logId != null;

  @override
  ConsumerState<AllergenLogScreen> createState() => _AllergenLogScreenState();
}

class _AllergenLogScreenState extends ConsumerState<AllergenLogScreen> {
  final _notesCtrl = TextEditingController();
  String? _ctrlSyncKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = ref.read(allergenLogControllerProvider.notifier);
      if (widget.isEdit) {
        final babyId = await ref.read(currentBabyIdProvider.future);
        if (babyId == null) return;
        await controller.hydrateForEdit(
          babyId: babyId,
          allergenKey: widget.allergenKey,
          logId: widget.logId!,
        );
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

  void _syncControllersFromState(AllergenLogState state) {
    final key = widget.isEdit ? state.logId : 'create';
    if (key == null || _ctrlSyncKey == key) return;
    _ctrlSyncKey = key;
    _notesCtrl.text = state.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allergenLogControllerProvider);
    final controller = ref.read(allergenLogControllerProvider.notifier);

    _syncControllersFromState(state);

    ref.listen<AllergenLogState>(allergenLogControllerProvider, (
      _,
      next,
    ) async {
      if (!next.isSaved || !context.mounted) return;

      if (next.photoUploadFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log saved, but photo upload failed.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // AL-08 reachability gate (NIB-128). After a successful save (CREATE or
      // EDIT) re-derive per-allergen statuses; if every allergen is `safe`
      // AND the per-baby `program_completion_shown_{babyId}` flag is unset,
      // flip the flag and route to /home/allergen/complete instead of
      // popping. On any read failure we fall through to the existing pop.
      final babyId = ref.read(currentBabyIdProvider).valueOrNull;
      if (babyId != null) {
        final flagService = ref.read(localFlagServiceProvider);
        if (!flagService.isProgramCompletionShown(babyId)) {
          final statusesResult = await ref
              .read(allergenServiceProvider)
              .getAllergenStatuses(babyId);
          if (!context.mounted) return;
          final statuses = statusesResult.dataOrNull;
          if (statuses != null) {
            final allSafe =
                statuses.isNotEmpty &&
                statuses.values.every(
                  (AllergenStatus s) => s == AllergenStatus.safe,
                );
            if (allSafe) {
              await flagService.markProgramCompletionShown(babyId);
              if (!context.mounted) return;
              context.goNamed(AppRoute.allergenComplete.name);
              return;
            }
          }
        }
      }

      if (!context.mounted) return;
      context.pop(true);
    });

    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _LogScreenBody(
          allergenKey: widget.allergenKey,
          babyId: babyId,
          isEdit: widget.isEdit,
          state: state,
          controller: controller,
          notesCtrl: _notesCtrl,
        );
      },
    );
  }
}

class _LogScreenBody extends StatelessWidget {
  const _LogScreenBody({
    required this.allergenKey,
    required this.babyId,
    required this.isEdit,
    required this.state,
    required this.controller,
    required this.notesCtrl,
  });

  final String allergenKey;
  final String babyId;
  final bool isEdit;
  final AllergenLogState state;
  final AllergenLogController controller;
  final TextEditingController notesCtrl;

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

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  bool get _canSubmit => !state.isLoading && state.hydrated;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = state.logDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) controller.setLogDate(picked);
  }

  Future<void> _openAttachmentSheet(BuildContext context) async {
    final result = await showAttachmentSheet(
      context,
      initialPhotoPath: state.photoPath,
      initialTitle: state.attachmentTitle,
      initialDescription: state.attachmentDescription,
    );
    if (result == null) return;
    controller
      ..setAttachmentPhoto(result.photoPath)
      ..setAttachmentTitle(result.title ?? '')
      ..setAttachmentDescription(result.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logDate = state.logDate;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.fgStrong,
          onPressed: () => context.pop(false),
        ),
        title: Text(
          'Reaction Log',
          style: textTheme.titleMedium?.copyWith(color: AppColors.fgStrong),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                  vertical: AppSizes.sm,
                ),
                children: [
                  const _SectionLabel('Date'),
                  const SizedBox(height: AppSizes.sm),
                  _DateField(
                    value: logDate != null ? _formatDate(logDate) : null,
                    hint: _formatDate(DateTime.now()),
                    onTap: () => _pickDate(context),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _ReactionToggleRow(
                    hadReaction: state.hadReaction,
                    onToggle: controller.toggleReaction,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const _SectionLabel('Notes'),
                  const SizedBox(height: AppSizes.sm),
                  _NotesField(
                    controller: notesCtrl,
                    onChanged: controller.setNotes,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const _SectionLabel('Attachment (Optional)'),
                  const SizedBox(height: AppSizes.sm),
                  _AttachmentBlock(
                    hasAttachment: _hasAttachment(state),
                    onOpenSheet: () => _openAttachmentSheet(context),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSizes.md),
                    Text(
                      state.errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
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
                key: const Key('log_save_button'),
                label: 'Save',
                onPressed: _canSubmit
                    ? () => controller.submit(
                        babyId: babyId,
                        allergenKey: allergenKey,
                      )
                    : null,
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

  bool _hasAttachment(AllergenLogState state) {
    final title = state.attachmentTitle;
    final description = state.attachmentDescription;
    final photo = state.photoPath;
    final existingPhoto = state.existingPhotoPath;
    return (photo != null && photo.isNotEmpty) ||
        (existingPhoto != null && existingPhoto.isNotEmpty) ||
        (title != null && title.isNotEmpty) ||
        (description != null && description.isNotEmpty);
  }
}

// ---------------------------------------------------------------------------
// Local widgets — kept private to the screen per spec build-rule 3.
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.fgStrong,
        fontWeight: FontWeight.w700,
      ),
    );
  }
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
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('log_date_field'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          height: AppSizes.fieldHeight,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.borderSoft),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.fieldPaddingH),
          alignment: Alignment.centerLeft,
          child: Text(
            hasValue ? value! : hint,
            style: textTheme.bodyLarge?.copyWith(
              color: hasValue ? AppColors.fgStrong : AppColors.fgFaint,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.borderSoft),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.fieldPaddingH,
        vertical: AppSizes.sm + 2,
      ),
      child: TextField(
        key: const Key('log_notes_field'),
        controller: controller,
        minLines: 1,
        maxLines: 4,
        onChanged: onChanged,
        cursorColor: AppColors.greenDeep,
        style: textTheme.bodyLarge?.copyWith(color: AppColors.fgStrong),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'My baby love it, no reaction',
          hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.fgFaint),
        ),
      ),
    );
  }
}

class _ReactionToggleRow extends StatelessWidget {
  const _ReactionToggleRow({
    required this.hadReaction,
    required this.onToggle,
  });

  final bool hadReaction;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      toggled: hadReaction,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Any Reaction?',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.fgStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IgnorePointer(
                child: AppSwitch(
                  key: const Key('log_reaction_switch'),
                  value: hadReaction,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentBlock extends StatelessWidget {
  const _AttachmentBlock({
    required this.hasAttachment,
    required this.onOpenSheet,
  });

  final bool hasAttachment;
  final VoidCallback onOpenSheet;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.dashed,
      padding: const EdgeInsets.all(AppSizes.sp12),
      child: SizedBox(
        height: AppSizes.buttonHeight,
        child: Material(
          color: AppColors.butter,
          shape: const StadiumBorder(),
          child: InkWell(
            key: const Key('attachment_add_picture'),
            customBorder: const StadiumBorder(),
            onTap: onOpenSheet,
            child: Center(
              child: Text(
                hasAttachment ? 'Edit Picture' : 'Add Picture',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

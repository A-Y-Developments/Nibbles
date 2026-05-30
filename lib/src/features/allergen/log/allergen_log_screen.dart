import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:nibbles/src/features/allergen/log/widgets/photo_capture_button.dart';
import 'package:nibbles/src/features/allergen/log/widgets/taste_selector.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Full-screen Allergen Log capture / edit screen (NIB-127).
///
/// CREATE mode — route `/home/allergen/:allergenKey/log`, [logId] null.
/// EDIT mode — route `/home/allergen/:allergenKey/log/:logId/edit`, [logId]
/// set; the controller hydrates state from the existing log via
/// [AllergenLogController.hydrateForEdit] on first build.
///
/// Pops with a [bool] result — `true` when a log was saved (caller should
/// invalidate). On a CREATE save where `hadReaction == true`, the pop result
/// is also `true` and the parent (home_screen) reads
/// [AllergenLogController]'s last state to decide whether to show the GP
/// referral dialog.
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
  final _attachmentTitleCtrl = TextEditingController();
  final _attachmentDescCtrl = TextEditingController();

  // Tracks the hydrated logId we already synced text controllers from. Keeps
  // the typed-into-field text from being clobbered on every rebuild.
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
    _attachmentTitleCtrl.dispose();
    _attachmentDescCtrl.dispose();
    super.dispose();
  }

  void _syncControllersFromState(AllergenLogState state) {
    final key = widget.isEdit ? state.logId : 'create';
    if (key == null || _ctrlSyncKey == key) return;
    _ctrlSyncKey = key;
    _notesCtrl.text = state.notes ?? '';
    _attachmentTitleCtrl.text = state.attachmentTitle ?? '';
    _attachmentDescCtrl.text = state.attachmentDescription ?? '';
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
      // flip the flag and route to /home/allergen/complete instead of popping.
      // On any read failure (status read, missing baby) we fall through to
      // the existing pop — the success path must NOT be blocked on a stale
      // status read. NIB-102 fires its analytics events independently on the
      // controller side; this navigation happens after that and both paths
      // coexist.
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
          attachmentTitleCtrl: _attachmentTitleCtrl,
          attachmentDescCtrl: _attachmentDescCtrl,
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
    required this.attachmentTitleCtrl,
    required this.attachmentDescCtrl,
  });

  final String allergenKey;
  final String babyId;
  final bool isEdit;
  final AllergenLogState state;
  final AllergenLogController controller;
  final TextEditingController notesCtrl;
  final TextEditingController attachmentTitleCtrl;
  final TextEditingController attachmentDescCtrl;

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

  Future<void> _pickPhoto(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                controller.pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                controller.pickPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logDate = state.logDate ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(false),
        ),
        title: Text(
          isEdit ? 'Edit Log' : 'Add Log',
          style: textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          children: [
            // Log Date row
            const _SectionLabel('Log Date'),
            const SizedBox(height: AppSizes.sm),
            _DateField(
              value: _formatDate(logDate),
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: AppSizes.lg),

            // Reaction toggle
            _ReactionToggleCard(
              hadReaction: state.hadReaction,
              onToggle: controller.toggleReaction,
            ),
            const SizedBox(height: AppSizes.lg),

            // Taste (optional)
            const _SectionLabel('Reaction (optional)'),
            const SizedBox(height: AppSizes.sm),
            TasteSelector(
              selected: state.taste,
              onSelect: controller.setTaste,
            ),
            const SizedBox(height: AppSizes.lg),

            // Notes
            const _SectionLabel('Notes'),
            const SizedBox(height: AppSizes.sm),
            _MultilineField(
              controller: notesCtrl,
              hintText: 'How did it go? Anything to remember?',
              minLines: 3,
              onChanged: controller.setNotes,
            ),
            const SizedBox(height: AppSizes.lg),

            // Attachment
            const _SectionLabel('Attachment (optional)'),
            const SizedBox(height: AppSizes.sm),
            AppTextField(
              controller: attachmentTitleCtrl,
              hintText: 'Title (e.g. Recipe, Photo)',
              onChanged: controller.setAttachmentTitle,
            ),
            const SizedBox(height: AppSizes.sm),
            _MultilineField(
              controller: attachmentDescCtrl,
              hintText: 'Description',
              minLines: 2,
              onChanged: controller.setAttachmentDescription,
            ),
            const SizedBox(height: AppSizes.sm),
            _PhotoRow(
              localPhotoPath: state.photoPath,
              existingPhotoPath: state.existingPhotoPath,
              onPick: () => _pickPhoto(context),
              onRemove: controller.removePhoto,
            ),
            const SizedBox(height: AppSizes.lg),

            if (state.errorMessage != null) ...[
              Text(
                state.errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
            ],

            AppPillButton(
              key: const Key('log_save_button'),
              label: isEdit ? 'Save Changes' : 'Save Log',
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
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
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
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          height: AppSizes.fieldHeight,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.borderSoft),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md - 2),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: AppSizes.iconSm,
                color: AppColors.greenDeep,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.fgFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.controller,
    required this.hintText,
    required this.minLines,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
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
        horizontal: AppSizes.md - 2,
        vertical: AppSizes.sm,
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: 6,
        onChanged: onChanged,
        cursorColor: AppColors.greenDeep,
        style: textTheme.bodyLarge?.copyWith(color: AppColors.fgStrong),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.greenSoft),
        ),
      ),
    );
  }
}

class _ReactionToggleCard extends StatelessWidget {
  const _ReactionToggleCard({
    required this.hadReaction,
    required this.onToggle,
  });

  final bool hadReaction;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: onToggle,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Any reaction?', style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  hadReaction
                      ? 'Marked Unsafe — captured as a flagged log.'
                      : 'Marked Safe — captured as a clean log.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          IgnorePointer(
            child: AppSwitch(value: hadReaction, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.localPhotoPath,
    required this.existingPhotoPath,
    required this.onPick,
    required this.onRemove,
  });

  /// New photo picked locally in this session.
  final String? localPhotoPath;

  /// Existing storage path on the row when editing an existing log. Shown
  /// as a chip when no new photo is picked yet.
  final String? existingPhotoPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (localPhotoPath != null) {
      return PhotoCaptureButton(
        photoPath: localPhotoPath,
        onPick: onPick,
        onRemove: onRemove,
      );
    }
    return Row(
      children: [
        Expanded(
          child: AppPillButton(
            label: existingPhotoPath != null ? 'Replace Photo' : 'Add Photo',
            onPressed: onPick,
            variant: AppPillButtonVariant.secondary,
            size: AppPillButtonSize.small,
            leading: const Icon(Icons.camera_alt_outlined),
          ),
        ),
        if (existingPhotoPath != null) ...[
          const SizedBox(width: AppSizes.sm),
          const AppChip(
            label: 'Existing photo',
            tone: AppChipTone.mute,
            emoji: '📎',
          ),
        ],
      ],
    );
  }
}

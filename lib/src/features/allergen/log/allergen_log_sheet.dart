import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/widgets/photo_capture_button.dart';
import 'package:nibbles/src/features/allergen/log/widgets/reaction_section.dart';
import 'package:nibbles/src/features/allergen/log/widgets/taste_selector.dart';

/// Single-screen allergen log bottom sheet.
///
/// Opened via [showAllergenLogSheet].
class AllergenLogSheet extends ConsumerStatefulWidget {
  const AllergenLogSheet({
    required this.babyId,
    required this.allergenKey,
    required this.allergenName,
    required this.allergenEmoji,
    super.key,
  });

  final String babyId;
  final String allergenKey;
  final String allergenName;
  final String allergenEmoji;

  @override
  ConsumerState<AllergenLogSheet> createState() => _AllergenLogSheetState();
}

class _AllergenLogSheetState extends ConsumerState<AllergenLogSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allergenLogControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allergenLogControllerProvider);
    final controller = ref.read(allergenLogControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(allergenLogControllerProvider, (_, next) {
      if (!next.isSaved || !context.mounted) return;

      if (next.photoUploadFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log saved, but photo upload failed.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      Navigator.of(context).pop(true);
    });

    final canSave =
        state.taste != null &&
        (!state.hadReaction || state.severity != null) &&
        !state.isLoading;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.pagePaddingV,
            ),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Log Exposure — '
                      '${widget.allergenName} '
                      '${widget.allergenEmoji}',
                      style: textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Taste selector
              TasteSelector(
                selected: state.taste,
                onSelect: controller.setTaste,
              ),
              const SizedBox(height: AppSizes.xl),

              // Reaction toggle
              SwitchListTile(
                key: const Key('reaction_toggle'),
                title: Text('Any reaction?', style: textTheme.titleMedium),
                value: state.hadReaction,
                onChanged: (_) => controller.toggleReaction(),
                activeTrackColor: AppColors.warning,
                contentPadding: EdgeInsets.zero,
              ),

              // Reaction section (animated expand/collapse)
              ReactionSection(
                visible: state.hadReaction,
                symptoms: state.symptoms,
                severity: state.severity,
                notes: state.notes,
                onToggleSymptom: controller.toggleSymptom,
                onSetSeverity: controller.setSeverity,
                onSetNotes: controller.setNotes,
              ),
              const SizedBox(height: AppSizes.lg),

              // Photo capture
              PhotoCaptureButton(
                photoPath: state.photoPath,
                onPick: () => _showImageSourcePicker(context, controller),
                onRemove: controller.removePhoto,
              ),
              const SizedBox(height: AppSizes.xl),

              // Error
              if (state.errorMessage != null) ...[
                Text(
                  state.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
              ],

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('log_save_button'),
                  onPressed: canSave
                      ? () => controller.saveLog(
                          widget.babyId,
                          widget.allergenKey,
                        )
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
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourcePicker(
    BuildContext context,
    AllergenLogController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                controller.pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                controller.pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper to open the sheet
// ---------------------------------------------------------------------------

Future<bool?> showAllergenLogSheet(
  BuildContext context, {
  required String babyId,
  required String allergenKey,
  required String allergenName,
  required String allergenEmoji,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXl),
      ),
    ),
    builder: (_) => AllergenLogSheet(
      babyId: babyId,
      allergenKey: allergenKey,
      allergenName: allergenName,
      allergenEmoji: allergenEmoji,
    ),
  );
}

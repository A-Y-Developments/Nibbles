import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';

/// Result returned from [showAttachmentSheet] when the user taps Add.
class AttachmentSheetResult {
  const AttachmentSheetResult({
    required this.photoPath,
    required this.title,
    required this.description,
  });

  final String? photoPath;
  final String? title;
  final String? description;
}

/// Bottom-sheet capturing the optional photo + title + description for an
/// Allergen Log attachment.
///
/// Mirrors Figma frames `1525:28629` (add context) and `1525:31142` (edit
/// context) — visually identical, reusable across both flows. Local draft
/// state is held inside the sheet; tapping Cancel returns `null` and the
/// parent form is untouched. Tapping Add returns the captured fields so the
/// parent controller can commit them in one place.
Future<AttachmentSheetResult?> showAttachmentSheet(
  BuildContext context, {
  String? initialPhotoPath,
  String? initialTitle,
  String? initialDescription,
}) {
  return showModalBottomSheet<AttachmentSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radius2xl),
      ),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: _AttachmentSheet(
        initialPhotoPath: initialPhotoPath,
        initialTitle: initialTitle,
        initialDescription: initialDescription,
      ),
    ),
  );
}

class _AttachmentSheet extends StatefulWidget {
  const _AttachmentSheet({
    this.initialPhotoPath,
    this.initialTitle,
    this.initialDescription,
  });

  final String? initialPhotoPath;
  final String? initialTitle;
  final String? initialDescription;

  @override
  State<_AttachmentSheet> createState() => _AttachmentSheetState();
}

class _AttachmentSheetState extends State<_AttachmentSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _photoPath = widget.initialPhotoPath;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await _pickSource();
    if (source == null) return;
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xFile == null) return;
    setState(() => _photoPath = xFile.path);
  }

  Future<ImageSource?> _pickSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }

  void _onCancel() => Navigator.of(context).pop();

  void _onAdd() {
    final title = _titleCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    Navigator.of(context).pop(
      AttachmentSheetResult(
        photoPath: _photoPath,
        title: title.isEmpty ? null : title,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sp20,
          AppSizes.md,
          AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Attachment',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _PhotoPreview(photoPath: _photoPath, onTap: _pickPhoto),
            const SizedBox(height: AppSizes.md),
            const _FieldLabel('Title'),
            const SizedBox(height: AppSizes.sm),
            AppTextField(
              key: const Key('attachment_title_field'),
              controller: _titleCtrl,
              hintText: 'Rash on cheek area',
            ),
            const SizedBox(height: AppSizes.md),
            const _FieldLabel('Description'),
            const SizedBox(height: AppSizes.sm),
            AppTextField(
              key: const Key('attachment_description_field'),
              controller: _descriptionCtrl,
              hintText: 'Taken 30 min after feeding',
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppPillButton(
                    key: const Key('attachment_cancel_button'),
                    label: 'Cancel',
                    onPressed: _onCancel,
                    variant: AppPillButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: AppPillButton(
                    key: const Key('attachment_add_button'),
                    label: 'Add',
                    onPressed: _onAdd,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
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

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.radiusLg);

    // Button role + curated label so screen readers announce the tap target
    // (the inner "Tap to add photo" caption is absent once a photo is set, and
    // an Image.file alone carries no accessible name). excludeSemantics is safe
    // here — the InkWell wraps no other interactive children.
    return Semantics(
      button: true,
      label: photoPath != null ? 'Change photo' : 'Add photo',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('attachment_photo_tap'),
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: 195,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: radius,
            ),
            alignment: Alignment.center,
            child: photoPath != null
                ? ClipRRect(
                    borderRadius: radius,
                    child: Image.file(
                      File(photoPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 195,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.fgFaint,
                        size: AppSizes.iconLg,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Tap to add photo',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.fgFaint,
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

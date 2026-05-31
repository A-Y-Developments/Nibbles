import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_controller.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_state.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Read-only Reaction Log Detail screen (NIB-93).
///
/// Route — `/home/allergen/:allergenKey/log/:logId`. Figma frames:
///  • 1525:28920 — Tried Safe + No Attachment
///  • 1525:28776 — Tried Safe + Attachment
///  • 1525:28946 — Tried Unsafe + No Attachment
///  • 1525:28856 — Tried Unsafe + Attachment
///
/// Layout (verbatim copy):
/// AppBar "Reaction Log" + overflow (Edit Reactions / Delete Log).
/// Body: "Log N" + Safe/Unsafe pill, "Date" field, "Notes" field, and an
/// optional "Attachment (Optional)" block (photo + Change Picture CTA +
/// title/description + download chip). The Reaction (taste) field is not
/// shown in the Figma audit and is intentionally omitted from this screen.
class AllergenLogDetailScreen extends ConsumerWidget {
  const AllergenLogDetailScreen({
    required this.allergenKey,
    required this.logId,
    super.key,
  });

  final String allergenKey;
  final String logId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      allergenLogDetailControllerProvider(allergenKey, logId),
    );

    return asyncState.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  err is AppException ? err.message : 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppPillButton(
                  label: 'Try Again',
                  onPressed: () => ref.invalidate(
                    allergenLogDetailControllerProvider(allergenKey, logId),
                  ),
                  size: AppPillButtonSize.small,
                  expand: false,
                ),
              ],
            ),
          ),
        ),
      ),
      data: (state) => _LogDetailView(
        state: state,
        allergenKey: allergenKey,
        logId: logId,
      ),
    );
  }
}

class _LogDetailView extends ConsumerWidget {
  const _LogDetailView({
    required this.state,
    required this.allergenKey,
    required this.logId,
  });

  final AllergenLogDetailState state;
  final String allergenKey;
  final String logId;

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

  Future<void> _onMenuSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    switch (value) {
      case 'edit':
        await context.pushNamed(
          AppRoute.allergenLogEdit.name,
          pathParameters: {'allergenKey': allergenKey, 'logId': logId},
        );
        ref
          ..invalidate(
            allergenLogDetailControllerProvider(allergenKey, logId),
          )
          ..invalidate(allergenDetailControllerProvider(allergenKey))
          ..invalidate(allergenTrackerControllerProvider(state.babyId));
      case 'delete':
        await _confirmAndDelete(context, ref);
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Delete this log?',
          style: Theme.of(ctx).textTheme.titleMedium,
        ),
        content: Text(
          'This will permanently remove this reaction log. You can re-add it '
          'later.',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
            color: AppColors.fgMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
          ),
          TextButton(
            key: const Key('log_delete_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                color: AppColors.destructive,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final service = ref.read(allergenServiceProvider);
    final result = await service.deleteAllergenLog(
      logId: state.log.id,
      photoPath: state.log.photoUrl,
    );

    if (!context.mounted) return;

    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't delete log. Please try again."),
        ),
      );
      return;
    }

    unawaited(
      Analytics.instance.logAllergenLogDeleted(allergenKey: allergenKey),
    );

    ref
      ..invalidate(allergenDetailControllerProvider(allergenKey))
      ..invalidate(allergenTrackerControllerProvider(state.babyId));
    context.pop();
  }

  Future<void> _onChangePicturePressed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await context.pushNamed(
      AppRoute.allergenLogEdit.name,
      pathParameters: {'allergenKey': allergenKey, 'logId': logId},
    );
    ref
      ..invalidate(allergenLogDetailControllerProvider(allergenKey, logId))
      ..invalidate(allergenDetailControllerProvider(allergenKey))
      ..invalidate(allergenTrackerControllerProvider(state.babyId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = state.log;
    final notes = log.notes?.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.fgStrong,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reaction Log',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.fgStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            key: const Key('log_detail_menu'),
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.fgStrong,
            ),
            onSelected: (v) => _onMenuSelected(context, ref, v),
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit Reactions'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete Log'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.pagePaddingV,
        ),
        children: [
          _LogTitleRow(
            logNumber: state.logNumber,
            hadReaction: log.hadReaction,
          ),
          const SizedBox(height: AppSizes.md),
          const _FieldLabel('Date'),
          const SizedBox(height: AppSizes.xs),
          _ReadOnlyField(value: _formatDate(log.logDate)),
          const SizedBox(height: AppSizes.md),
          const _FieldLabel('Notes'),
          const SizedBox(height: AppSizes.xs),
          _ReadOnlyField(
            value: notes == null || notes.isEmpty ? '—' : notes,
          ),
          if (_hasAttachment(log)) ...[
            const SizedBox(height: AppSizes.md),
            const _FieldLabel('Attachment (Optional)'),
            const SizedBox(height: AppSizes.sm),
            _AttachmentBlock(
              log: log,
              onChangePicturePressed: () =>
                  _onChangePicturePressed(context, ref),
            ),
          ],
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  bool _hasAttachment(AllergenLog log) {
    if (log.attachmentTitle != null && log.attachmentTitle!.isNotEmpty) {
      return true;
    }
    if (log.attachmentDescription != null &&
        log.attachmentDescription!.isNotEmpty) {
      return true;
    }
    if (log.photoUrl != null && log.photoUrl!.isNotEmpty) return true;
    return false;
  }
}

// ---------------------------------------------------------------------------
// Local widgets — private to log_detail per spec build-rule 3.
// ---------------------------------------------------------------------------

/// Header row: bold "Log N" + Safe/Unsafe status pill.
class _LogTitleRow extends StatelessWidget {
  const _LogTitleRow({required this.logNumber, required this.hadReaction});

  final int logNumber;
  final bool hadReaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Log $logNumber',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.fgStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppChip(
          label: hadReaction ? 'Unsafe' : 'Safe',
          tone: hadReaction ? AppChipTone.flag : AppChipTone.safe,
        ),
      ],
    );
  }
}

/// Field label — Parkinsans SemiBold 15 per Headline/SemiBold token.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: FontFamily.parkinsans,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w600,
        color: AppColors.fgStrong,
      ),
    );
  }
}

/// Pill-shaped read-only field. Background = Neutral-10 (#eaeaea / borderSoft).
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.fieldPaddingH),
      decoration: BoxDecoration(
        color: AppColors.borderSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.figtree(
          fontSize: 15,
          height: 22 / 15,
          color: AppColors.fgFaint,
        ),
      ),
    );
  }
}

/// Attachment cluster: photo preview + Change Picture pill + title +
/// description + small download chip.
class _AttachmentBlock extends ConsumerWidget {
  const _AttachmentBlock({
    required this.log,
    required this.onChangePicturePressed,
  });

  final AllergenLog log;
  final VoidCallback onChangePicturePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = log.attachmentTitle;
    final description = log.attachmentDescription;
    final photoPath = log.photoUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (photoPath != null && photoPath.isNotEmpty)
          _PhotoPreview(photoPath: photoPath),
        if (photoPath != null && photoPath.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sp12),
          AppPillButton(
            key: const Key('log_detail_change_picture'),
            label: 'Change Picture',
            onPressed: onChangePicturePressed,
            variant: AppPillButtonVariant.ghost,
          ),
        ],
        if ((title != null && title.isNotEmpty) ||
            (description != null && description.isNotEmpty)) ...[
          const SizedBox(height: AppSizes.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: FontFamily.parkinsans,
                          fontSize: 15,
                          height: 22 / 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.fgStrong,
                        ),
                      ),
                    if (description != null && description.isNotEmpty) ...[
                      if (title != null && title.isNotEmpty)
                        const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.figtree(
                          fontSize: 15,
                          height: 22 / 15,
                          color: AppColors.fgFaint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const _DownloadChip(),
            ],
          ),
        ],
      ],
    );
  }
}

class _PhotoPreview extends ConsumerWidget {
  const _PhotoPreview({required this.photoPath});
  final String photoPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(_signedPhotoUrlProvider(photoPath));

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: urlAsync.when(
        loading: () => Container(
          height: 195,
          width: double.infinity,
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
        error: (_, __) => Container(
          height: 195,
          width: double.infinity,
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: const Text('Photo unavailable'),
        ),
        data: (url) {
          if (url == null) {
            return Container(
              height: 195,
              width: double.infinity,
              color: AppColors.surfaceVariant,
              alignment: Alignment.center,
              child: const Text('Photo unavailable'),
            );
          }
          return Image.network(
            url,
            height: 195,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 195,
              color: AppColors.surfaceVariant,
              alignment: Alignment.center,
              child: const Text('Photo unavailable'),
            ),
          );
        },
      ),
    );
  }
}

/// 35x35 round chip with a download glyph, sitting beside the attachment
/// caption. Display-only per audit; no documented save-to-device flow yet.
class _DownloadChip extends StatelessWidget {
  const _DownloadChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: AppSizes.shadowCard,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.file_download_outlined,
        size: AppSizes.iconSm,
        color: AppColors.fgStrong,
      ),
    );
  }
}

/// Resolves a signed URL for a stored attachment photo. Auto-disposed so the
/// signed URL is re-fetched the next time the detail screen is opened.
final _signedPhotoUrlProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, path) async {
      final service = ref.watch(allergenServiceProvider);
      final result = await service.getSignedPhotoUrl(path);
      if (result.isFailure) return null;
      return result.dataOrNull;
    });

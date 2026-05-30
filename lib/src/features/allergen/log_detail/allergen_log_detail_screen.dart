import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_controller.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_state.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Read-only Allergen Log Detail screen (NIB-127).
///
/// Route — `/home/allergen/:allergenKey/log/:logId`. Shows the captured log
/// fields (header + status badge, log date, optional taste, optional notes,
/// optional attachment title/description/photo). The overflow menu in the
/// app bar exposes Edit (pushes the EDIT route) and Delete (confirmation
/// dialog → [AllergenService.deleteAllergenLog] → pops back).
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

  String _tasteLabel(EmojiTaste taste) => switch (taste) {
    EmojiTaste.love => '😍 Loved it',
    EmojiTaste.neutral => '😐 Neutral',
    EmojiTaste.dislike => '😣 Disliked',
  };

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
        // Refresh the detail view in case the edit updated fields.
        ref.invalidate(
          allergenLogDetailControllerProvider(allergenKey, logId),
        );
        // Refresh both upstream lists so a pop to either reflects the edit.
        ref.invalidate(allergenDetailControllerProvider(allergenKey));
        ref.invalidate(allergenTrackerControllerProvider(state.babyId));
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

    // Invalidate both upstream lists so a pop to either reflects the delete.
    ref
      ..invalidate(allergenDetailControllerProvider(allergenKey))
      ..invalidate(allergenTrackerControllerProvider(state.babyId));
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final log = state.log;
    final allergen = state.allergen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Log ${state.logNumber}', style: textTheme.titleMedium),
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
                child: Text('Edit'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
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
          _LogHeaderCard(
            allergen: allergen,
            hadReaction: log.hadReaction,
            logDate: _formatDate(log.logDate),
          ),
          if (log.emojiTaste != null) ...[
            const SizedBox(height: AppSizes.lg),
            const _SectionLabel('Reaction'),
            const SizedBox(height: AppSizes.sm),
            _ReadOnlyRow(value: _tasteLabel(log.emojiTaste!)),
          ],
          if (log.notes != null && log.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            const _SectionLabel('Notes'),
            const SizedBox(height: AppSizes.sm),
            _ReadOnlyRow(value: log.notes!.trim()),
          ],
          if (_hasAttachment(log)) ...[
            const SizedBox(height: AppSizes.lg),
            const _SectionLabel('Attachment'),
            const SizedBox(height: AppSizes.sm),
            _AttachmentCard(log: log),
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

class _LogHeaderCard extends StatelessWidget {
  const _LogHeaderCard({
    required this.allergen,
    required this.hadReaction,
    required this.logDate,
  });

  final Allergen allergen;
  final bool hadReaction;
  final String logDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.coralSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(allergen.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(allergen.name, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  logDate,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.fgFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          AppChip(
            label: hadReaction ? 'Unsafe' : 'Safe',
            tone: hadReaction ? AppChipTone.flag : AppChipTone.safe,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Text(
        value,
        style: textTheme.bodyMedium?.copyWith(color: AppColors.fgStrong),
      ),
    );
  }
}

class _AttachmentCard extends ConsumerWidget {
  const _AttachmentCard({required this.log});

  final AllergenLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final title = log.attachmentTitle;
    final description = log.attachmentDescription;
    final photoPath = log.photoUrl;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title.isNotEmpty)
            Text(title, style: textTheme.titleSmall),
          if (description != null && description.isNotEmpty) ...[
            if (title != null && title.isNotEmpty)
              const SizedBox(height: AppSizes.xs),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
            ),
          ],
          if (photoPath != null && photoPath.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            _PhotoPreview(photoPath: photoPath),
          ],
        ],
      ),
    );
  }
}

class _PhotoPreview extends ConsumerWidget {
  const _PhotoPreview({required this.photoPath});
  final String photoPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(_signedPhotoUrlProvider(photoPath));

    return urlAsync.when(
      loading: () => Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      error: (_, __) => const AppChip(
        label: 'Photo unavailable',
        tone: AppChipTone.mute,
        emoji: '📎',
      ),
      data: (url) {
        if (url == null) {
          return const AppChip(
            label: 'Photo unavailable',
            tone: AppChipTone.mute,
            emoji: '📎',
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Image.network(
            url,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              color: AppColors.surfaceVariant,
              alignment: Alignment.center,
              child: const Text('Photo unavailable'),
            ),
          ),
        );
      },
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

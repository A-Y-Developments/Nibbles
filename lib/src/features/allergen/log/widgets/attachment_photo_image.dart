import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';

/// Resolves a signed URL for a stored attachment photo. Auto-disposed so the
/// signed URL is re-fetched the next time it's watched.
final signedPhotoUrlProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, path) async {
      final service = ref.watch(allergenServiceProvider);
      final result = await service.getSignedPhotoUrl(path);
      if (result.isFailure) return null;
      return result.dataOrNull;
    });

/// Renders an Allergen Log attachment photo from either a freshly-picked
/// local file ([localPath]) or an already-uploaded remote storage path
/// ([existingRemotePath], resolved to a signed URL). [localPath] wins when
/// both are set — that's the "user just changed the photo" case. Renders
/// nothing when neither is set; callers should check for that beforehand.
class AttachmentPhotoImage extends ConsumerWidget {
  const AttachmentPhotoImage({
    required this.localPath,
    required this.existingRemotePath,
    required this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? localPath;
  final String? existingRemotePath;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = _buildImage(ref);
    if (image == null) return const SizedBox.shrink();
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget? _buildImage(WidgetRef ref) {
    final local = localPath;
    if (local != null && local.isNotEmpty) {
      return Image.file(
        File(local),
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }

    final remote = existingRemotePath;
    if (remote == null || remote.isEmpty) return null;

    final urlAsync = ref.watch(signedPhotoUrlProvider(remote));
    return urlAsync.when(
      loading: () => _placeholder(const BrandFlowerLoader.small()),
      error: (_, _) => _placeholder(const Text('Photo unavailable')),
      data: (url) => url == null
          ? _placeholder(const Text('Photo unavailable'))
          : Image.network(
              url,
              height: height,
              width: double.infinity,
              fit: fit,
              errorBuilder: (_, _, _) =>
                  _placeholder(const Text('Photo unavailable')),
            ),
    );
  }

  Widget _placeholder(Widget child) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: child,
    );
  }
}

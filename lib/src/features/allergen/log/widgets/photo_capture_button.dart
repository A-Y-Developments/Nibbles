import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

class PhotoCaptureButton extends StatelessWidget {
  const PhotoCaptureButton({
    required this.photoPath,
    required this.onPick,
    required this.onRemove,
    super.key,
  });

  final String? photoPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Image.file(
              File(photoPath!),
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      key: const Key('photo_capture_button'),
      onPressed: onPick,
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('Add Photo'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// On/off switch. Mirrors kit components-controls `.switch`: 44x24 track,
/// butter-on / grey-off, greenDeep 20px thumb with shadowSwitch.
class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    const inset = (AppSizes.switchTrackH - AppSizes.switchThumb) / 2;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: AppSizes.switchTrackW,
          height: AppSizes.switchTrackH,
          decoration: BoxDecoration(
            color: value ? AppColors.butter : AppColors.switchTrackOff,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: inset),
                  width: AppSizes.switchThumb,
                  height: AppSizes.switchThumb,
                  decoration: const BoxDecoration(
                    color: AppColors.greenDeep,
                    shape: BoxShape.circle,
                    boxShadow: AppSizes.shadowSwitch,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

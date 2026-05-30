import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// NIB-65 — Butter-wash header for the Home dashboard.
///
/// Layout (per `design/preview/components-header.html` + `HomeScreen.jsx`):
///   - Background: vertical gradient `butter → butterSoft`.
///   - Left:  white "Today" pill (h32, green-deep label).
///   - Centre: "Nibbles" wordmark (title3 / Parkinsans 700 17, fg-strong).
///   - Right: 36px green-deep avatar with the first letter of [babyName]
///            (or '?' when empty). Tap delegates to [onAvatarTap] — NIB-86
///            wired this to push the profile route.
///
/// The signature is intentionally identical to the NIB-86 placeholder so
/// `home_screen.dart` does not need to change.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.babyName,
    required this.ageMonths,
    this.onAvatarTap,
    super.key,
  });

  final String babyName;

  /// Held for parity with the NIB-86 wired signature. The header itself does
  /// not surface the age — the greeting card below it does — but the
  /// param has to stay so `home_screen.dart` keeps compiling untouched.
  final int ageMonths;
  final VoidCallback? onAvatarTap;

  String get _avatarInitial {
    final trimmed = babyName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + AppSizes.xs,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.butter, AppColors.butterSoft],
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
      ),
      child: Row(
        children: [
          const _TodayPill(),
          const Expanded(
            child: Center(
              child: Text(
                'Nibbles',
                style: TextStyle(
                  fontFamily: FontFamily.parkinsans,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.294,
                  color: AppColors.fgStrong,
                ),
              ),
            ),
          ),
          _HeaderAvatar(
            initial: _avatarInitial,
            onTap: onAvatarTap,
          ),
        ],
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.roundButtonSm,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sp12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: const Text(
        'Today',
        style: TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
          color: AppColors.greenDeep,
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.initial, this.onTap});

  final String initial;
  final VoidCallback? onTap;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1,
          color: AppColors.cream,
        ),
      ),
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: avatar,
    );
  }
}

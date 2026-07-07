import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// NIB-65 — Butter-wash header for the Home dashboard.
///
/// Layout (per `design/preview/components-header.html` + `HomeScreen.jsx`):
///   - Background: vertical gradient `butter → butterSoft`.
///   - Left:  white "Today" pill (h32, green-deep label).
///   - Centre: Nibbles wordmark image.
///   - Right: 36px green-deep circular avatar. Tap delegates to
///            [onAvatarTap] — NIB-86 wired this to push the profile route.
///
/// The signature is intentionally identical to the NIB-86 placeholder so
/// `home_screen.dart` does not need to change.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.babyName,
    required this.ageMonths,
    this.onAvatarTap,
    this.onTodayTap,
    super.key,
  });

  final String babyName;

  /// Held for parity with the NIB-86 wired signature. The header itself does
  /// not surface the age — the greeting card below it does — but the
  /// param has to stay so `home_screen.dart` keeps compiling untouched.
  final int ageMonths;
  final VoidCallback? onAvatarTap;

  /// Resets the Home date strip back to today.
  final VoidCallback? onTodayTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          _TodayPill(onTap: onTodayTap),
          Expanded(
            child: Center(
              child: Semantics(
                label: 'Nibbles',
                image: true,
                excludeSemantics: true,
                child: Assets.images.home.nibblesWordmark.image(
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          _HeaderAvatar(onTap: onAvatarTap),
        ],
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      height: AppSizes.roundButtonSm,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: const Text(
        'Today',
        style: TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
          color: AppColors.greenDeep,
        ),
      ),
    );

    if (onTap == null) return pill;

    return Semantics(
      button: true,
      label: 'Jump to today',
      identifier: 'home_today_pill',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: pill,
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({this.onTap});

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
      child: const Icon(Icons.person_outline, size: 18, color: AppColors.cream),
    );

    if (onTap == null) return avatar;

    return Semantics(
      button: true,
      label: 'Profile',
      identifier: 'home_profile_avatar',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: avatar,
      ),
    );
  }
}

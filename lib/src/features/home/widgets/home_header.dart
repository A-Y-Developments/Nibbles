import 'package:flutter/material.dart';

/// Placeholder for NIB-65 (header + avatar). Wave 2 will replace the
/// implementation; this file fixes the call-site contract so `home_screen`
/// does not need to change.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.babyName,
    required this.ageMonths,
    this.onAvatarTap,
    super.key,
  });

  final String babyName;
  final int ageMonths;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-65): implement header + greeting + avatar per redesign.
    return const SizedBox.shrink();
  }
}

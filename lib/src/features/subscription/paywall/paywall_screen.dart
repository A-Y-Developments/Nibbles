import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_sheet.dart';

/// NIB-55 — paywall page (`/subscription/paywall`).
///
/// Reached from the M2 entitlement guard (NIB-144) and from
/// Settings → Manage Subscription → "Go Premium". A full-screen page — not a
/// modal sheet — so it behaves as a real navigation destination in both
/// contexts. (The body widget is still named `PaywallSheet` for history; it is
/// no longer presented as a sheet. Rename deferred.)
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(child: PaywallSheet(key: Key('paywall_screen_sheet'))),
    );
  }
}

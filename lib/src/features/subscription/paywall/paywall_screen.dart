import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_sheet.dart';

/// NIB-55 — paywall screen.
///
/// The real entry point is [showPaywallSheet] (bottom sheet from "Go
/// Premium"). This screen exists so the existing `/subscription/paywall`
/// GoRoute still resolves to a widget; it hosts the same [PaywallSheet]
/// body as a full-page Scaffold with the Figma sheet's rounded top corners
/// drawn against a soft scrim so deep-link arrivals match the sheet aesthetic.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // Soft scrim behind the sheet body so it reads as an overlay even when
      // pushed full-screen via deep link (rather than animating up from a
      // parent route).
      backgroundColor: AppColors.text.withValues(alpha: 0.4),
      body: const SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            child: Material(
              color: AppColors.cream,
              child: PaywallSheet(key: Key('paywall_screen_sheet')),
            ),
          ),
        ),
      ),
    );
  }
}

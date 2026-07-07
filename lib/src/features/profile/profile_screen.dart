import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_overlay.dart';
import 'package:nibbles/src/features/profile/profile_controller.dart';
import 'package:nibbles/src/features/profile/profile_state.dart';
import 'package:nibbles/src/features/profile/widgets/premium_teaser_card.dart';
import 'package:nibbles/src/features/profile/widgets/profile_avatar_card.dart';
import 'package:nibbles/src/features/profile/widgets/profile_header.dart';
import 'package:nibbles/src/features/profile/widgets/settings_row.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fire screen_view('profile') once on mount via a post-frame callback.
    // Best-effort + unawaited so a Firebase hiccup never throws into the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await ref.read(analyticsProvider).logScreenView(screenName: 'profile');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _ProfileError(
        message: 'Could not load profile.',
        onRetry: () => ref.invalidate(currentBabyIdProvider),
      ),
      data: (babyId) {
        if (babyId == null) {
          return _ProfileError(
            message: 'No baby profile found.',
            onRetry: () => ref.invalidate(currentBabyIdProvider),
          );
        }
        return _ProfileBody(babyId: babyId);
      },
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileControllerProvider(babyId));

    return asyncState.when(
      loading: () => const GradientScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => _ProfileError(
        message: err is AppException ? err.message : 'Something went wrong.',
        onRetry: () => ref.invalidate(profileControllerProvider(babyId)),
      ),
      data: (state) => _ProfileContent(state: state),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = state.baby;
    if (baby == null) {
      return const _ProfileError(message: 'No baby profile found.');
    }

    void goBack() => context.canPop() ? context.pop() : context.go('/home');

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(onBack: goBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  0,
                  AppSizes.md,
                  AppSizes.pagePaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileAvatarCard(
                      name: baby.name,
                      ageLabel: _ageLabel(baby.dateOfBirth),
                      onEdit: () =>
                          context.pushNamed(AppRoute.profileEdit.name),
                    ),
                    const PremiumTeaserCard(),
                    const SizedBox(height: AppSizes.lg),
                    SettingsRow(
                      key: const Key('profile_manage_subscription_row'),
                      title: 'Manage Subscription',
                      subtitle: state.subscriptionLabel ?? 'No Subscription',
                      // NIB-73 — push the Manage Subscription screen.
                      onTap: () =>
                          context.pushNamed(AppRoute.manageSubscription.name),
                    ),
                    const SizedBox(height: AppSizes.sp12),
                    SettingsRow(
                      key: const Key('profile_feedback_row'),
                      title: 'Give Feedback',
                      onTap: () =>
                          context.pushNamed(AppRoute.profileFeedback.name),
                    ),
                    const SizedBox(height: AppSizes.sp12),
                    SettingsRow(
                      key: const Key('profile_sign_out_button'),
                      title: 'Sign out',
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                    const SizedBox(height: AppSizes.sp12),
                    SettingsRow(
                      key: const Key('profile_delete_account_row'),
                      title: 'Delete account',
                      danger: true,
                      onTap: () => showDeleteAccountOverlay(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ageLabel(DateTime dob) {
    // Months + days since the most recent month anniversary, mirroring
    // ageInMonths so the breakdown stays consistent with Home. Pluralized
    // with singular handling at exactly 1 (NIB-170; was always "month").
    final now = DateTime.now();
    final months = ageInMonths(dob, now: now);
    final anniversary = DateTime(dob.year, dob.month + months, dob.day);
    final days = now.difference(anniversary).inDays;
    final clampedDays = days < 0 ? 0 : days;
    final monthLabel = months == 1 ? 'month' : 'months';
    final dayLabel = clampedDays == 1 ? 'day' : 'days';
    return '$months $monthLabel $clampedDays $dayLabel';
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final result = await ref.read(authServiceProvider.notifier).signOut();
      if (!context.mounted) return;
      switch (result) {
        case Success():
          unawaited(ref.read(analyticsProvider).logLogout());
        // GoRouter redirect handles navigation to /auth/login.
        case Failure():
          AppToast.error(context, "Couldn't sign out. Please try again.");
      }
    }
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl,
                  color: AppColors.destructive,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSizes.lg),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

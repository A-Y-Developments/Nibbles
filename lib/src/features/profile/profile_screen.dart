import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/profile_controller.dart';
import 'package:nibbles/src/features/profile/profile_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) =>
          const Scaffold(body: Center(child: Text('Could not load profile.'))),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            body: Center(child: Text('No baby profile found.')),
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Profile'),
        ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
                ),
                const SizedBox(height: AppSizes.lg),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(profileControllerProvider(babyId)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (state) => _ProfileContent(babyId: babyId, state: state),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.babyId, required this.state});

  final String babyId;
  final ProfileState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BabyInfoCard(
                baby: state.baby,
                subscriptionLabel: state.subscriptionLabel,
              ),
              const SizedBox(height: AppSizes.lg),
              _SafeAllergenSection(safeAllergens: state.safeAllergens),
              const SizedBox(height: AppSizes.xl),
              FilledButton(
                key: const Key('profile_edit_button'),
                onPressed: () => context.pushNamed(AppRoute.profileEdit.name),
                child: const Text('Edit'),
              ),
              const SizedBox(height: AppSizes.md),
              OutlinedButton(
                key: const Key('profile_sign_out_button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () => _confirmSignOut(context, ref),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authServiceProvider.notifier).signOut();
      // GoRouter redirect handles navigation to /auth/login automatically
    }
  }
}

// ---------------------------------------------------------------------------
// Baby Info Card
// ---------------------------------------------------------------------------

class _BabyInfoCard extends StatelessWidget {
  const _BabyInfoCard({required this.baby, required this.subscriptionLabel});

  final Baby baby;
  final String subscriptionLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: AppSizes.avatarLg,
            height: AppSizes.avatarLg,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _calculateAge(baby.dateOfBirth),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.subtext,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _genderLabel(baby.gender),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.subtext,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    subscriptionLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final months = (now.year - dob.year) * 12 + now.month - dob.month;
    if (months < 12) return '$months months old';
    final years = months ~/ 12;
    return '$years year${years > 1 ? 's' : ''} old';
  }

  String _genderLabel(Gender gender) => switch (gender) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.preferNotToSay => 'Prefer not to say',
  };
}

// ---------------------------------------------------------------------------
// Safe Allergen Section
// ---------------------------------------------------------------------------

class _SafeAllergenSection extends StatelessWidget {
  const _SafeAllergenSection({required this.safeAllergens});

  final List<AllergenBoardItem> safeAllergens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovered Safe Allergens',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSizes.md),
        if (safeAllergens.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Text(
                'No safe allergens confirmed yet. Keep going!',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: safeAllergens.map((item) {
              return _AllergenChip(
                emoji: item.allergen.emoji,
                name: item.allergen.name,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.allergenSafe.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.allergenSafe, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSizes.xs),
          Text(
            name,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.allergenSafe,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

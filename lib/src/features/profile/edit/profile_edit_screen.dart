import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_controller.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_state.dart';
import 'package:nibbles/src/features/profile/profile_controller.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

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
        return _ProfileEditBody(babyId: babyId);
      },
    );
  }
}

class _ProfileEditBody extends ConsumerWidget {
  const _ProfileEditBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileEditControllerProvider(babyId));

    return asyncState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Edit Profile'),
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
                      ref.invalidate(profileEditControllerProvider(babyId)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (formState) =>
          _ProfileEditForm(babyId: babyId, formState: formState),
    );
  }
}

class _ProfileEditForm extends ConsumerStatefulWidget {
  const _ProfileEditForm({required this.babyId, required this.formState});

  final String babyId;
  final ProfileEditState formState;

  @override
  ConsumerState<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<_ProfileEditForm> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.formState.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState =
        ref.watch(profileEditControllerProvider(widget.babyId)).valueOrNull ??
        widget.formState;
    final textTheme = Theme.of(context).textTheme;
    final controller =
        ref.read(profileEditControllerProvider(widget.babyId).notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Edit Profile',
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
              // Baby name
              TextField(
                key: const Key('edit_baby_name_field'),
                controller: _nameController,
                onChanged: controller.updateName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: "Baby's name"),
              ),
              const SizedBox(height: AppSizes.lg),
              // Date of birth
              Text(
                'Date of Birth',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                height: 180,
                child: CupertinoDatePicker(
                  key: const Key('edit_baby_dob_picker'),
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: formState.dob,
                  maximumDate: today,
                  minimumDate: DateTime(now.year - 3, now.month, now.day),
                  onDateTimeChanged: controller.updateDob,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              // Gender
              Text(
                'Gender',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              ...Gender.values.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: _GenderCard(
                    label: _genderLabel(g),
                    selected: formState.gender == g,
                    onTap: () => controller.updateGender(g),
                  ),
                ),
              ),
              if (formState.errorMessage != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  formState.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              FilledButton(
                key: const Key('edit_profile_save_button'),
                onPressed: formState.isLoading
                    ? null
                    : () => _save(controller),
                child: formState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(ProfileEditController controller) async {
    final ok = await controller.save();
    if (!ok || !mounted) return;

    // Invalidate profile so PR-01 shows updated data
    ref.invalidate(profileControllerProvider(widget.babyId));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    context.pop();
  }

  String _genderLabel(Gender g) => switch (g) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.preferNotToSay => 'Prefer not to say',
  };
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

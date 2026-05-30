import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/common/components/inputs/app_text_field.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_controller.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_state.dart';
import 'package:nibbles/src/features/profile/profile_controller.dart';

/// PR-02 — Edit Profile.
///
/// Mirrors Figma frame 1200:10475 (`ProfileEditScreen` in
/// `design/ui_kits/nibbles_mobile/ProfileScreen.jsx`): butter-soft wash
/// header with a back chevron + "Change Profile" title, coral avatar puck,
/// then a cream form pane with First Name / Last Name (Optional) / Email
/// labelled fields and a full-width primary "Save" pill.
class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _ProfileEditError(
        message: 'Could not load profile.',
        onRetry: () => ref.invalidate(currentBabyIdProvider),
      ),
      data: (babyId) {
        if (babyId == null) {
          return _ProfileEditError(
            message: 'No baby profile found.',
            onRetry: () => ref.invalidate(currentBabyIdProvider),
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
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => _ProfileEditError(
        message: err is AppException ? err.message : 'Something went wrong.',
        onRetry: () => ref.invalidate(profileEditControllerProvider(babyId)),
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
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  bool _emailTouched = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.formState.firstName,
    );
    _lastNameController = TextEditingController(
      text: widget.formState.lastName,
    );
    _emailController = TextEditingController(text: widget.formState.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState =
        ref.watch(profileEditControllerProvider(widget.babyId)).valueOrNull ??
            widget.formState;
    final controller = ref.read(
      profileEditControllerProvider(widget.babyId).notifier,
    );
    final theme = Theme.of(context);

    final emailValid =
        const EmailInput.dirty().validator(formState.email.trim()) == null;
    final firstNameValid = formState.firstName.trim().isNotEmpty;
    final canSave = firstNameValid && emailValid && !formState.isLoading;

    void goBack() => context.canPop() ? context.pop() : context.go('/home');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: ColoredBox(
              color: AppColors.butterSoft,
              child: Column(
                children: [
                  _EditHeader(onBack: goBack),
                  const _EditAvatar(),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.sm,
                AppSizes.pagePaddingH,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    key: const Key('edit_first_name_field'),
                    label: 'First Name',
                    controller: _firstNameController,
                    onChanged: controller.updateFirstName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppTextField(
                    key: const Key('edit_last_name_field'),
                    label: 'Last Name (Optional)',
                    controller: _lastNameController,
                    onChanged: controller.updateLastName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppTextField(
                    key: const Key('edit_email_field'),
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      if (!_emailTouched) {
                        setState(() => _emailTouched = true);
                      }
                      controller.updateEmail(value);
                    },
                    errorText: _emailTouched && !emailValid
                        ? 'Enter a valid email address.'
                        : null,
                  ),
                  if (formState.errorMessage != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      formState.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.xl - 4),
                  AppPillButton(
                    key: const Key('edit_profile_save_button'),
                    label: formState.isLoading ? 'Saving…' : 'Save',
                    onPressed: canSave ? _save : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final controller = ref.read(
      profileEditControllerProvider(widget.babyId).notifier,
    );
    final result = await controller.save();
    if (!result.success || !mounted) return;

    // Invalidate profile so PR-01 shows updated data.
    ref.invalidate(profileControllerProvider(widget.babyId));

    final message = result.emailChanged
        ? 'Please check your inbox to confirm the new email.'
        : 'Profile updated.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    context.pop();
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: AppColors.butterSoft,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md + 2,
        AppSizes.sm - 2,
        AppSizes.md + 2,
        AppSizes.md + 2,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.roundButtonSm,
            child: AppRoundButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack,
              tone: AppRoundButtonTone.ghost,
              size: AppRoundButtonSize.small,
              semanticLabel: 'Back',
            ),
          ),
          Expanded(
            child: Text(
              'Change Profile',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.fgStrong,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.roundButtonSm),
        ],
      ),
    );
  }
}

class _EditAvatar extends StatelessWidget {
  const _EditAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.butterSoft,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md + 2,
        0,
        AppSizes.md + 2,
        AppSizes.md + 2,
      ),
      child: Center(
        child: Container(
          width: AppSizes.avatarXl,
          height: AppSizes.avatarXl,
          decoration: const BoxDecoration(
            color: AppColors.coral,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.child_care_rounded,
              size: AppSizes.xxxl,
              color: AppColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileEditError extends StatelessWidget {
  const _ProfileEditError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  AppPillButton(
                    label: 'Try Again',
                    onPressed: onRetry,
                    expand: false,
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

import 'dart:async';

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
import 'package:nibbles/src/logging/analytics.dart';

// ── Figma frame 1200:10475 spec values (profile-edit only) ──────────────
// Avatar PNG is 143x143 in Figma; no asset shipped, so we keep the coral
// circle + cream icon (same fallback used by ProfileAvatarCard) at 143px.
const double _kEditAvatarSize = 143;
// Form column inset: 16px left, 17px right (Figma); use 16 symmetrically.
const double _kFormPaddingH = 16;
// Field group gap (between fields) = 17; label→input gap = 11.
const double _kFieldGroupGap = 17;
const double _kLabelGap = 11;
// Page background Grad-1 (linear-gradient 154.372deg butter→light-grey).
const Color _kGradEnd = Color(0xFFF5F5F5);

/// PR-02 — Edit Profile.
///
/// Mirrors Figma frame 1200:10475: Grad-1 page wash (butter→#f5f5f5 at
/// ~154°), back chip + "Change Profile" header, 143px coral avatar puck,
/// then First Name / Last Name (Optional) / Email labelled fields and a
/// primary "Save" pill.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  @override
  void initState() {
    super.initState();
    // Fire screen_view('profile_edit') once on mount via post-frame callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await ref
          .read(analyticsProvider)
          .logScreenView(screenName: 'profile_edit');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const _ProfileEditScaffold(
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
      loading: () => const _ProfileEditScaffold(
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
  late final FocusNode _firstNameFocus;
  late final FocusNode _lastNameFocus;
  late final FocusNode _emailFocus;
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
    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
    _emailFocus = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
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

    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 22 / 15,
      color: AppColors.fgStrong,
    );

    return _ProfileEditScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EditHeader(onBack: goBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _kFormPaddingH,
                  0,
                  _kFormPaddingH,
                  AppSizes.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _EditAvatar(),
                    const SizedBox(height: _kFieldGroupGap),
                    Semantics(
                      label: 'First Name',
                      textField: true,
                      child: _LabelledField(
                        label: 'First Name',
                        labelStyle: labelStyle,
                        field: AppTextField(
                          key: const Key('edit_first_name_field'),
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          onChanged: controller.updateFirstName,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_lastNameFocus),
                        ),
                      ),
                    ),
                    const SizedBox(height: _kFieldGroupGap),
                    Semantics(
                      label: 'Last Name, optional',
                      textField: true,
                      child: _LabelledField(
                        label: 'Last Name (Optional)',
                        labelStyle: labelStyle,
                        field: AppTextField(
                          key: const Key('edit_last_name_field'),
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          onChanged: controller.updateLastName,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_emailFocus),
                        ),
                      ),
                    ),
                    const SizedBox(height: _kFieldGroupGap),
                    Semantics(
                      label: 'Email',
                      textField: true,
                      child: _LabelledField(
                        label: 'Email',
                        labelStyle: labelStyle,
                        field: AppTextField(
                          key: const Key('edit_email_field'),
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          onChanged: (value) {
                            if (!_emailTouched) {
                              setState(() => _emailTouched = true);
                            }
                            controller.updateEmail(value);
                          },
                          onSubmitted: (_) {
                            if (canSave) unawaited(_save());
                          },
                          errorText: _emailTouched && !emailValid
                              ? 'Enter a valid email address.'
                              : null,
                        ),
                      ),
                    ),
                    if (formState.errorMessage != null) ...[
                      const SizedBox(height: AppSizes.sm),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          'Error: ${formState.errorMessage!}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.xl - 4),
                    AppPillButton(
                      key: const Key('edit_profile_save_button'),
                      label: formState.isLoading ? 'Saving…' : 'Save',
                      size: AppPillButtonSize.small,
                      onPressed: canSave ? _save : null,
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

/// Scaffold with the Grad-1 page wash (Figma: linear-gradient 154.372deg
/// from #fffcd5 at 19.168% to #f5f5f5 at 50%). Flutter's [LinearGradient]
/// uses begin/end alignments; ~154° clockwise from "up" maps to a top-left
/// → bottom-right diagonal — Alignment.topLeft → Alignment.bottomRight.
class _ProfileEditScaffold extends StatelessWidget {
  const _ProfileEditScaffold({required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.butterSoft,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.19, 0.5],
            colors: [AppColors.butterSoft, _kGradEnd],
          ),
        ),
        child: body,
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sp12,
        AppSizes.sm,
        AppSizes.sp12,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          AppRoundButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
            tone: AppRoundButtonTone.ghost,
            size: AppRoundButtonSize.small,
            semanticLabel: 'Back',
          ),
          const SizedBox(width: AppSizes.sp2),
          Expanded(
            child: Text(
              'Change Profile',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.fgStrong,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditAvatar extends StatelessWidget {
  const _EditAvatar();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: _kEditAvatarSize,
          height: _kEditAvatarSize,
          decoration: const BoxDecoration(
            color: AppColors.coral,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.child_care_rounded,
              // ~74px glyph fits the 143px coral puck while echoing the
              // ProfileScreen avatar proportions (64 glyph in 120 puck).
              size: 74,
              color: AppColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}

/// Field row matching Figma: label (Parkinsans SemiBold 15) then field with
/// an 11px gap. Used in the Profile Edit form for First/Last/Email.
class _LabelledField extends StatelessWidget {
  const _LabelledField({
    required this.label,
    required this.field,
    required this.labelStyle,
  });

  final String label;
  final Widget field;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: _kLabelGap),
        field,
      ],
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
    return _ProfileEditScaffold(
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

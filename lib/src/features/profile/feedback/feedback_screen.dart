import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_controller.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Give Feedback — single multi-line free-text entry + bottom-anchored CTA.
///
/// Mirrors the Figma spec (frames 1207:15273 + 1216:11913):
/// - Cream header (matches the screen background) with a left chevron and
///   left-aligned "Give Feedback" title.
/// - Textarea with placeholder "Your feedback..." and the helper line
///   "Thank you. We read every message." rendered BELOW the field.
/// - Bottom-pinned primary green "Send Feedback" CTA (DS Regular-button).
/// - On submit: full-screen rotating-flower brand loader (shared with the
///   post-onboarding "babysit" setup screen) over butter-soft cream. "Sending"
///   animates trailing dots for the real submit (min-dwell floor so it can't
///   flash), then swaps to "Feedback sent" before the screen auto-dismisses
///   back to Profile.
///
/// Failure stays P2 — a toast prompts a retry on the entry screen and the
/// controller logs a non-fatal Crashlytics breadcrumb.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  /// Floor on how long the spinning loader stays up so a fast Supabase insert
  /// doesn't flash the transition by. Measured from the moment submit starts.
  static const Duration _minLoaderDwell = Duration(milliseconds: 800);

  /// Window the user sees the "Feedback sent" caption for before the screen
  /// auto-pops back to Profile. No dismiss CTA in Figma, so it auto-dismisses.
  static const Duration _successHoldDuration = Duration(milliseconds: 1200);

  /// Times the real submit so we can enforce [_minLoaderDwell] before revealing
  /// the success caption.
  final Stopwatch _loaderStopwatch = Stopwatch();

  /// Gates the "Feedback sent" caption — true only once the insert succeeded
  /// AND the min-dwell floor has elapsed.
  bool _showSent = false;

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Fire screen_view('profile_feedback') once on mount via post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  Future<void> _logScreenView() async {
    try {
      await ref
          .read(analyticsProvider)
          .logScreenView(screenName: 'profile_feedback');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackControllerProvider);

    // submitting + success both render the brand loader; the caption only
    // fades in once [_showSent] flips (success edge + min-dwell, see _submit).
    final inTransition = state.phase != FeedbackPhase.idle;

    return AnimatedSwitcher(
      duration: AppDurations.fade,
      switchInCurve: AppCurves.standard,
      switchOutCurve: AppCurves.standard,
      child: KeyedSubtree(
        key: ValueKey(inTransition),
        child: inTransition
            ? _FeedbackTransitionScreen(showSent: _showSent)
            : _FeedbackEntryScreen(
                message: state.message,
                onBack: _goBack,
                onChanged: ref
                    .read(feedbackControllerProvider.notifier)
                    .updateMessage,
                onSubmit: _submit,
              ),
      ),
    );
  }

  Future<void> _submit() async {
    final controller = ref.read(feedbackControllerProvider.notifier);

    _showSent = false;
    _loaderStopwatch
      ..reset()
      ..start();
    final ok = await controller.submit();
    if (!mounted) return;

    if (!ok) {
      // P2 — non-blocking toast; user can retry without leaving the screen.
      AppToast.error(context, "Couldn't send feedback. Try again.");
      return;
    }

    // Hold the spinning loader until the min-dwell floor is met (so a fast
    // insert doesn't flash), then reveal "Feedback sent" and auto-pop.
    final remaining = _minLoaderDwell - _loaderStopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
      if (!mounted) return;
    }
    setState(() => _showSent = true);
    _dismissTimer?.cancel();
    _dismissTimer = Timer(_successHoldDuration, () {
      if (!mounted) return;
      _goBack();
    });
  }
}

/// Entry artboard (Figma 1207:15273). Pinned-bottom CTA + scrollable body so
/// the keyboard never overlaps the textarea on small screens.
class _FeedbackEntryScreen extends StatelessWidget {
  const _FeedbackEntryScreen({
    required this.message,
    required this.onBack,
    required this.onChanged,
    required this.onSubmit,
  });

  final String message;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final canSubmit = message.trim().isNotEmpty;

    return GradientScaffold(
      // resizeToAvoidBottomInset defaults to true; the inner SafeArea +
      // SingleChildScrollView lets the textarea scroll above the keyboard.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(bottom: false, child: _FeedbackHeader(onBack: onBack)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FeedbackField(initialValue: message, onChanged: onChanged),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Thank you. We read every message.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.fgStrong,
                      fontWeight: FontWeight.w600,
                      height: 1.47,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.md,
              ),
              child: AppPillButton(
                key: const Key('feedback_send_button'),
                label: 'Send Feedback',
                onPressed: canSubmit ? onSubmit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loader + success artboard (Figma 1216:11913). Reuses the same rotating
/// flower loader as the post-onboarding ("babysit") setup screen. While the
/// submit runs, "Sending" animates trailing dots; on success it swaps to the
/// static "Feedback sent" caption before the screen auto-dismisses.
class _FeedbackTransitionScreen extends StatelessWidget {
  const _FeedbackTransitionScreen({required this.showSent});

  final bool showSent;

  @override
  Widget build(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      height: 1.47,
    );

    return Scaffold(
      backgroundColor: AppColors.butterSoft,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandFlowerLoader(blobKey: Key('feedback_loader_blob')),
              const SizedBox(height: AppSizes.lg),
              Semantics(
                liveRegion: true,
                label: showSent ? 'Feedback sent' : 'Sending',
                child: AnimatedSwitcher(
                  duration: AppDurations.fade,
                  switchInCurve: AppCurves.standard,
                  switchOutCurve: AppCurves.standard,
                  child: showSent
                      ? Text(
                          'Feedback sent',
                          key: const Key('feedback_sent_caption'),
                          textAlign: TextAlign.center,
                          style: captionStyle,
                        )
                      : AnimatedEllipsisText(
                          key: const Key('feedback_loading_caption'),
                          text: 'Sending',
                          style: captionStyle,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back chip + "Give Feedback" title over the gradient — no coloured band.
/// Same pattern as the Profile / Edit Profile screen headers.
class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader({required this.onBack});

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
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            tone: AppRoundButtonTone.ghost,
            size: AppRoundButtonSize.small,
            semanticLabel: 'Back',
          ),
          const SizedBox(width: AppSizes.sp2),
          Expanded(
            child: Text(
              'Give Feedback',
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

/// Multiline feedback field — a plain [TextField] with the filled-grey
/// InputDecoration (Figma Input fill, radiusMd, no border). Green cursor is the
/// only focus affordance, matching the Figma which defines no focus state.
class _FeedbackField extends StatefulWidget {
  const _FeedbackField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_FeedbackField> createState() => _FeedbackFieldState();
}

class _FeedbackFieldState extends State<_FeedbackField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      key: const Key('feedback_message_field'),
      controller: _controller,
      onChanged: widget.onChanged,
      minLines: 8,
      maxLines: 12,
      maxLength: 2000,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      cursorColor: AppColors.greenDeep,
      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.fgStrong),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bgInput,
        counterText: '',
        hintText: 'Your feedback...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.fgFaint,
        ),
        contentPadding: const EdgeInsets.all(AppSizes.sp12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

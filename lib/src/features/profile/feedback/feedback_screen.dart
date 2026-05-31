import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_controller.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Give Feedback — single multi-line free-text entry + bottom-anchored CTA.
///
/// Mirrors the Figma spec (frames 1207:15273 + 1216:11913):
/// - Butter-soft header with a left chevron and left-aligned "Give Feedback"
///   title.
/// - Textarea with placeholder "Your feedback..." and the helper line
///   "Thank you. We read every message." rendered BELOW the field.
/// - Bottom-pinned butter pill "Send Feedback" CTA.
/// - On submit: full-screen Nibbles brand mark over butter-soft cream with
///   "Loading" caption that resolves to "Feedback sent!" before the screen
///   auto-dismisses back to Profile.
///
/// Failure stays P2 — a SnackBar prompts a retry on the entry screen and the
/// controller logs a non-fatal Crashlytics breadcrumb.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  /// Window the user sees the "Feedback sent!" success state for before the
  /// screen auto-pops back to Profile. No dismiss CTA in Figma, so the screen
  /// auto-dismisses.
  static const Duration _successHoldDuration = Duration(milliseconds: 1400);

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

    // Schedule the auto-dismiss when we land on the success phase so all
    // listed states (idle / submitting / success) are reachable from the UI
    // before the screen pops back to Profile.
    ref.listen<FeedbackState>(feedbackControllerProvider, (prev, next) {
      if (prev?.phase != FeedbackPhase.success &&
          next.phase == FeedbackPhase.success) {
        _dismissTimer?.cancel();
        _dismissTimer = Timer(_successHoldDuration, () {
          if (!mounted) return;
          _goBack();
        });
      }
    });

    if (state.phase != FeedbackPhase.idle) {
      return _FeedbackTransitionScreen(phase: state.phase);
    }

    return _FeedbackEntryScreen(
      message: state.message,
      onBack: _goBack,
      onChanged: ref.read(feedbackControllerProvider.notifier).updateMessage,
      onSubmit: _submit,
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(feedbackControllerProvider.notifier);
    final ok = await controller.submit();
    if (!mounted) return;

    if (!ok) {
      // P2 — non-blocking toast; user can retry without leaving the screen.
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't send feedback. Try again.")),
      );
    }
    // Success path is handled via the ref.listen above (auto-dismiss).
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

    return Scaffold(
      backgroundColor: AppColors.background,
      // resizeToAvoidBottomInset defaults to true; the inner SafeArea +
      // SingleChildScrollView lets the textarea scroll above the keyboard.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: _FeedbackHeader(onBack: onBack),
          ),
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
                  _FeedbackField(
                    initialValue: message,
                    onChanged: onChanged,
                  ),
                  const SizedBox(height: AppSizes.sp12),
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
                variant: AppPillButtonVariant.ghost,
                onPressed: canSubmit ? onSubmit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loader + success artboard (Figma 1216:11913). Same widget for both because
/// they share layout — only the caption text swaps once the submit resolves.
class _FeedbackTransitionScreen extends StatelessWidget {
  const _FeedbackTransitionScreen({required this.phase});

  final FeedbackPhase phase;

  @override
  Widget build(BuildContext context) {
    final isSuccess = phase == FeedbackPhase.success;
    final caption = isSuccess ? 'Feedback sent!' : 'Loading';

    return Scaffold(
      backgroundColor: AppColors.butterSoft,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _BrandLoaderMark(),
              const SizedBox(height: AppSizes.lg),
              Semantics(
                liveRegion: true,
                label: caption,
                child: Text(
                  caption,
                  key: Key(
                    isSuccess
                        ? 'feedback_sent_caption'
                        : 'feedback_loading_caption',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    height: 1.47,
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

/// Slow-pulse Quatrefoil mark — stands in for the procedural logo loader
/// composition in the Figma artboard (no Lottie/raster asset shipped).
class _BrandLoaderMark extends StatefulWidget {
  const _BrandLoaderMark();

  @override
  State<_BrandLoaderMark> createState() => _BrandLoaderMarkState();
}

class _BrandLoaderMarkState extends State<_BrandLoaderMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(milliseconds: 1200),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.92,
        end: 1.04,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: const Quatrefoil(size: AppSizes.avatarXl + 40),
    );
  }
}

/// Butter-soft header for the Give Feedback screen. Left chevron + left-
/// aligned "Give Feedback" title (Figma 1207:15273 header instance — title is
/// flush-left next to the back button, not centred).
class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader({required this.onBack});

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
          AppRoundButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
            tone: AppRoundButtonTone.ghost,
            size: AppRoundButtonSize.small,
            semanticLabel: 'Back',
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Give Feedback',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.fgStrong,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Multiline textarea matching the kit `.field` fill (bgInput) + radiusMd.
/// Sized for 5-8 visible lines. Placeholder matches the Figma copy exactly.
class _FeedbackField extends StatefulWidget {
  const _FeedbackField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_FeedbackField> createState() => _FeedbackFieldState();
}

class _FeedbackFieldState extends State<_FeedbackField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: focused ? AppColors.surface : AppColors.bgInput,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: focused ? AppColors.greenDeep : AppColors.borderSoft,
          width: focused ? 2 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.18),
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md - 2,
        vertical: AppSizes.sp12,
      ),
      child: Semantics(
        label: 'Feedback message',
        hint: 'Thank you. We read every message.',
        textField: true,
        child: TextField(
          key: const Key('feedback_message_field'),
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          minLines: 6,
          maxLines: 10,
          // Silent 2k cap — there's no counter or helper text in Figma, so we
          // don't surface it visibly, but we still bound the payload size.
          maxLength: 2000,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          cursorColor: AppColors.greenDeep,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.fgStrong),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            counterText: '',
            hintText: 'Your feedback...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgFaint,
            ),
          ),
        ),
      ),
    );
  }
}

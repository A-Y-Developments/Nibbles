import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_controller.dart';
import 'package:nibbles/src/features/profile/widgets/profile_header.dart';

/// Give Feedback screen. Butter-soft "Settings" header, single multiline
/// textarea, helper caption, and a full-width green-deep CTA. Mirrors the
/// ProfileScreen kit pattern — no shell, no bottom nav (full-screen push).
class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackControllerProvider);
    final controller = ref.read(feedbackControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    void goBack() => context.canPop() ? context.pop() : context.go('/home');

    final canSubmit = state.message.trim().isNotEmpty && !state.isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: ColoredBox(
              color: AppColors.butterSoft,
              child: ProfileHeader(onBack: goBack),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.lg,
                AppSizes.pagePaddingH,
                AppSizes.pagePaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Give Feedback',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.fgStrong,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    "Tell us what's working, what's not, or what you'd love "
                    'to see next. We read every message.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.fgMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _FeedbackField(
                    initialValue: state.message,
                    enabled: !state.isSubmitting,
                    onChanged: controller.updateMessage,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Max 2,000 characters.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.fgFaint,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppPillButton(
                    key: const Key('feedback_send_button'),
                    label: state.isSubmitting ? 'Sending…' : 'Send Feedback',
                    onPressed: canSubmit ? () => _submit(context, ref) : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(feedbackControllerProvider.notifier);
    final ok = await controller.submit();
    if (!context.mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      context.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't send feedback. Try again.")),
      );
    }
  }
}

/// Multiline textarea matching the kit `.field` fill (bgInput) + radiusMd.
/// Sized for 5-8 visible lines.
class _FeedbackField extends StatefulWidget {
  const _FeedbackField({
    required this.initialValue,
    required this.enabled,
    required this.onChanged,
  });

  final String initialValue;
  final bool enabled;
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
      child: TextField(
        key: const Key('feedback_message_field'),
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        minLines: 6,
        maxLines: 10,
        maxLength: 2000,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        cursorColor: AppColors.greenDeep,
        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.fgStrong),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          counterText: '',
          hintText: 'Share your thoughts…',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.greenSoft,
          ),
        ),
      ),
    );
  }
}

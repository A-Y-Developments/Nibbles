import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class ProceedConfirmationSheet extends ConsumerStatefulWidget {
  const ProceedConfirmationSheet({
    required this.allergenKey,
    required this.boardItem,
    required this.nextAllergen,
    super.key,
  });

  final String allergenKey;
  final AllergenBoardItem boardItem;
  final Allergen? nextAllergen;

  @override
  ConsumerState<ProceedConfirmationSheet> createState() =>
      _ProceedConfirmationSheetState();
}

class _ProceedConfirmationSheetState
    extends ConsumerState<ProceedConfirmationSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _onConfirm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(allergenDetailControllerProvider(widget.allergenKey).notifier)
        .advanceToNext();

    if (!mounted) return;

    result.when(
      success: (String? nextKey) {
        Navigator.of(context).pop();
        if (nextKey != null) {
          context.goNamed(
            AppRoute.allergenDetail.name,
            pathParameters: {'allergenKey': nextKey},
          );
        } else {
          context.goNamed(AppRoute.allergenComplete.name);
        }
      },
      failure: (_) => setState(() {
        _isLoading = false;
        _errorMessage = "Couldn't save your log. Please try again.";
      }),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allergen = widget.boardItem.allergen;
    final logs = widget.boardItem.logs.take(3).toList();
    final next = widget.nextAllergen;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Center(
              child: Text(allergen.emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: AppSizes.sm),
            Center(
              child: Text(
                '✅ ${allergen.name} passed!',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            ...List.generate(logs.length, (i) {
              final log = logs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    Icon(
                      log.hadReaction
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      color: log.hadReaction
                          ? AppColors.allergenFlagged
                          : AppColors.allergenSafe,
                      size: AppSizes.iconMd,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      'Day ${i + 1} — '
                      '${log.hadReaction ? 'Reaction' : 'No Reaction'}'
                      ' · ${_formatDate(log.logDate)}',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                _errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            FilledButton(
              onPressed: _isLoading ? null : _onConfirm,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Text(
                      next != null
                          ? 'Start ${next.name} ${next.emoji}'
                          : 'Complete Program 🎉',
                    ),
            ),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: Text('Stay on ${allergen.name}'),
            ),
          ],
        ),
      ),
    );
  }
}

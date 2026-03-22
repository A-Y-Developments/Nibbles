import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_state.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/proceed_confirmation_sheet.dart';

class AllergenDetailScreen extends ConsumerWidget {
  const AllergenDetailScreen({required this.allergenKey, super.key});

  final String allergenKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync =
        ref.watch(allergenDetailControllerProvider(allergenKey));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: stateAsync.maybeWhen(
          data: (s) => Text(s.boardItem.allergen.name),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (s) => _DetailBody(allergenKey: allergenKey, detailState: s),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.allergenKey,
    required this.detailState,
  });

  final String allergenKey;
  final AllergenDetailState detailState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canProceed = detailState.boardItem.status == AllergenStatus.safe ||
        detailState.boardItem.status == AllergenStatus.flagged;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder — full detail UI is built in NIB-23
          Expanded(
            child: Center(
              child: Text('Allergen Detail — $allergenKey'),
            ),
          ),
          if (canProceed) ...[
            FilledButton(
              onPressed: () => _showProceedSheet(context),
              child: Text(
                detailState.nextAllergen != null
                    ? 'Proceed to Next Allergen'
                    : 'Complete Program',
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ],
      ),
    );
  }

  void _showProceedSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => ProceedConfirmationSheet(
        allergenKey: allergenKey,
        boardItem: detailState.boardItem,
        nextAllergen: detailState.nextAllergen,
      ),
    );
  }
}

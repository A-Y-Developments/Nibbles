import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_controller.dart';
import 'package:nibbles/src/features/shopping_list/widgets/add_ingredient_card.dart';
import 'package:nibbles/src/features/shopping_list/widgets/clear_all_confirm_sheet.dart';
import 'package:nibbles/src/features/shopping_list/widgets/shopping_list_menu.dart';
import 'package:nibbles/src/features/shopping_list/widgets/swipe_reveal_row.dart';

/// Shopping List root screen — Figma frames 971:9851 (populated),
/// 971:9989 (empty), 971:9872 (add-card overlay), 971:9915 (swipe-delete).
/// Header (Title 3/Bold + "+" add chip + green-deep more_horiz chip) +
/// segmented control (List / Bought) + ingredient rows.
///
/// Background: Grad-1 (linear-gradient 154.398deg, butterSoft → cream)
/// matching the recipe library Grad-1 mapping.
///
/// Header overflow chip opens a floating dropdown menu (971:9889 / 971:9936)
/// with two actions:
///   * "Copy to Clipboard" — copies the active List items as a bulleted
///     string via the controller; surfaces a P2 toast on success/failure.
///   * "Clear shopping list" — opens the Clear-All confirmation sheet
///     (971:9958). Confirm calls the controller's `clearAll` and drops back
///     to the empty state; cancel dismisses the sheet.
///
/// Per-row trailing close-X commits delete directly (no confirm modal).
/// Swipe-left reveals a burgundy Delete pill; tap commits delete.
/// "+" chip opens the Add Ingredients bottom sheet over the keyboard
/// (NIB-81 — frames 971:9872 / 971:9915).
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        resizeToAvoidBottomInset: false,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const GradientScaffold(
        resizeToAvoidBottomInset: false,
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const GradientScaffold(
            resizeToAvoidBottomInset: false,
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return GradientScaffold(
          resizeToAvoidBottomInset: false,
          body: _ShoppingListBody(babyId: babyId),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ShoppingListBody extends ConsumerStatefulWidget {
  const _ShoppingListBody({required this.babyId});

  final String babyId;

  @override
  ConsumerState<_ShoppingListBody> createState() => _ShoppingListBodyState();
}

class _ShoppingListBodyState extends ConsumerState<_ShoppingListBody> {
  int _selectedTab = 0; // 0 = List, 1 = Bought

  // Controller that tracks which row (by id) currently has its swipe
  // reveal open. Allows tap-outside-to-close and one-open-at-a-time.
  final SwipeRevealController _swipeController = SwipeRevealController();

  final TextEditingController _addController = TextEditingController();
  final FocusNode _addFocusNode = FocusNode();

  @override
  void dispose() {
    _swipeController.dispose();
    _addController.dispose();
    _addFocusNode.dispose();
    super.dispose();
  }

  Future<void> _showClearConfirmation() async {
    final confirmed = await showClearAllConfirmSheet(context);
    if (confirmed != true || !mounted) return;
    await _runWrite(
      ref.read(shoppingListControllerProvider(widget.babyId).notifier).clearAll,
      errorMessage: "Couldn't clear list. Try again.",
    );
  }

  Future<void> _copyToClipboard() async {
    final ok = await ref
        .read(shoppingListControllerProvider(widget.babyId).notifier)
        .copyToClipboard();
    if (!mounted) return;
    _showToast(ok ? 'Copied to clipboard' : "Couldn't copy. Try again.");
  }

  Future<void> _runWrite(
    Future<void> Function() action, {
    required String errorMessage,
  }) async {
    try {
      await action();
    } on Exception catch (_) {
      if (!mounted) return;
      _showToast(errorMessage);
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
  }

  Future<void> _delete(String itemId) async {
    _swipeController.close();
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .delete(itemId);
    } on Exception catch (_) {
      if (!mounted) return;
      _showToast("Couldn't delete item. Try again.");
    }
  }

  Future<void> _check(String itemId) async {
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .check(itemId);
    } on Exception catch (_) {
      if (!mounted) return;
      _showToast("Couldn't update item. Try again.");
    }
  }

  Future<void> _uncheck(String itemId) async {
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .uncheck(itemId);
    } on Exception catch (_) {
      if (!mounted) return;
      _showToast("Couldn't update item. Try again.");
    }
  }

  void _openAddCard() {
    _swipeController.close();
    showAddIngredientSheet(
      context,
      controller: _addController,
      focusNode: _addFocusNode,
      onAdd: _submitAdd,
    ).whenComplete(_addController.clear);
  }

  Future<void> _submitAdd() async {
    final raw = _addController.text;
    if (raw.trim().isEmpty) return;
    _addController.clear();
    if (mounted) Navigator.of(context).pop();

    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .addManual(raw);
    } on Exception catch (_) {
      if (!mounted) return;
      _showToast("Couldn't add items. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(
      shoppingListControllerProvider(widget.babyId),
    );

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Tap anywhere outside the add card / open swipe row to dismiss them.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _swipeController.close,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                0,
              ),
              child: Column(
                children: [
                  _ShoppingListHeader(
                    onAddPressed: _openAddCard,
                    onMenuSelected: (action) {
                      switch (action) {
                        case ShoppingListMenuAction.copy:
                          _copyToClipboard();
                        case ShoppingListMenuAction.clear:
                          _showClearConfirmation();
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.sp12),
                  _ListBoughtTabs(
                    selectedIndex: _selectedTab,
                    onChanged: (i) => setState(() => _selectedTab = i),
                  ),
                  const SizedBox(height: AppSizes.sp12),
                  Expanded(
                    child: controllerAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => _ErrorState(
                        onRetry: () => ref.invalidate(
                          shoppingListControllerProvider(widget.babyId),
                        ),
                      ),
                      data: (state) => _selectedTab == 0
                          ? _ItemsList(
                              items: state.listItems,
                              swipeController: _swipeController,
                              onToggle: _check,
                              onDelete: _delete,
                            )
                          : _ItemsList(
                              items: state.boughtItems,
                              swipeController: _swipeController,
                              onToggle: _uncheck,
                              onDelete: _delete,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header — title + "+" add chip + green-deep more_horiz overflow chip
// ---------------------------------------------------------------------------

class _ShoppingListHeader extends StatelessWidget {
  const _ShoppingListHeader({
    required this.onAddPressed,
    required this.onMenuSelected,
  });

  final VoidCallback onAddPressed;
  final ValueChanged<ShoppingListMenuAction> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Shopping List',
            style: AppTypography.textTheme.titleSmall,
          ),
        ),
        _AddChip(onTap: onAddPressed),
        const SizedBox(width: AppSizes.sm),
        PopupMenuButton<ShoppingListMenuAction>(
          tooltip: 'More options',
          position: PopupMenuPosition.under,
          offset: const Offset(0, AppSizes.sm),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          onSelected: onMenuSelected,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: ShoppingListMenuAction.copy,
              child: _MenuItemContent(
                icon: Icons.copy,
                label: 'Copy to Clipboard',
              ),
            ),
            PopupMenuItem(
              value: ShoppingListMenuAction.clear,
              child: _MenuItemContent(
                icon: Icons.delete_outline,
                label: 'Clear shopping list',
              ),
            ),
          ],
          child: const _OverflowChip(),
        ),
      ],
    );
  }
}

/// Leading-icon + label row used inside the native overflow [PopupMenuButton].
class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.text),
        const SizedBox(width: AppSizes.sm),
        Text(label, style: AppTypography.textTheme.bodyLarge),
      ],
    );
  }
}

/// 40x40 green-deep rounded-square chip with "+" icon. Opens the floating
/// Add Ingredient card. Mirrors the header chip treatment in 971:9872.
class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add ingredient',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.greenDeep,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add,
            color: AppColors.onGreen,
            size: AppSizes.iconMd,
            semanticLabel: '',
          ),
        ),
      ),
    );
  }
}

/// 40x40 green-deep rounded-square chip hosting the more_horiz overflow.
/// Used as the child of the header's native overflow PopupMenuButton.
/// Mirrors Figma 971:9858 / 971:9943 (Button-chips, bg ForestDarkn, rounded-[10px]).
class _OverflowChip extends StatelessWidget {
  const _OverflowChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.greenDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.more_horiz,
        color: AppColors.onGreen,
        size: AppSizes.iconMd,
        semanticLabel: '',
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List / Bought tabs — native CupertinoSlidingSegmentedControl (Figma 962:6668)
//   Track borderSoft, forest thumb, Parkinsans SemiBold 15/22 labels.
//   LayoutBuilder + per-segment SizedBox forces the control to span full width
//   (the native control otherwise hugs its content).
// ---------------------------------------------------------------------------

class _ListBoughtTabs extends StatelessWidget {
  const _ListBoughtTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double _trackPadding = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = (constraints.maxWidth - _trackPadding * 2) / 2;
        return CupertinoSlidingSegmentedControl<int>(
          groupValue: selectedIndex,
          backgroundColor: AppColors.borderSoft,
          thumbColor: AppColors.green,
          padding: const EdgeInsets.all(_trackPadding),
          onValueChanged: (value) {
            if (value != null) onChanged(value);
          },
          children: {
            0: _SegmentLabel(
              label: 'List',
              active: selectedIndex == 0,
              width: segmentWidth,
            ),
            1: _SegmentLabel(
              label: 'Bought',
              active: selectedIndex == 1,
              width: segmentWidth,
            ),
          },
        );
      },
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.label,
    required this.active,
    required this.width,
  });

  final String label;
  final bool active;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FontFamily.parkinsans,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 22 / 15,
            color: active ? AppColors.onGreen : AppColors.green,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List body
// ---------------------------------------------------------------------------

class _ItemsList extends StatelessWidget {
  const _ItemsList({
    required this.items,
    required this.swipeController,
    required this.onToggle,
    required this.onDelete,
  });

  final List<ShoppingListItem> items;
  final SwipeRevealController swipeController;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sp12),
      itemBuilder: (_, index) {
        final item = items[index];
        // Optimistic placeholder id=='' would collide if multiple are pending;
        // fall back to a createdAt-based key.
        final rowKey = item.id.isNotEmpty
            ? item.id
            : 'pending-${item.createdAt.microsecondsSinceEpoch}';
        return SwipeRevealRow(
          key: ValueKey(rowKey),
          rowId: rowKey,
          controller: swipeController,
          onDelete: () => onDelete(item.id),
          child: _ShoppingItemRow(
            item: item,
            onToggle: () => onToggle(item.id),
            onDelete: () => onDelete(item.id),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Row — Figma 822:7262 List variant
//   White card, rounded-10, custom 30x30 square checkbox (greenDeep border),
//   label (body/regular), trailing 37x37 cancel chip.
// ---------------------------------------------------------------------------

class _ShoppingItemRow extends StatelessWidget {
  const _ShoppingItemRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingListItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const double _checkboxSize = 30;
  static const double _cancelChipSize = 37;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        checked: item.isChecked,
        label: item.name,
        onTap: onToggle,
        container: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sp12,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            // Figma 822:7262 — rows are elevated white cards on the Grad-1
            // background; the shadow makes them pop vs a flat fill.
            boxShadow: AppSizes.shadowCard,
          ),
          child: Row(
            children: [
              _SquareCheckbox(
                value: item.isChecked,
                onTap: onToggle,
                size: _checkboxSize,
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.isChecked ? AppColors.fgMuted : AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sp12),
              Semantics(
                button: true,
                label: 'Delete ${item.name}',
                hint: 'Removes this item from the list',
                child: _CancelChip(onTap: onDelete, size: _cancelChipSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom square checkbox — 30x30 visual, 48x48 touch target.
/// Mirrors Figma 871:7708 (Checkbox/default).
class _SquareCheckbox extends StatelessWidget {
  const _SquareCheckbox({
    required this.value,
    required this.onTap,
    required this.size,
  });

  final bool value;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: AppSizes.xxl,
        height: AppSizes.xxl,
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value ? AppColors.greenDeep : AppColors.cream,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.greenDeep, width: 1.5),
            ),
            alignment: Alignment.center,
            child: value
                ? const Icon(Icons.check, size: 18, color: AppColors.onGreen)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Per-row cancel chip — 37x37 visual, 48x48 touch target.
/// Mirrors Figma 898:18568 (cancel) inside Button-chips wrapper.
/// Single-tap directly commits delete — no confirm dialog (NIB-81).
class _CancelChip extends StatelessWidget {
  const _CancelChip({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: AppSizes.xxl,
        height: AppSizes.xxl,
        child: Center(
          child: SizedBox(
            width: size,
            height: size,
            child: const Center(
              child: Icon(
                Icons.cancel,
                color: AppColors.burgundy,
                size: AppSizes.iconMd,
                semanticLabel: '',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state — Figma 971:9989
//   Centered brand flower + verbatim caption, no CTA.
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandFlower(size: 153),
          // Figma 971:9989 empty-state gap-[10px] (no 10px spacing token).
          const SizedBox(height: 10),
          Text(
            'You don’t have any list yet',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error retry
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load shopping list.',
              style: AppTypography.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.sm),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_controller.dart';
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
/// The header "+" chip reveals an inline add card docked at the bottom of the
/// List tab (971:9872) — a borderless, centered "Ingredients" field (autofocus)
/// under a butter "Add" pill. Tapping "Add" commits the trimmed name via the
/// controller and clears the field, keeping focus for rapid entry; blanks are
/// ignored. The card auto-hides when the field loses focus (tap-away / keyboard
/// dismiss).
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const GradientScaffold(
        resizeToAvoidBottomInset: false,
        body: Center(child: BrandFlowerLoader.small()),
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

  // Separate controllers per tab: the tab-swap AnimatedSwitcher briefly keeps
  // both _ItemsList instances mounted, and a ScrollController cannot attach to
  // two scroll views at once.
  final ScrollController _listScrollController = ScrollController();
  final ScrollController _boughtScrollController = ScrollController();

  // Inline add card — revealed by the header "+", auto-hidden on focus loss.
  final TextEditingController _addController = TextEditingController();
  final FocusNode _addFocusNode = FocusNode();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _addFocusNode.addListener(_onAddFocusChange);
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _listScrollController.dispose();
    _boughtScrollController.dispose();
    _addFocusNode
      ..removeListener(_onAddFocusChange)
      ..dispose();
    _addController.dispose();
    super.dispose();
  }

  void _startAdding() {
    setState(() {
      _selectedTab = 0;
      _adding = true;
    });
  }

  void _onAddFocusChange() {
    if (!_addFocusNode.hasFocus && _adding) {
      _addController.clear();
      setState(() => _adding = false);
    }
  }

  void _submitAddField() {
    final name = _addController.text.trim();
    if (name.isEmpty) return;
    _submitItem(name);
    _addController.clear();
    _addFocusNode.requestFocus();
  }

  Future<void> _showClearConfirmation() async {
    final confirmed = await showClearAllConfirmSheet(context);
    if (confirmed != true || !mounted) return;
    await _runWrite(
      ref.read(shoppingListControllerProvider(widget.babyId).notifier).clearAll,
      errorMessage: "Couldn't clear list. Try again.",
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(shoppingListControllerProvider(widget.babyId));
    await ref.read(shoppingListControllerProvider(widget.babyId).future);
  }

  Future<void> _copyToClipboard() async {
    final ok = await ref
        .read(shoppingListControllerProvider(widget.babyId).notifier)
        .copyToClipboard();
    if (!mounted) return;
    if (ok) {
      _showToast('Copied to clipboard', isError: false);
    } else {
      _showToast("Couldn't copy. Try again.");
    }
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

  void _showToast(String message, {bool isError = true}) {
    if (isError) {
      AppToast.error(context, message);
    } else {
      AppToast.success(context, message);
    }
  }

  Future<void> _delete(String itemId, {required String via}) async {
    _swipeController.close();
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .delete(itemId, via: via);
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

  Future<void> _submitItem(String raw) async {
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
          // Tap anywhere outside the add card / open swipe row to dismiss both.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _swipeController.close();
              _addFocusNode.unfocus();
            },
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
                    onAddPressed: _startAdding,
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
                  AppSlidingSegmentedControl(
                    segments: const ['List', 'Bought'],
                    selectedIndex: _selectedTab,
                    onChanged: (i) {
                      _addFocusNode.unfocus();
                      setState(() => _selectedTab = i);
                    },
                  ),
                  const SizedBox(height: AppSizes.sp12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppDurations.fade,
                      switchInCurve: AppCurves.standard,
                      switchOutCurve: AppCurves.standard,
                      child: controllerAsync.when(
                        loading: () => const Center(
                          key: ValueKey('shopping-loading'),
                          child: BrandFlowerLoader.small(),
                        ),
                        error: (e, _) => _ErrorState(
                          key: const ValueKey('shopping-error'),
                          onRetry: () => ref.invalidate(
                            shoppingListControllerProvider(widget.babyId),
                          ),
                        ),
                        data: (state) => BrandRefreshIndicator(
                          key: ValueKey('shopping-refresh-$_selectedTab'),
                          onRefresh: _refresh,
                          child: _selectedTab == 0
                              ? _ItemsList(
                                  key: const ValueKey('shopping-list-active'),
                                  items: state.listItems,
                                  swipeController: _swipeController,
                                  scrollController: _listScrollController,
                                  onToggle: _check,
                                  onDelete: _delete,
                                )
                              : _ItemsList(
                                  key: const ValueKey('shopping-list-bought'),
                                  items: state.boughtItems,
                                  swipeController: _swipeController,
                                  scrollController: _boughtScrollController,
                                  onToggle: _uncheck,
                                  onDelete: _delete,
                                ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: AppDurations.slide,
                    curve: AppCurves.emphasized,
                    alignment: Alignment.topCenter,
                    child: (_selectedTab == 0 && _adding)
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: AppSizes.sm,
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom +
                                  AppSizes.sp20,
                            ),
                            child: _AddCard(
                              controller: _addController,
                              focusNode: _addFocusNode,
                              onAdd: _submitAddField,
                            ),
                          )
                        : const SizedBox(
                            width: double.infinity,
                            height: AppSizes.sm,
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

/// 40x40 green-deep rounded-square chip hosting the more_horiz overflow.
/// Used as the child of the header's native overflow PopupMenuButton.
/// Mirrors Figma 971:9858 / 971:9943 (Button-chips, bg ForestDarkn, rounded-[10px]).
class _OverflowChip extends StatelessWidget {
  const _OverflowChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.roundButtonMd,
      height: AppSizes.roundButtonMd,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
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

/// Green-deep circular chip hosting the add "+".
/// Mirrors [_OverflowChip]; reveals the inline add card on tap.
class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add ingredient',
      child: Material(
        color: AppColors.greenDeep,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: AppSizes.roundButtonMd,
            height: AppSizes.roundButtonMd,
            child: Icon(
              Icons.add,
              color: AppColors.onGreen,
              size: AppSizes.iconMd,
              semanticLabel: '',
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline add card — Figma 971:9872. Revealed by the header "+" chip; a
// borderless, centered "Ingredients" field (autofocus) under a butter "Add"
// pill. Bespoke to this screen: the field has no fill or border by design.
// ---------------------------------------------------------------------------

class _AddCard extends StatelessWidget {
  const _AddCard({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final fieldStyle = AppTypography.textTheme.bodyLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sp12,
        AppSizes.md,
        AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius3xl),
        boxShadow: AppSizes.shadowCardLifted,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppPillButton(
                label: 'Add',
                variant: AppPillButtonVariant.ghost,
                size: AppPillButtonSize.small,
                expand: false,
                onPressed: onAdd,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => onAdd(),
            style: fieldStyle,
            cursorColor: AppColors.greenDeep,
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: 'Ingredients',
              hintStyle: fieldStyle?.copyWith(color: AppColors.fgFaint),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List body
// ---------------------------------------------------------------------------

/// Stable-keyed model entry backing the [AnimatedList]. [key] persists across
/// the optimistic placeholder → server-item swap so the row updates in place
/// (id filled, no re-animation) rather than fading out and back in.
class _AnimatedEntry {
  _AnimatedEntry(this.key, this.item);

  final String key;
  ShoppingListItem item;
}

/// Ingredient list with fade + collapse animations on add / remove.
///
/// Native [AnimatedList] (Material) driven by a diff of the reactive [items]
/// against a locally-held keyed model. Adds fade+slide in; deletes (and checks,
/// which drop an item off the List tab) fade+collapse out. The last item
/// removed snaps to the empty state rather than animating.
class _ItemsList extends StatefulWidget {
  const _ItemsList({
    required this.items,
    required this.swipeController,
    required this.scrollController,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final List<ShoppingListItem> items;
  final SwipeRevealController swipeController;
  final ScrollController scrollController;
  final ValueChanged<String> onToggle;
  final void Function(String itemId, {required String via}) onDelete;

  @override
  State<_ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<_ItemsList> {
  static const Duration _animDuration = Duration(milliseconds: 240);

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<_AnimatedEntry> _entries = [];
  int _keySeq = 0;

  @override
  void initState() {
    super.initState();
    for (final item in widget.items) {
      _entries.add(_AnimatedEntry(_nextKey(), item));
    }
  }

  @override
  void didUpdateWidget(covariant _ItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(widget.items);
  }

  String _nextKey() => 'e${_keySeq++}';

  /// Reconcile [incoming] into [_entries], animating insertions and removals.
  /// Items keep their relative order (both tabs sort by createdAt desc), so a
  /// left-to-right insert pass keeps [_entries] and the [AnimatedList] in sync
  /// without needing to handle reorders.
  void _sync(List<ShoppingListItem> incoming) {
    final matched = <int, _AnimatedEntry>{};
    final used = <_AnimatedEntry>{};

    for (var i = 0; i < incoming.length; i++) {
      final it = incoming[i];
      if (it.id.isEmpty) continue;
      for (final e in _entries) {
        if (!used.contains(e) && e.item.id == it.id) {
          matched[i] = e;
          used.add(e);
          break;
        }
      }
    }

    // Reconcile the just-added optimistic placeholder (id=='') against its
    // server-assigned row by name so the swap is an in-place update.
    for (var i = 0; i < incoming.length; i++) {
      if (matched.containsKey(i)) continue;
      final it = incoming[i];
      for (final e in _entries) {
        if (!used.contains(e) && e.item.id.isEmpty && e.item.name == it.name) {
          matched[i] = e;
          used.add(e);
          break;
        }
      }
    }

    for (var idx = _entries.length - 1; idx >= 0; idx--) {
      final e = _entries[idx];
      if (used.contains(e)) continue;
      _entries.removeAt(idx);
      _listKey.currentState?.removeItem(
        idx,
        (context, animation) => _buildRow(e, animation, active: false),
        duration: _animDuration,
      );
    }

    for (var i = 0; i < incoming.length; i++) {
      final e = matched[i];
      if (e != null) {
        e.item = incoming[i];
      } else {
        final entry = _AnimatedEntry(_nextKey(), incoming[i]);
        _entries.insert(i, entry);
        _listKey.currentState?.insertItem(i, duration: _animDuration);
      }
    }
  }

  Widget _buildRow(
    _AnimatedEntry entry,
    Animation<double> animation, {
    required bool active,
  }) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final item = entry.item;
    final row = Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sp12),
      child: active
          ? SwipeRevealRow(
              key: ValueKey(entry.key),
              rowId: entry.key,
              controller: widget.swipeController,
              onDelete: () => widget.onDelete(item.id, via: 'swipe'),
              child: _ShoppingItemRow(
                item: item,
                onToggle: () => widget.onToggle(item.id),
                onDelete: () => widget.onDelete(item.id, via: 'button'),
              ),
            )
          : _ShoppingItemRow(item: item, onToggle: () {}, onDelete: () {}),
    );
    return FadeTransition(
      opacity: curved,
      child: SizeTransition(sizeFactor: curved, axisAlignment: -1, child: row),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Empty state stays pull-to-refresh–able: a viewport-tall scrollable keeps
    // the flower reachable even with no rows.
    if (widget.items.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const _EmptyState(),
          ),
        ),
      );
    }
    return AnimatedList(
      key: _listKey,
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      initialItemCount: _entries.length,
      itemBuilder: (context, index, animation) =>
          _buildRow(_entries[index], animation, active: true),
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
                child: AnimatedDefaultTextStyle(
                  duration: AppDurations.base,
                  curve: AppCurves.standard,
                  style:
                      (AppTypography.textTheme.bodyLarge ?? const TextStyle())
                          .copyWith(
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: item.isChecked
                                ? AppColors.fgMuted
                                : AppColors.text,
                          ),
                  child: Text(item.name),
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
          child: AnimatedContainer(
            duration: AppDurations.base,
            curve: AppCurves.standard,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value ? AppColors.greenDeep : AppColors.cream,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greenDeep, width: 1.5),
            ),
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: value ? 1 : 0,
              duration: AppDurations.base,
              curve: AppCurves.emphasized,
              child: const Icon(
                Icons.check,
                size: 18,
                color: AppColors.onGreen,
              ),
            ),
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandFlower(size: AppSizes.avatarXl),
          SizedBox(height: AppSizes.md),
          Text(
            'You don’t have any list yet',
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitle,
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
  const _ErrorState({required this.onRetry, super.key});

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

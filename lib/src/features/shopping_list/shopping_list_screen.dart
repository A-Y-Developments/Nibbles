import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_controller.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _ShoppingListBody(babyId: babyId);
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

class _ShoppingListBodyState extends ConsumerState<_ShoppingListBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showClearConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Clear list',
        message: 'This will delete all items. Are you sure?',
      ),
    );
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
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync =
        ref.watch(shoppingListControllerProvider(widget.babyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Shopping List',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          PopupMenuButton<_MenuAction>(
            icon: const Icon(Icons.more_vert, color: AppColors.text),
            onSelected: (action) {
              switch (action) {
                case _MenuAction.copy:
                  _copyToClipboard();
                case _MenuAction.clear:
                  _showClearConfirmation();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _MenuAction.copy,
                child: Text('Copy to clipboard'),
              ),
              PopupMenuItem(
                value: _MenuAction.clear,
                child: Text('Clear list'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtext,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'List'),
            Tab(text: 'Bought'),
          ],
        ),
      ),
      body: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load shopping list.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    shoppingListControllerProvider(widget.babyId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (state) => TabBarView(
          controller: _tabController,
          children: [
            _ListTab(
              state: state,
              babyId: widget.babyId,
              onAddFailed: () => _showToast("Couldn't add items. Try again."),
              onDeleteFailed: () =>
                  _showToast("Couldn't delete item. Try again."),
              onCheckFailed: () =>
                  _showToast("Couldn't update item. Try again."),
            ),
            _BoughtTab(
              state: state,
              babyId: widget.babyId,
              onUncheckFailed: () =>
                  _showToast("Couldn't update item. Try again."),
              onDeleteFailed: () =>
                  _showToast("Couldn't delete item. Try again."),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MenuAction { copy, clear }

// ---------------------------------------------------------------------------
// List Tab (unchecked items)
// ---------------------------------------------------------------------------

class _ListTab extends ConsumerStatefulWidget {
  const _ListTab({
    required this.state,
    required this.babyId,
    required this.onAddFailed,
    required this.onDeleteFailed,
    required this.onCheckFailed,
  });

  final ShoppingListState state;
  final String babyId;
  final VoidCallback onAddFailed;
  final VoidCallback onDeleteFailed;
  final VoidCallback onCheckFailed;

  @override
  ConsumerState<_ListTab> createState() => _ListTabState();
}

class _ListTabState extends ConsumerState<_ListTab> {
  final _textController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _textController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isAdding = true);
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .addManual(name);
      _textController.clear();
    } on Exception catch (_) {
      widget.onAddFailed();
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _check(String itemId) async {
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .check(itemId);
    } on Exception catch (_) {
      widget.onCheckFailed();
    }
  }

  Future<void> _deleteDirect(String itemId) async {
    try {
      await ref
          .read(shoppingListControllerProvider(widget.babyId).notifier)
          .delete(itemId);
    } on Exception catch (_) {
      widget.onDeleteFailed();
    }
  }

  Future<void> _deleteWithConfirm(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Delete item',
        message: "Are you sure you want to delete? You can't restore it.",
      ),
    );
    if (confirmed != true) return;
    await _deleteDirect(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.state.listItems;

    return Column(
      children: [
        // Add input
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Add an item...',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.hint),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              SizedBox(
                height: AppSizes.buttonHeightSm,
                child: FilledButton(
                  onPressed: _isAdding ? null : _add,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Add'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // List
        Expanded(
          child: items.isEmpty
              ? _ListEmptyState(
                  onBrowseRecipes: () => context.goNamed(
                    AppRoute.recipeLibrary.name,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.sm,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return _ShoppingItemTile(
                      item: item,
                      onToggle: () => _check(item.id),
                      onDeleteDirect: () => _deleteDirect(item.id),
                      onDeleteWithConfirm: () => _deleteWithConfirm(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bought Tab (checked items)
// ---------------------------------------------------------------------------

class _BoughtTab extends ConsumerWidget {
  const _BoughtTab({
    required this.state,
    required this.babyId,
    required this.onUncheckFailed,
    required this.onDeleteFailed,
  });

  final ShoppingListState state;
  final String babyId;
  final VoidCallback onUncheckFailed;
  final VoidCallback onDeleteFailed;

  Future<void> _uncheck(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    try {
      await ref
          .read(shoppingListControllerProvider(babyId).notifier)
          .uncheck(itemId);
    } on Exception catch (_) {
      onUncheckFailed();
    }
  }

  Future<void> _deleteDirect(
    WidgetRef ref,
    String itemId,
  ) async {
    try {
      await ref
          .read(shoppingListControllerProvider(babyId).notifier)
          .delete(itemId);
    } on Exception catch (_) {
      onDeleteFailed();
    }
  }

  Future<void> _deleteWithConfirm(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Delete item',
        message: "Are you sure you want to delete? You can't restore it.",
      ),
    );
    if (confirmed != true) return;
    await _deleteDirect(ref, itemId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = state.boughtItems;

    if (items.isEmpty) {
      return const _BoughtEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (_, index) {
        final item = items[index];
        return _ShoppingItemTile(
          item: item,
          onToggle: () => _uncheck(context, ref, item.id),
          onDeleteDirect: () => _deleteDirect(ref, item.id),
          onDeleteWithConfirm: () => _deleteWithConfirm(context, ref, item.id),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared item tile
// ---------------------------------------------------------------------------

class _ShoppingItemTile extends StatelessWidget {
  const _ShoppingItemTile({
    required this.item,
    required this.onToggle,
    // Called after swipe-confirm — no dialog needed, already confirmed.
    required this.onDeleteDirect,
    // Called by trash icon — shows confirmation dialog.
    required this.onDeleteWithConfirm,
  });

  final ShoppingListItem item;
  final VoidCallback onToggle;
  final VoidCallback onDeleteDirect;
  final VoidCallback onDeleteWithConfirm;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: AppColors.onError),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (_) => const _ConfirmDialog(
            title: 'Delete item',
            message: "Are you sure you want to delete? You can't restore it.",
          ),
        );
      },
      onDismissed: (_) => onDeleteDirect(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.xs,
        ),
        leading: Checkbox(
          value: item.isChecked,
          activeColor: AppColors.primary,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          item.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration:
                    item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? AppColors.subtext : AppColors.text,
              ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: AppSizes.iconMd),
          color: AppColors.hint,
          onPressed: onDeleteWithConfirm,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty states
// ---------------------------------------------------------------------------

class _ListEmptyState extends StatelessWidget {
  const _ListEmptyState({required this.onBrowseRecipes});

  final VoidCallback onBrowseRecipes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSizes.md),
            Text(
              "It seems you don't have any shopping list :(",
              style: textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(
              onPressed: onBrowseRecipes,
              child: Text(
                'Browse recipes to get started',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoughtEmptyState extends StatelessWidget {
  const _BoughtEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSizes.md),
            Text(
              'No items bought yet.',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable confirm dialog
// ---------------------------------------------------------------------------

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(title, style: textTheme.titleMedium),
      content: Text(message, style: textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Yes'),
        ),
      ],
    );
  }
}

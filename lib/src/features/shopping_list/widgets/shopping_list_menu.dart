import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Actions surfaced by [ShoppingListOverflowMenu].
enum ShoppingListMenuAction { copy, clear }

/// Floating dropdown menu anchored to the Shopping List header overflow chip
/// (Figma 971:9889 / 971:9936 — Overlay Menu - Input).
///
/// White card 262 wide, pad-12, gap-4 between rows, rounded-10 with a soft
/// drop shadow. Each row is a px-12 py-6 rounded-6 button containing an
/// 18px leading icon + Figtree Body/Regular 15/22 label. The pressed/hover
/// row fills lime (`AppColors.butter`).
///
/// Wrap the trigger in [ShoppingListOverflowMenu] and pass the trigger as
/// [child]; tapping the child opens the menu, tapping outside dismisses.
class ShoppingListOverflowMenu extends StatefulWidget {
  const ShoppingListOverflowMenu({
    required this.onSelected,
    required this.child,
    super.key,
  });

  final ValueChanged<ShoppingListMenuAction> onSelected;
  final Widget child;

  @override
  State<ShoppingListOverflowMenu> createState() =>
      _ShoppingListOverflowMenuState();
}

class _ShoppingListOverflowMenuState extends State<ShoppingListOverflowMenu> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  static const double _menuWidth = 262;
  static const double _menuOffsetY = 8;

  void _toggle() {
    if (_controller.isShowing) {
      _controller.hide();
    } else {
      _controller.show();
    }
  }

  void _handleSelected(ShoppingListMenuAction action) {
    _controller.hide();
    widget.onSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (overlayContext) {
          return Stack(
            children: [
              // Tap-outside dismiss.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _controller.hide,
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                offset: const Offset(0, _menuOffsetY),
                child: _MenuCard(
                  width: _menuWidth,
                  onSelected: _handleSelected,
                ),
              ),
            ],
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: widget.child,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.width, required this.onSelected});

  final double width;
  final ValueChanged<ShoppingListMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppSizes.sp12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A6E6E6E),
              offset: Offset(0, 4),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuRow(
              icon: Icons.add,
              label: 'Copy to Clipboard',
              onTap: () => onSelected(ShoppingListMenuAction.copy),
            ),
            const SizedBox(height: AppSizes.xs),
            _MenuRow(
              icon: Icons.delete_outline,
              label: 'Clear All Shopping List',
              onTap: () => onSelected(ShoppingListMenuAction.clear),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          // Press feedback is a neutral wash, not lime — pressing a row
          // must not flash yellow (backlog #6).
          color: _pressed ? AppColors.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 18, color: AppColors.text),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                widget.label,
                style: AppTypography.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

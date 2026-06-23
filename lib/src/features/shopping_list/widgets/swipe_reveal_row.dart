import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Width of the burgundy Delete pill revealed behind the row.
const double _deleteRevealWidth = 100;

/// Shared controller that tracks which row currently has its swipe
/// revealed. Only one row can be open at a time, and any tap outside
/// the open row closes it.
class SwipeRevealController extends ChangeNotifier {
  String? _openRowId;
  String? get openRowId => _openRowId;

  void open(String rowId) {
    if (_openRowId == rowId) return;
    _openRowId = rowId;
    notifyListeners();
  }

  void close() {
    if (_openRowId == null) return;
    _openRowId = null;
    notifyListeners();
  }
}

/// Wraps a shopping-list row with a swipe-to-reveal Delete pill.
///
/// Figma 971:9915 (Shoplist - slide delete): user drags the row left,
/// the row compresses, and a burgundy Delete pill is revealed beside it.
/// Tap on the pill commits delete. Only one row can be open at a time —
/// opening a new one closes the previous. Tap outside closes too.
class SwipeRevealRow extends StatefulWidget {
  const SwipeRevealRow({
    required this.rowId,
    required this.controller,
    required this.onDelete,
    required this.child,
    super.key,
  });

  final String rowId;
  final SwipeRevealController controller;
  final VoidCallback onDelete;
  final Widget child;

  @override
  State<SwipeRevealRow> createState() => _SwipeRevealRowState();
}

class _SwipeRevealRowState extends State<SwipeRevealRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _dragOffset = 0; // 0 = closed, _deleteRevealWidth = fully revealed

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 180),
        )..addListener(() {
          setState(() {
            _dragOffset = _anim.value * _deleteRevealWidth;
          });
        });
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _anim.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    final isOpen = widget.controller.openRowId == widget.rowId;
    if (isOpen && _dragOffset == 0) {
      _animateTo(1);
    } else if (!isOpen && _dragOffset > 0) {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _anim
      ..stop()
      ..value = _dragOffset / _deleteRevealWidth
      ..animateTo(target, curve: Curves.easeOut);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    setState(() {
      // dx is negative when dragging left
      _dragOffset = (_dragOffset - d.delta.dx).clamp(0.0, _deleteRevealWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    final shouldOpen =
        velocity < -200 || _dragOffset > _deleteRevealWidth * 0.5;
    if (shouldOpen) {
      widget.controller.open(widget.rowId);
      _animateTo(1);
    } else {
      widget.controller.close();
      _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Burgundy Delete pill behind the row, aligned to the right edge,
          // visible only when the row is shifted left.
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _dragOffset,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: _deleteRevealWidth,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSizes.sp12),
                      child: _DeletePill(onTap: widget.onDelete),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Burgundy Delete pill — Figma 875:15198. flex-1 h-48, rounded-[24px],
/// bg burgundy (#77393b), label "Delete" Parkinsans SemiBold 15/22 white.
class _DeletePill extends StatelessWidget {
  const _DeletePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.burgundy,
          borderRadius: BorderRadius.circular(AppSizes.radius2xl),
        ),
        child: Text(
          'Delete',
          style: AppTypography.headline.copyWith(color: AppColors.onGreen),
        ),
      ),
    );
  }
}

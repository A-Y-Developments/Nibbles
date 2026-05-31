import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Action chosen from the 3-dot log-detail menu.
///
/// Mirrors the floating Input overlay 188x96 at y=-26 in Figma frames
/// 1525:31083 (edit context) and 1525:31206 (delete context).
enum LogActionMenuChoice { edit, delete }

/// Anchors a floating 3-dot action menu to [anchor] and returns the user's
/// choice (or `null` if dismissed).
///
/// Figma node 1525:31083 — Input overlay 188x96, two rows: "Edit Reactions"
/// (greenDeep / pencil icon) and "Delete Log" (burgundy / trash icon). The
/// surface uses the white token (#ffffff) with the kit shadowCard.
Future<LogActionMenuChoice?> showLogActionsMenu(
  BuildContext context, {
  required GlobalKey anchor,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  final anchorBox = anchor.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null || anchorBox == null) return null;

  // Bottom-right corner of the 3-dot anchor (where the menu's top-right hangs
  // from in Figma — y=-26 below the icon's centre baseline).
  final topRight = anchorBox.localToGlobal(
    anchorBox.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );

  final position = RelativeRect.fromLTRB(
    topRight.dx - _kMenuWidth,
    topRight.dy + AppSizes.xs,
    overlay.size.width - topRight.dx,
    0,
  );

  return showMenu<LogActionMenuChoice>(
    context: context,
    position: position,
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    ),
    constraints: const BoxConstraints(
      minWidth: _kMenuWidth,
      maxWidth: _kMenuWidth,
    ),
    items: const [
      PopupMenuItem<LogActionMenuChoice>(
        key: Key('log_actions_menu_edit'),
        value: LogActionMenuChoice.edit,
        padding: EdgeInsets.zero,
        child: _MenuRow(
          icon: Icons.edit_outlined,
          label: 'Edit Reactions',
          color: AppColors.greenDeep,
        ),
      ),
      PopupMenuItem<LogActionMenuChoice>(
        key: Key('log_actions_menu_delete'),
        value: LogActionMenuChoice.delete,
        padding: EdgeInsets.zero,
        child: _MenuRow(
          icon: Icons.delete_outline,
          label: 'Delete Log',
          color: AppColors.burgundy,
        ),
      ),
    ],
  );
}

const double _kMenuWidth = 188;

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sp12),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd - 4, color: color),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.parkinsans,
                fontSize: 14,
                height: 22 / 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

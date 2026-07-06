import 'package:flutter/material.dart';

abstract final class AppSizes {
  // Spacing (8pt grid)
  static const double sp2 = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double sp12 = 12;
  static const double md = 16;
  static const double sp20 = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double sp36 = 36;
  static const double sp40 = 40;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Border radius — max-rounded design system: every corner token maps to the
  // full pill radius; revert to the graded 4/8/10/16/20/24/30 scale to undo.
  static const double radiusFull = 999;
  static const double radiusXs = radiusFull;
  static const double radiusSm = radiusFull;
  static const double radiusMd = radiusFull;
  static const double radiusLg = radiusFull;
  static const double radiusXl = radiusFull;
  static const double radius2xl = radiusFull;
  static const double radius3xl = radiusFull;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Padding presets
  static const double pagePaddingH = 20;
  static const double pagePaddingV = 24;
  static const double cardPadding = 16;
  static const double listItemPaddingV = 12;

  // Component-specific
  static const double buttonHeight = 38;
  static const double buttonHeightSm = 40;
  static const double roundButton = 44;
  static const double roundButtonSm = 32;
  static const double inputHeight = 52;
  // Kit .field is 48px (inputHeight=52 is a deferred decision; do not mutate).
  static const double fieldHeight = 48;
  // Kit .field horizontal padding (components-inputs.html .field spec: 0 14px).
  static const double fieldPaddingH = 14;
  // Segmented control track height (controls/segmented preview).
  static const double segmentedHeight = 42;
  // Switch track / thumb (controls preview: 44x24 track, 20px thumb).
  static const double switchTrackW = 44;
  static const double switchTrackH = 24;
  static const double switchThumb = 20;
  // Checkbox (.cb controls preview: 24/radius8).
  static const double checkbox = 24;
  // Tip-card glyph circle (cards preview: 28px).
  static const double tipGlyph = 28;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;
  static const double bottomNavRadius = 28;
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 80;
  static const double avatarXl = 120;
  static const double chipHeight = 36;
  static const double chipHeightSm = 24;
  static const double dayChipW = 64;
  static const double dayChipH = 86;
  static const double dividerThickness = 1;

  // Shadow tokens (offsets + blur from kit colors_and_type.css)
  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x0F272727), offset: Offset(0, 2), blurRadius: 8),
  ];
  static const List<BoxShadow> shadowCardLifted = [
    BoxShadow(color: Color(0x1A272727), offset: Offset(0, 6), blurRadius: 24),
  ];
  static const List<BoxShadow> shadowSwitch = [
    BoxShadow(color: Color(0x1A272727), offset: Offset(0, 2), blurRadius: 4),
  ];
}

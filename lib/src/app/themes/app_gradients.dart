import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

abstract final class AppGradients {
  // Figma Grad-1 — linear-gradient(152.612deg, #FFFCD5 19.168%, #F5F5F5 50%).
  // Butter concentrated in the top ~20%, fully grey from mid-screen down.
  static const LinearGradient background = LinearGradient(
    begin: Alignment(-0.460, -0.888),
    end: Alignment(0.460, 0.888),
    stops: [0.19168, 0.5],
    colors: [AppColors.butterSoft, Color(0xFFF5F5F5)],
  );

  static const LinearGradient backgroundMoreWhite = LinearGradient(
    begin: Alignment(-0.460, -0.888),
    end: Alignment(0.460, 0.888),
    stops: [0.19168, 0.5],
    colors: [Color(0xFFFCFADE), Color(0xFFF4F4F4)],
  );
}

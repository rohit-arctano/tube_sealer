// lib/core/config/display_config.dart
import 'dart:math';
import 'package:flutter/material.dart';

class DisplayConfig {
  final int widthPx;
  final int heightPx;
  final double diagonalInches;
  final double minTouchDp; // minimum touch target in logical dp
  final double baselineWidth; // design baseline logical width
  final double baselineHeight; // design baseline logical height
  final Color accentColor;
  final Color bgDark;
  final Color textLight;
  final Color borderDark;

  const DisplayConfig({
    required this.widthPx,
    required this.heightPx,
    required this.diagonalInches,
    required this.minTouchDp,
    required this.baselineWidth,
    required this.baselineHeight,
    required this.accentColor,
    this.bgDark = const Color(0xFF111111),
    this.textLight = const Color(0xFFFFFFFF),
    this.borderDark = const Color(0xFF666666),
  });

  double get physicalDpi {
    final diagPx = sqrt((widthPx * widthPx) + (heightPx * heightPx));
    return diagPx / diagonalInches;
  }
}

// === EDIT THIS SECTION TO CHANGE DISPLAY CONFIG ===
// Change resolution, touch size, or colors here and rebuild.
const DisplayConfig displayConfig = DisplayConfig(
  widthPx: 800,
  heightPx: 480,
  diagonalInches: 5.0,
  minTouchDp: 64.0,
  baselineWidth: 360.0,
  baselineHeight: 640.0,
  accentColor: Color(0xFFFFFFFF),
  bgDark: Color(0xFF111111),
  textLight: Color(0xFFFFFFFF),
  borderDark: Color(0xFFFFFFFF),
);


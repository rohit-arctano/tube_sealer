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
    this.bgDark = const Color(0xFF020B21),
    this.textLight = const Color(0xFFF7FAFF),
    this.borderDark = const Color(0xFF3A5FC9),
  });

  double get physicalDpi {
    final diagPx = sqrt((widthPx * widthPx) + (heightPx * heightPx));
    return diagPx / diagonalInches;
  }

  String get resolutionLabel => '${widthPx}x$heightPx';

  double get aspectRatioValue => widthPx / heightPx;

  String get aspectRatioLabel {
    final divisor = _greatestCommonDivisor(widthPx, heightPx);
    return '${widthPx ~/ divisor}:${heightPx ~/ divisor}';
  }
}

int _greatestCommonDivisor(int a, int b) {
  var x = a.abs();
  var y = b.abs();

  while (y != 0) {
    final remainder = x % y;
    x = y;
    y = remainder;
  }

  return x == 0 ? 1 : x;
}

// === EDIT THIS SECTION TO CHANGE DISPLAY CONFIG ===
// Change resolution, touch size, or colors here and rebuild.
// Keep the design baseline stable so widget sizing stays consistent
// even when the target device resolution/aspect ratio changes.
const DisplayConfig displayConfig = DisplayConfig(
  widthPx: 480,
  heightPx: 800,
  diagonalInches: 5.0,
  minTouchDp: 64.0,
  baselineWidth: 360.0,
  baselineHeight: 640.0,
  accentColor: Color(0xFF0734A6),
  bgDark: Color(0xFF020B21),
  textLight: Color(0xFFF7FAFF),
  borderDark: Color(0xFF3A5FC9),
);


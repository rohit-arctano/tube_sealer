// lib/core/services/responsive_service.dart
import 'dart:math';
import 'package:flutter/widgets.dart';
import '../config/display_config.dart';

/// Responsive helper that scales all UI values based on screen size and config baseline.
class Responsive {
  final DisplayConfig cfg;
  final Size logicalSize; // MediaQuery.of(context).size
  late final double scale;

  Responsive(this.cfg, this.logicalSize) {
    final scaleW = logicalSize.width / cfg.baselineWidth;
    final scaleH = logicalSize.height / cfg.baselineHeight;
    scale = min(scaleW, scaleH);
  }

  /// Scale a base size (design value) by the computed scale factor.
  /// Clamped between 4 and 2000 to avoid extreme values.
  double scaled(double base) => (base * scale).clamp(4.0, 2000.0);

  /// Touch target in logical dp to use for buttons and controls.
  /// Ensures a minimum size for gloved/resistive touch.
  double touchTargetDp() => max(cfg.minTouchDp, scaled(56.0));

  /// Shortcut: accent color from config.
  Color accentColor() => cfg.accentColor;

  /// Shortcut: dark background color.
  Color bgDark() => cfg.bgDark;

  /// Shortcut: light text color.
  Color textLight() => cfg.textLight;

  /// Shortcut: border color.
  Color borderDark() => cfg.borderDark;
}

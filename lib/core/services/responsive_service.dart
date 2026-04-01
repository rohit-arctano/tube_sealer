// lib/core/services/responsive_service.dart
import 'dart:math';
import 'package:flutter/widgets.dart';
import '../../app/theme/app_colors.dart';
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

  /// Shortcut: active accent color from the current theme.
  Color accentColor() => AppColors.primary;

  /// Shortcut: active screen background color.
  Color bgDark() => AppColors.background;

  /// Shortcut: primary readable text color for the current theme.
  Color textLight() => AppColors.textPrimary;

  /// Shortcut: border color for the current theme.
  Color borderDark() => AppColors.divider;
}

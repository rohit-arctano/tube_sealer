import 'package:flutter/material.dart';
import '../../core/models/machine_status.dart';

/// Biomedical-grade color palette.
/// Clinical blues and teals with high-contrast status indicators.
class AppColors {
  AppColors._();

  // ── Primary palette ──
  static const primary = Color(0xFF0054B5);       // Brand blue
  static const primaryLight = Color(0xFF4D8AD4);   // Light blue
  static const primaryDark = Color(0xFF003A7D);    // Dark blue

  // ── Surface / background ──
  static const background = Color(0xFFF4F7F9);     // Cool off-white
  static const surface = Color(0xFFFFFFFF);         // Card white
  static const surfaceVariant = Color(0xFFE8EEF2);  // Subtle grey-blue

  // ── Status indicators ──
  static const ready = Color(0xFF2E7D32);           // Green
  static const running = Color(0xFF1565C0);         // Blue
  static const warning = Color(0xFFF9A825);         // Amber
  static const error = Color(0xFFC62828);           // Red
  static const maintenance = Color(0xFF757575);     // Grey

  // ── Text ──
  static const textPrimary = Color(0xFF1A2B3C);
  static const textSecondary = Color(0xFF5A6B7C);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textOnDark = Color(0xFFE0E8EF);

  // ── Misc ──
  static const divider = Color(0xFFD0D8E0);
  static const disabled = Color(0xFFB0BEC5);
  static const success = Color(0xFF2E7D32);
  static const fail = Color(0xFFC62828);

  /// Map machine status to its indicator color.
  static Color fromStatus(MachineStatus status) {
    switch (status) {
      case MachineStatus.ready:
        return ready;
      case MachineStatus.running:
        return running;
      case MachineStatus.warning:
        return warning;
      case MachineStatus.error:
        return error;
      case MachineStatus.maintenance:
        return maintenance;
    }
  }
}

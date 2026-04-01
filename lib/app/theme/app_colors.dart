import 'package:flutter/material.dart';
import '../../core/models/machine_status.dart';
import 'app_theme_controller.dart';

@immutable
class AppThemePalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color disabled;

  const AppThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.disabled,
  });
}

/// Shared brand palette centered on the requested #0734A6 blue.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0734A6);
  static const primaryLight = Color(0xFF5E8EFF);
  static const primaryDark = Color(0xFF041B59);

  static const ready = Color(0xFF6BA7FF);
  static const running = Color(0xFF4E8CFF);
  static const warning = Color(0xFFF2C14E);
  static const error = Color(0xFFE35D6A);
  static const maintenance = Color(0xFF7F95CD);

  static const textOnPrimary = Color(0xFFF7FAFF);
  static const textOnDark = Color(0xFFF7FAFF);

  static const success = Color(0xFF63A3FF);
  static const fail = Color(0xFFE07B86);

  static const darkPalette = AppThemePalette(
    background: Color(0xFF020B21),
    surface: Color(0xFF0B1639),
    surfaceVariant: Color(0xFF11275C),
    textPrimary: Color(0xFFF7FAFF),
    textSecondary: Color(0xFFB8C6E6),
    divider: Color(0xFF3A5FC9),
    disabled: Color(0xFF5E6F98),
  );

  static const lightPalette = AppThemePalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F9FF),
    surfaceVariant: Color(0xFFEAF0FF),
    textPrimary: Color(0xFF0D1A43),
    textSecondary: Color(0xFF53627E),
    divider: Color(0xFFADC0EE),
    disabled: Color(0xFF99A7C4),
  );

  static AppThemePalette paletteFor(ThemeMode mode) {
    return mode == ThemeMode.light ? lightPalette : darkPalette;
  }

  static AppThemePalette get currentPalette {
    return paletteFor(AppThemeController.instance.themeMode);
  }

  static Color get background => currentPalette.background;
  static Color get surface => currentPalette.surface;
  static Color get surfaceVariant => currentPalette.surfaceVariant;
  static Color get textPrimary => currentPalette.textPrimary;
  static Color get textSecondary => currentPalette.textSecondary;
  static Color get divider => currentPalette.divider;
  static Color get disabled => currentPalette.disabled;

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

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

  static const _darkAccent = Color(0xFF22E4FF);
  static const _darkAccentSoft = Color(0xFF72E6FF);
  static const _darkInactiveAccent = Color(0xFF4B68AF);
  static const _darkSelectedSurface = Color(0xFF102668);
  static const _darkSelectedSurfaceSoft = Color(0xFF0D1B53);
  static const _darkCardSurface = Color(0xFF0B1648);
  static const _darkCardSurfaceRaised = Color(0xFF10205C);
  static const _darkPanelBorder = Color(0xFF183F9E);
  static const _darkPanelBorderStrong = Color(0xFF22E4FF);
  static const _darkGlowTop = Color(0xFF153279);
  static const _darkValueHighlight = Color(0xFFFF5D95);

  static const _readyLight = Color(0xFF6BA7FF);
  static const _runningLight = Color(0xFF4E8CFF);
  static const _warningLight = Color(0xFFF2C14E);
  static const _errorLight = Color(0xFFE35D6A);
  static const _maintenanceLight = Color(0xFF7F95CD);

  static const textOnPrimary = Color(0xFFF7FAFF);
  static const textOnDark = Color(0xFFF7FAFF);

  static const _successLight = Color(0xFF63A3FF);
  static const _failLight = Color(0xFFE07B86);

  static const darkPalette = AppThemePalette(
    background: Color(0xFF040A25),
    surface: Color(0xFF0A1440),
    surfaceVariant: Color(0xFF0F1C56),
    textPrimary: Color(0xFFF7FBFF),
    textSecondary: Color(0xFF7E96CC),
    divider: Color(0xFF183F9E),
    disabled: Color(0xFF4A5C90),
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

  static bool get isDarkMode => AppThemeController.instance.isDarkMode;
  static ThemeMode get currentMode => AppThemeController.instance.themeMode;

  static Color get background => currentPalette.background;
  static Color get surface => currentPalette.surface;
  static Color get surfaceVariant => currentPalette.surfaceVariant;
  static Color get textPrimary => currentPalette.textPrimary;
  static Color get textSecondary => currentPalette.textSecondary;
  static Color get divider => currentPalette.divider;
  static Color get disabled => currentPalette.disabled;
  static Color activeAccentFor(ThemeMode mode) => mode == ThemeMode.dark ? _darkAccent : primary;
  static Color activeAccentSoftFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkAccentSoft : primaryLight;
  static Color inactiveAccentFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkInactiveAccent : paletteFor(mode).textSecondary;
  static Color cardSurfaceFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkCardSurface : paletteFor(mode).surface;
  static Color cardSurfaceRaisedFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkCardSurfaceRaised : paletteFor(mode).surfaceVariant;
  static Color selectedSurfaceFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkSelectedSurface : primary;
  static Color selectedSurfaceSoftFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkSelectedSurfaceSoft : paletteFor(mode).surfaceVariant;
  static Color panelBorderFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkPanelBorder : paletteFor(mode).divider;
  static Color panelBorderStrongFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkPanelBorderStrong : primaryLight;
  static Color glowTopFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkGlowTop : paletteFor(mode).surfaceVariant;
  static Color readyFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? const Color(0xFF79E5FF) : _readyLight;
  static Color runningFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? const Color(0xFF2FDFFF) : _runningLight;
  static Color warningFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? const Color(0xFFF7DE77) : _warningLight;
  static Color errorFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? _darkValueHighlight : _errorLight;
  static Color maintenanceFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? const Color(0xFF8EA7FF) : _maintenanceLight;
  static Color successFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? const Color(0xFF29E5FF) : _successLight;
  static Color failFor(ThemeMode mode) =>
      mode == ThemeMode.dark ? const Color(0xFFFF7EAF) : _failLight;

  static Color get activeAccent => activeAccentFor(currentMode);
  static Color get activeAccentSoft => activeAccentSoftFor(currentMode);
  static Color get inactiveAccent => inactiveAccentFor(currentMode);
  static Color get cardSurface => cardSurfaceFor(currentMode);
  static Color get cardSurfaceRaised => cardSurfaceRaisedFor(currentMode);
  static Color get selectedSurface => selectedSurfaceFor(currentMode);
  static Color get selectedSurfaceSoft => selectedSurfaceSoftFor(currentMode);
  static Color get panelBorder => panelBorderFor(currentMode);
  static Color get panelBorderStrong => panelBorderStrongFor(currentMode);
  static Color get glowTop => glowTopFor(currentMode);
  static Color get valueHighlight => errorFor(currentMode);

  static Color get ready => readyFor(currentMode);
  static Color get running => runningFor(currentMode);
  static Color get warning => warningFor(currentMode);
  static Color get error => errorFor(currentMode);
  static Color get maintenance => maintenanceFor(currentMode);
  static Color get success => successFor(currentMode);
  static Color get fail => failFor(currentMode);

  static List<BoxShadow> panelShadow({
    bool active = false,
    Color? glowColor,
  }) {
    if (isDarkMode) {
      final tint = glowColor ?? activeAccent;
      return [
        const BoxShadow(
          color: Color(0xCC02071A),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: tint.withValues(alpha: active ? 0.24 : 0.12),
          blurRadius: active ? 22 : 14,
          spreadRadius: active ? 1.1 : 0.15,
        ),
      ];
    }

    return [
      BoxShadow(
        color: (active && glowColor != null
                ? glowColor.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.05)),
        blurRadius: active ? 18 : 12,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static LinearGradient get screenBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [
                glowTop.withValues(alpha: 0.72),
                background,
              ]
            : [
                surfaceVariant.withValues(alpha: 0.45),
                background,
              ],
      );

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

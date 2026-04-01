import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Theme definitions for dark and light machine UI modes.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      palette: AppColors.lightPalette,
    );
  }

  static ThemeData get dark {
    return _buildTheme(
      brightness: Brightness.dark,
      palette: AppColors.darkPalette,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemePalette palette,
  }) {
    final textTheme = TextTheme(
      titleLarge: AppTextStyles.screenTitleFor(palette.textPrimary),
      titleMedium: AppTextStyles.sectionTitleFor(palette.textPrimary),
      bodyLarge: AppTextStyles.bodyLargeFor(palette.textPrimary),
      bodyMedium: AppTextStyles.bodyMediumFor(palette.textPrimary),
      bodySmall: AppTextStyles.captionFor(palette.textSecondary),
      labelLarge: AppTextStyles.buttonLabelFor(palette.textPrimary),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.divider,
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textOnPrimary,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        toolbarHeight: 52,
        titleTextStyle: AppTextStyles.screenTitleFor(palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: palette.divider, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          textStyle: AppTextStyles.buttonLabelFor(AppColors.textOnPrimary),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: AppColors.primaryLight, width: 2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          textStyle: AppTextStyles.buttonLabelFor(palette.textPrimary),
          shape: const RoundedRectangleBorder(),
          side: BorderSide(color: palette.divider, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceVariant,
        labelStyle: AppTextStyles.captionFor(palette.textSecondary),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: palette.divider, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: palette.divider, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
        side: BorderSide(color: palette.divider, width: 2),
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyLargeFor(palette.textPrimary),
      ),
    );
  }
}

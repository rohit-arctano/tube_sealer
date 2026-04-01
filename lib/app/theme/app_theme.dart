import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
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
    final isDarkTheme = brightness == Brightness.dark;
    final themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    final activeAccent = AppColors.activeAccentFor(themeMode);
    final cardSurface = AppColors.cardSurfaceFor(themeMode);
    final cardSurfaceRaised = AppColors.cardSurfaceRaisedFor(themeMode);
    final selectedSurface = AppColors.selectedSurfaceFor(themeMode);
    final selectedSurfaceSoft = AppColors.selectedSurfaceSoftFor(themeMode);
    final panelBorder = AppColors.panelBorderFor(themeMode);
    final panelBorderStrong = AppColors.panelBorderStrongFor(themeMode);
    final errorColor = AppColors.errorFor(themeMode);
    final cardBorderRadius = BorderRadius.circular(AppSizes.cardRadius);
    final buttonBorderRadius = BorderRadius.circular(AppSizes.buttonRadius);
    final inputBorderRadius = BorderRadius.circular(AppSizes.inputRadius);
    final dialogBorderRadius = BorderRadius.circular(AppSizes.dialogRadius);
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
        secondary: isDarkTheme ? activeAccent : AppColors.primaryLight,
        onSecondary: AppColors.textOnPrimary,
        surface: isDarkTheme ? cardSurface : palette.surface,
        onSurface: palette.textPrimary,
        error: errorColor,
        onError: AppColors.textOnPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? cardSurface : palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        toolbarHeight: 52,
        titleTextStyle: AppTextStyles.screenTitleFor(palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: isDarkTheme ? cardSurface : palette.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: BorderSide(
            color: isDarkTheme ? panelBorder : palette.divider,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkTheme ? selectedSurface : AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          textStyle: AppTextStyles.buttonLabelFor(AppColors.textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
            side: BorderSide(
              color: isDarkTheme ? panelBorderStrong : AppColors.primaryLight,
              width: 2,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          textStyle: AppTextStyles.buttonLabelFor(palette.textPrimary),
          backgroundColor: isDarkTheme ? selectedSurfaceSoft : null,
          shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
          side: BorderSide(
            color: isDarkTheme ? panelBorder : palette.divider,
            width: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme ? cardSurfaceRaised : palette.surfaceVariant,
        labelStyle: AppTextStyles.captionFor(palette.textSecondary),
        border: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: BorderSide(
            color: isDarkTheme ? panelBorder : palette.divider,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: BorderSide(
            color: isDarkTheme ? panelBorder : palette.divider,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: BorderSide(
            color: isDarkTheme ? activeAccent : AppColors.primaryLight,
            width: 2,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDarkTheme ? cardSurface : palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: dialogBorderRadius,
          side: BorderSide(
            color: isDarkTheme ? panelBorder : palette.divider,
            width: 1.5,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDarkTheme ? cardSurface : palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: dialogBorderRadius,
          side: BorderSide(
            color: isDarkTheme ? panelBorder : palette.divider,
            width: 1.5,
          ),
        ),
        headerBackgroundColor: isDarkTheme ? selectedSurface : AppColors.primary,
        headerForegroundColor: AppColors.textOnPrimary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return isDarkTheme ? activeAccent : AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: BorderSide(
          color: isDarkTheme ? panelBorder : palette.divider,
          width: 2,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDarkTheme ? panelBorder : palette.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDarkTheme ? selectedSurfaceSoft : palette.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyLargeFor(palette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: buttonBorderRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

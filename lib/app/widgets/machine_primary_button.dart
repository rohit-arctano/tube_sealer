import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Large, square, industrial-style primary action button.
class MachinePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  const MachinePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? AppColors.activeAccent;
    final backgroundColor = isDarkTheme
        ? (color != null
              ? accent.withValues(alpha: 0.14)
              : AppColors.selectedSurfaceSoft)
        : AppColors.surface;
    final borderColor = isDarkTheme
        ? (color != null ? accent : AppColors.panelBorder)
        : (color ?? AppColors.divider);
    final labelColor = isDarkTheme ? AppColors.textOnPrimary : AppColors.textPrimary;
    final buttonRadius = BorderRadius.circular(AppSizes.buttonRadius);

    return SizedBox(
      width: double.infinity,
      height: AppSizes.bigButton,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: buttonRadius,
          boxShadow: isDarkTheme
              ? AppColors.panelShadow(
                  active: color != null,
                  glowColor: color ?? AppColors.activeAccent,
                )
              : null,
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: labelColor,
            side: BorderSide(color: borderColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: buttonRadius,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24,
                  color: isDarkTheme ? accent : labelColor,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                label,
                style: AppTextStyles.buttonLabel.copyWith(color: labelColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

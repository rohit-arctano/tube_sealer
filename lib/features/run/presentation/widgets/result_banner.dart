import 'package:flutter/material.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/cycle_result.dart';

class ResultBanner extends StatelessWidget {
  final CycleResult result;
  const ResultBanner({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == CycleResult.none) return const SizedBox.shrink();

    final isPass = result == CycleResult.success;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final icon = isPass ? Icons.check_circle_outline : Icons.error_outline;
    final accentColor = isPass ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
        gradient: isDarkTheme
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardSurfaceRaised,
                  AppColors.cardSurface,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: accentColor, width: 2),
        boxShadow: isDarkTheme
            ? AppColors.panelShadow(
                active: true,
                glowColor: accentColor,
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accentColor, size: 32),
          const SizedBox(width: 12),
          Text(
            result.label,
            style: AppTextStyles.screenTitle,
          ),
        ],
      ),
    );
  }
}

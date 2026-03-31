import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/info_card.dart';

class TubeDetectionCard extends StatelessWidget {
  final bool detected;
  const TubeDetectionCard({super.key, required this.detected});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.tubeDetection,
      icon: Icons.sensors,
      child: Row(
        children: [
          Icon(
            detected ? Icons.check_circle : Icons.cancel,
            color: detected ? AppColors.success : AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            detected ? AppStrings.tubeDetected : AppStrings.tubeNotDetected,
            style: AppTextStyles.bodyLarge.copyWith(
              color: detected ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

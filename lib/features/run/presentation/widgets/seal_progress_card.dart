import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/info_card.dart';
import '../../../../core/models/seal_step.dart';

class SealProgressCard extends StatelessWidget {
  final double progress;
  final SealStep step;
  const SealProgressCard({
    super.key,
    required this.progress,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.sealProgress,
      icon: Icons.timelapse,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                step == SealStep.failed ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}

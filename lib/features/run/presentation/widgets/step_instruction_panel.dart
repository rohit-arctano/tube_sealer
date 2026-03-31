import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/info_card.dart';
import '../../../../core/models/seal_step.dart';

class StepInstructionPanel extends StatelessWidget {
  final SealStep step;
  const StepInstructionPanel({super.key, required this.step});

  String _instruction() {
    switch (step) {
      case SealStep.idle:
        return 'Press Start to begin a new seal cycle.';
      case SealStep.waitingForTube:
        return 'Insert the tube into the sealing chamber.';
      case SealStep.aligningTube:
        return 'Tube is being aligned automatically.';
      case SealStep.sealing:
        return 'Sealing in progress — do not remove tube.';
      case SealStep.completed:
        return 'Seal complete. Remove the tube.';
      case SealStep.failed:
        return 'Cycle failed. Check alarm details.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.currentStep,
      icon: Icons.format_list_numbered,
      accentColor: step.isActive ? AppColors.running : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.label, style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: step == SealStep.failed ? AppColors.error : null,
          )),
          const SizedBox(height: 6),
          Text(_instruction(), style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

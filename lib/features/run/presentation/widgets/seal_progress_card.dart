import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/widgets/info_card.dart';
import '../../../../core/models/seal_step.dart';
import '../../../../core/config/display_config.dart';
import '../../../../core/services/responsive_service.dart';
import '../../../../widget/components/ui_components.dart';

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
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    return InfoCard(
      title: AppStrings.sealProgress,
      icon: Icons.timelapse,
      child: ProgressPhase(
        label: step.label,
        progress: progress,
        timeRemaining: '${(step.progressFraction * 100).toStringAsFixed(0)}%',
        r: r,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/machine_primary_button.dart';

class RunActionButtons extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStop;
  const RunActionButtons({
    super.key,
    required this.isRunning,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRunning) return const SizedBox.shrink();
    return MachinePrimaryButton(
      label: AppStrings.stopCycle,
      icon: Icons.stop_rounded,
      color: AppColors.error,
      onPressed: onStop,
    );
  }
}

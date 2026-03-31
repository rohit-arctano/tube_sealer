import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/machine_primary_button.dart';

class StartCycleButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const StartCycleButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MachinePrimaryButton(
      label: AppStrings.startCycle,
      icon: Icons.play_arrow_rounded,
      color: AppColors.success,
      onPressed: enabled ? onPressed : null,
    );
  }
}

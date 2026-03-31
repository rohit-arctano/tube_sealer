import 'package:flutter/material.dart';
import '../../core/models/machine_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Monochrome square marker + status label.
class StatusIndicator extends StatelessWidget {
  final MachineStatus status;

  const StatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromStatus(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status.label.toUpperCase(),
          style: AppTextStyles.statusLabel,
        ),
      ],
    );
  }
}

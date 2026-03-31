import 'package:flutter/material.dart';
import '../../core/models/machine_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Coloured dot + label for machine status.
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
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status.label,
          style: AppTextStyles.statusLabel.copyWith(color: color),
        ),
      ],
    );
  }
}

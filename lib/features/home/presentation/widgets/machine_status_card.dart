import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/widgets/info_card.dart';
import '../../../../app/widgets/status_indicator.dart';
import '../../../../core/models/machine_status.dart';

class MachineStatusCard extends StatelessWidget {
  final MachineStatus status;
  const MachineStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.machineStatus,
      icon: Icons.monitor_heart_outlined,
      child: StatusIndicator(status: status),
    );
  }
}

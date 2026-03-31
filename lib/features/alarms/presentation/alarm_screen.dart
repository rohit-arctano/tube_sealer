import 'package:flutter/material.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/services/machine_service.dart';
import '../controller/alarm_controller.dart';

class AlarmScreen extends StatefulWidget {
  final MachineService service;
  const AlarmScreen({super.key, required this.service});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late final AlarmController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AlarmController(widget.service);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.init();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final alarm = _ctrl.state.activeAlarm;
        if (alarm == null) {
          return const Center(
            child: Text('No active alarms', style: AppTextStyles.bodyLarge),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alarm.code, style: AppTextStyles.caption),
                          Text(alarm.title, style: AppTextStyles.screenTitle
                              .copyWith(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description',
                          style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      Text(alarm.description,
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 16),
                      Text('How to Fix',
                          style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      Text(alarm.fixInstruction,
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Actions
              MachinePrimaryButton(
                label: AppStrings.acknowledge,
                icon: Icons.check,
                onPressed: _ctrl.acknowledge,
              ),
              if (alarm.retryAllowed) ...[
                const SizedBox(height: 12),
                MachinePrimaryButton(
                  label: AppStrings.retry,
                  icon: Icons.refresh,
                  color: AppColors.warning,
                  onPressed: _ctrl.retry,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

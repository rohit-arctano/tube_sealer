import 'package:flutter/material.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/config/display_config.dart';
import '../../../core/services/machine_service.dart';
import '../../../core/services/responsive_service.dart';
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
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final alarm = _ctrl.state.activeAlarm;
        if (alarm == null) {
          return Center(
            child: Text('No active alarms', style: AppTextStyles.bodyLarge),
          );
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(
            r.scaled(10),
            0,
            r.scaled(10),
            r.scaled(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(r.scaled(12)),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alarm.code, style: AppTextStyles.caption),
                    SizedBox(height: r.scaled(6)),
                    Text(alarm.title, style: AppTextStyles.screenTitle),
                  ],
                ),
              ),
              SizedBox(height: r.scaled(12)),
              Container(
                padding: EdgeInsets.all(r.scaled(12)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: AppTextStyles.sectionTitle),
                    SizedBox(height: r.scaled(8)),
                    Text(alarm.description, style: AppTextStyles.bodyMedium),
                    SizedBox(height: r.scaled(14)),
                    Text('How to Fix', style: AppTextStyles.sectionTitle),
                    SizedBox(height: r.scaled(8)),
                    Text(alarm.fixInstruction, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const Spacer(),
              MachinePrimaryButton(
                label: AppStrings.acknowledge,
                icon: Icons.check,
                onPressed: _ctrl.acknowledge,
              ),
              if (alarm.retryAllowed) ...[
                SizedBox(height: r.scaled(10)),
                MachinePrimaryButton(
                  label: AppStrings.retry,
                  icon: Icons.refresh,
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

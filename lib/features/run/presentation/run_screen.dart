import 'package:flutter/material.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../core/services/machine_service.dart';
import '../controller/run_controller.dart';
import 'widgets/live_parameter_card.dart';
import 'widgets/result_banner.dart';
import 'widgets/run_action_buttons.dart';
import 'widgets/seal_progress_card.dart';
import 'widgets/step_instruction_panel.dart';

class RunScreen extends StatefulWidget {
  final MachineService service;
  const RunScreen({super.key, required this.service});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  late final RunController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = RunController(widget.service);
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
        final s = _ctrl.state;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepInstructionPanel(step: s.currentStep),
              SealProgressCard(
                progress: s.sealProgress,
                step: s.currentStep,
              ),
              LiveParameterCard(
                temperature: s.currentTemperature,
                targetTemperature:
                    s.selectedRecipe?.targetTemperature ?? 0,
              ),
              ResultBanner(result: s.cycleResult),
              const SizedBox(height: AppSizes.lg),
              RunActionButtons(
                isRunning: s.currentStep.isActive,
                onStop: _ctrl.stop,
              ),
            ],
          ),
        );
      },
    );
  }
}

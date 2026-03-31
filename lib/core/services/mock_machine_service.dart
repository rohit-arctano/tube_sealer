import 'dart:async';
import '../models/alarm_info.dart';
import '../models/cycle_result.dart';
import '../models/machine_status.dart';
import '../models/machine_ui_state.dart';
import '../models/recipe_model.dart';
import '../models/seal_step.dart';
import '../models/user_role.dart';
import 'machine_service.dart';

/// Simulated machine service for UI development without hardware.
class MockMachineService implements MachineService {
  final _controller = StreamController<MachineUiState>.broadcast();
  Timer? _cycleTimer;

  MachineUiState _state = MachineUiState(
    status: MachineStatus.ready,
    tubeDetected: true,
    selectedRecipe: const RecipeModel(
      material: 'Silicone (Liveo™ Pharma 50)',
      id: 'R001',
      name: 'Standard PVC 6mm',
      tubeSize: '6mm',
      targetTemperature: 165,
      sealTimeMs: 3500,
      isLocked: false,
    ),
    currentStep: SealStep.idle,
    cycleResult: CycleResult.none,
    currentTemperature: 23.0,
    todayCount: 42,
    totalCount: 12847,
    userRole: UserRole.operator,
  );

  MockMachineService() {
    // Emit initial state.
    _controller.add(_state);
  }

  void _emit(MachineUiState newState) {
    _state = newState;
    _controller.add(_state);
  }

  @override
  Stream<MachineUiState> watchMachineState() => _controller.stream;

  @override
  Future<void> startSealCycle() async {
    if (!_state.canStartCycle) return;

    // Step through a simulated cycle.
    final steps = [
      SealStep.waitingForTube,
      SealStep.aligningTube,
      SealStep.sealing,
      SealStep.completed,
    ];
    int i = 0;
    double temp = _state.currentTemperature;

    _emit(_state.copyWith(
      status: MachineStatus.running,
      currentStep: steps[i],
      cycleResult: CycleResult.none,
      sealProgress: 0.0,
    ));

    _cycleTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      i++;
      if (i < steps.length) {
        temp += 35;
        _emit(_state.copyWith(
          currentStep: steps[i],
          currentTemperature: temp.clamp(23, 170),
          sealProgress: steps[i].progressFraction,
        ));
      } else {
        timer.cancel();
        _emit(_state.copyWith(
          status: MachineStatus.ready,
          currentStep: SealStep.idle,
          cycleResult: CycleResult.success,
          sealProgress: 1.0,
          currentTemperature: 23.0,
          todayCount: _state.todayCount + 1,
          totalCount: _state.totalCount + 1,
        ));
      }
    });
  }

  @override
  Future<void> stopSealCycle() async {
    _cycleTimer?.cancel();
    _emit(_state.copyWith(
      status: MachineStatus.ready,
      currentStep: SealStep.idle,
      cycleResult: CycleResult.failed,
      sealProgress: 0.0,
      currentTemperature: 23.0,
    ));
  }

  @override
  Future<void> acknowledgeAlarm() async {
    _emit(_state.copyWith(
      status: MachineStatus.ready,
      activeAlarm: null,
    ));
  }

  @override
  Future<void> retryLastAction() async {
    await acknowledgeAlarm();
    await startSealCycle();
  }

  /// Simulate an alarm for testing.
  void triggerTestAlarm() {
    _cycleTimer?.cancel();
    _emit(_state.copyWith(
      status: MachineStatus.error,
      currentStep: SealStep.failed,
      cycleResult: CycleResult.failed,
      activeAlarm: const AlarmInfo(
        code: 'E-101',
        title: 'Heater Over-Temperature',
        description: 'The sealing element exceeded the safe temperature limit.',
        fixInstruction:
            'Allow the unit to cool for 5 minutes, then press Retry. '
            'If the alarm persists, contact service.',
        retryAllowed: true,
      ),
    ));
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _controller.close();
  }
}

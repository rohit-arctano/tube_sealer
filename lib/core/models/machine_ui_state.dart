import 'alarm_info.dart';
import 'cycle_result.dart';
import 'machine_status.dart';
import 'recipe_model.dart';
import 'seal_step.dart';
import 'user_role.dart';

/// Central UI state for the entire machine.
class MachineUiState {
  final MachineStatus status;
  final bool tubeDetected;
  final RecipeModel? selectedRecipe;
  final SealStep currentStep;
  final CycleResult cycleResult;
  final AlarmInfo? activeAlarm;
  final double currentTemperature;
  final double sealProgress;
  final int todayCount;
  final int totalCount;
  final UserRole userRole;

  const MachineUiState({
    this.status = MachineStatus.ready,
    this.tubeDetected = false,
    this.selectedRecipe,
    this.currentStep = SealStep.idle,
    this.cycleResult = CycleResult.none,
    this.activeAlarm,
    this.currentTemperature = 0.0,
    this.sealProgress = 0.0,
    this.todayCount = 0,
    this.totalCount = 0,
    this.userRole = UserRole.operator,
  });

  MachineUiState copyWith({
    MachineStatus? status,
    bool? tubeDetected,
    RecipeModel? selectedRecipe,
    SealStep? currentStep,
    CycleResult? cycleResult,
    AlarmInfo? activeAlarm,
    double? currentTemperature,
    double? sealProgress,
    int? todayCount,
    int? totalCount,
    UserRole? userRole,
  }) {
    return MachineUiState(
      status: status ?? this.status,
      tubeDetected: tubeDetected ?? this.tubeDetected,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
      currentStep: currentStep ?? this.currentStep,
      cycleResult: cycleResult ?? this.cycleResult,
      activeAlarm: activeAlarm ?? this.activeAlarm,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      sealProgress: sealProgress ?? this.sealProgress,
      todayCount: todayCount ?? this.todayCount,
      totalCount: totalCount ?? this.totalCount,
      userRole: userRole ?? this.userRole,
    );
  }

  /// Whether the start button should be enabled.
  bool get canStartCycle =>
      status == MachineStatus.ready &&
      tubeDetected &&
      selectedRecipe != null &&
      currentStep == SealStep.idle;
}

import '../models/machine_ui_state.dart';

/// Contract for machine communication.
/// Implemented by MockMachineService (dev) and NativeMachineService (prod).
abstract class MachineService {
  Stream<MachineUiState> watchMachineState();
  Future<void> startSealCycle();
  Future<void> stopSealCycle();
  Future<void> acknowledgeAlarm();
  Future<void> retryLastAction();
  void dispose();
}

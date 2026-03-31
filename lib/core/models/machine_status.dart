/// Represents the current operational state of the tube sealer machine.
enum MachineStatus {
  ready,
  running,
  warning,
  error,
  maintenance;

  String get label {
    switch (this) {
      case MachineStatus.ready:
        return 'Ready';
      case MachineStatus.running:
        return 'Running';
      case MachineStatus.warning:
        return 'Warning';
      case MachineStatus.error:
        return 'Error';
      case MachineStatus.maintenance:
        return 'Maintenance';
    }
  }
}

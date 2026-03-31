/// Outcome of a completed seal cycle.
enum CycleResult {
  none,
  success,
  failed;

  String get label {
    switch (this) {
      case CycleResult.none:
        return '—';
      case CycleResult.success:
        return 'Pass';
      case CycleResult.failed:
        return 'Fail';
    }
  }
}

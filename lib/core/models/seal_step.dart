/// Represents the current step in a seal cycle.
enum SealStep {
  idle,
  waitingForTube,
  aligningTube,
  sealing,
  completed,
  failed;

  String get label {
    switch (this) {
      case SealStep.idle:
        return 'Idle';
      case SealStep.waitingForTube:
        return 'Waiting for Tube';
      case SealStep.aligningTube:
        return 'Aligning Tube';
      case SealStep.sealing:
        return 'Sealing';
      case SealStep.completed:
        return 'Completed';
      case SealStep.failed:
        return 'Failed';
    }
  }

  /// Progress fraction (0.0 to 1.0) for the progress indicator.
  double get progressFraction {
    switch (this) {
      case SealStep.idle:
        return 0.0;
      case SealStep.waitingForTube:
        return 0.15;
      case SealStep.aligningTube:
        return 0.35;
      case SealStep.sealing:
        return 0.7;
      case SealStep.completed:
        return 1.0;
      case SealStep.failed:
        return 0.0;
    }
  }

  bool get isActive =>
      this == SealStep.waitingForTube ||
      this == SealStep.aligningTube ||
      this == SealStep.sealing;
}

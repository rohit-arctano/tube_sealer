// lib/core/services/mock_machine.dart
import 'dart:async';
import '../models/sealing_models.dart';

/// Simple mock machine HAL for development/testing.
class MockMachine {
  SealingPhase _phase = SealingPhase.idle;
  double _progress = 0.0;
  String _label = '';
  int _timeRemaining = 0;
  String? _errorMessage;
  late StreamController<PhaseUpdate> _updateController;
  late Timer? _timer;

  String _tubingType = 'TuFlux TPE';
  String _tubingSize = 'ID 1/4 x OD 7/16 Red';

  MockMachine() {
    _updateController = StreamController<PhaseUpdate>.broadcast();
    _timer = null;
  }

  /// Stream of phase updates.
  Stream<PhaseUpdate> get onPhaseUpdate => _updateController.stream;

  /// Current phase.
  SealingPhase get phase => _phase;

  /// Start sealing process.
  Future<void> startProcess() async {
    _phase = SealingPhase.compression;
    _startPhaseTimer(SealingPhase.compression);
  }

  /// Abort the sealing process.
  Future<void> abortProcess() async {
    _timer?.cancel();
    _phase = SealingPhase.idle;
    _progress = 0.0;
    _label = '';
    _timeRemaining = 0;
    _updateController.add(PhaseUpdate(
      phase: _phase,
      progress: _progress,
      label: 'Aborted',
      timeRemainingSeconds: 0,
    ));
  }

  /// Set tubing selection.
  void setTubing(String type, String size) {
    _tubingType = type;
    _tubingSize = size;
  }

  /// Dispose of resources.
  void dispose() {
    _timer?.cancel();
    _updateController.close();
  }

  void _startPhaseTimer(SealingPhase phase) {
    _timer?.cancel();
    const tickDuration = Duration(milliseconds: 500);
    final totalDurationMs = _getPhaseDuration(phase);
    int elapsedMs = 0;

    _timer = Timer.periodic(tickDuration, (timer) {
      elapsedMs += tickDuration.inMilliseconds;
      _progress = (elapsedMs / totalDurationMs).clamp(0.0, 1.0);
      _timeRemaining = ((totalDurationMs - elapsedMs) / 1000).ceil();

      _updateController.add(PhaseUpdate(
        phase: _phase,
        progress: _progress,
        label: _getPhaseLabel(_phase),
        timeRemainingSeconds: _timeRemaining,
      ));

      if (_progress >= 1.0) {
        timer.cancel();
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    switch (_phase) {
      case SealingPhase.compression:
        _phase = SealingPhase.heating;
        _startPhaseTimer(_phase);
        break;
      case SealingPhase.heating:
        _phase = SealingPhase.cooling;
        _startPhaseTimer(_phase);
        break;
      case SealingPhase.cooling:
        _phase = SealingPhase.complete;
        _progress = 1.0;
        _timeRemaining = 0;
        _updateController.add(PhaseUpdate(
          phase: _phase,
          progress: 1.0,
          label: 'Complete',
          timeRemainingSeconds: 0,
        ));
        break;
      default:
        break;
    }
  }

  int _getPhaseDuration(SealingPhase phase) {
    switch (phase) {
      case SealingPhase.compression:
        return 3000; // 3 seconds for demo
      case SealingPhase.heating:
        return 4000; // 4 seconds
      case SealingPhase.cooling:
        return 5000; // 5 seconds
      default:
        return 1000;
    }
  }

  String _getPhaseLabel(SealingPhase phase) {
    switch (phase) {
      case SealingPhase.compression:
        return 'Compression phase';
      case SealingPhase.heating:
        return 'Heating phase';
      case SealingPhase.cooling:
        return 'Cooling phase';
      case SealingPhase.complete:
        return 'Process Complete';
      default:
        return 'Ready';
    }
  }
}

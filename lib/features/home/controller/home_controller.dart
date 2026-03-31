import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/models/machine_ui_state.dart';
import '../../../core/services/machine_service.dart';

/// Controller for the Home screen.
class HomeController extends ChangeNotifier {
  final MachineService _service;
  StreamSubscription<MachineUiState>? _sub;

  MachineUiState _state = const MachineUiState();
  MachineUiState get state => _state;

  HomeController(this._service);

  /// Call after the first frame to avoid setState during build.
  void init() {
    _sub = _service.watchMachineState().listen((s) {
      _state = s;
      notifyListeners();
    });
  }

  Future<void> startCycle() => _service.startSealCycle();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

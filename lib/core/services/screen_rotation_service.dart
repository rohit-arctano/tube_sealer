import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages screen orientation for the custom vertical display.
/// Cycles through 4 orientations: 0°, 90°, 180°, 270°.
class ScreenRotationService extends ChangeNotifier {
  static final ScreenRotationService _instance = ScreenRotationService._();
  factory ScreenRotationService() => _instance;
  ScreenRotationService._();

  static const _orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
  ];

  static const _labels = ['0°', '90°', '180°', '270°'];

  int _index = 0;

  /// Current rotation index (0–3).
  int get index => _index;

  /// Human-readable label for current rotation.
  String get label => _labels[_index];

  /// Number of quarter-turns for RotatedBox (0–3).
  int get quarterTurns => _index;

  /// Rotate to the next orientation (cycles 0° → 90° → 180° → 270° → 0°).
  Future<void> rotateNext() async {
    _index = (_index + 1) % 4;
    await SystemChrome.setPreferredOrientations([_orientations[_index]]);
    notifyListeners();
  }

  /// Set a specific rotation.
  Future<void> setRotation(int rotationIndex) async {
    _index = rotationIndex % 4;
    await SystemChrome.setPreferredOrientations([_orientations[_index]]);
    notifyListeners();
  }
}

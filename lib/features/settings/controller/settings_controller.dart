import 'package:flutter/foundation.dart';
import '../../../core/services/screen_rotation_service.dart';

/// Controller for the Settings screen.
class SettingsController extends ChangeNotifier {
  final ScreenRotationService rotation = ScreenRotationService();

  String _language = 'English';
  String get language => _language;

  double _brightness = 0.8;
  double get brightness => _brightness;

  final String version = '1.0.0';

  SettingsController() {
    rotation.addListener(_onRotationChanged);
  }

  void _onRotationChanged() => notifyListeners();

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setBrightness(double value) {
    _brightness = value;
    notifyListeners();
  }

  Future<void> rotateScreen() => rotation.rotateNext();

  @override
  void dispose() {
    rotation.removeListener(_onRotationChanged);
    super.dispose();
  }
}

/// A tube sealing recipe with all parameters.
class RecipeModel {
  final String id;
  final String name;
  final String tubeSize;
  final String material;
  final double targetTemperature;
  final int sealTimeMs;
  final bool isLocked;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.tubeSize,
    required this.material,
    required this.targetTemperature,
    required this.sealTimeMs,
    required this.isLocked,
  });

  /// Human-readable seal time.
  String get sealTimeFormatted {
    final seconds = sealTimeMs / 1000;
    return '${seconds.toStringAsFixed(1)}s';
  }

  /// Human-readable temperature.
  String get temperatureFormatted => '${targetTemperature.toStringAsFixed(0)}°C';
}

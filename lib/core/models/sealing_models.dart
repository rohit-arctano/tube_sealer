// lib/core/models/sealing_models.dart

/// Sealing process phases.
enum SealingPhase {
  idle,
  ready,
  compression,
  heating,
  cooling,
  complete,
  error,
}

/// Sealing process state update.
class PhaseUpdate {
  final SealingPhase phase;
  final double progress; // 0.0 to 1.0
  final String label;
  final int timeRemainingSeconds;
  final String? errorMessage;

  PhaseUpdate({
    required this.phase,
    required this.progress,
    required this.label,
    required this.timeRemainingSeconds,
    this.errorMessage,
  });
}

/// Log entry for completed sealing.
class SealingLog {
  final DateTime date;
  final String tubingType;
  final String tubingSize;
  final int compressionTemp;
  final int heatingTemp;
  final int heatingTime;
  final int sealingTime;
  final int processTime;
  final String processCode;
  final bool success;

  SealingLog({
    required this.date,
    required this.tubingType,
    required this.tubingSize,
    required this.compressionTemp,
    required this.heatingTemp,
    required this.heatingTime,
    required this.sealingTime,
    required this.processTime,
    required this.processCode,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'tubingType': tubingType,
    'tubingSize': tubingSize,
    'compressionTemp': compressionTemp,
    'heatingTemp': heatingTemp,
    'heatingTime': heatingTime,
    'sealingTime': sealingTime,
    'processTime': processTime,
    'processCode': processCode,
    'success': success,
  };
}

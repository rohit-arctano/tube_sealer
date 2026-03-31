/// Describes an active machine alarm.
class AlarmInfo {
  final String code;
  final String title;
  final String description;
  final String fixInstruction;
  final bool retryAllowed;

  const AlarmInfo({
    required this.code,
    required this.title,
    required this.description,
    required this.fixInstruction,
    required this.retryAllowed,
  });
}

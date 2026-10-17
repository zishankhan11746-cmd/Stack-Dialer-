enum CallType {
  incoming,
  outgoing,
  missed,
  rejected,
}

class CallRecord {
  final String id;
  final String name;
  final String number;
  final CallType type;
  final DateTime timestamp;
  final int durationSeconds;
  final int simSlot;
  final String simCarrier;
  final String? note;
  final String? reminderTime;

  CallRecord({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.timestamp,
    required this.durationSeconds,
    this.simSlot = 1,
    this.simCarrier = 'Jio 5G',
    this.note,
    this.reminderTime,
  });

  String get durationString {
    if (durationSeconds == 0) return 'Missed';
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    if (mins == 0) return '${secs}s';
    return '${mins}m ${secs}s';
  }
}

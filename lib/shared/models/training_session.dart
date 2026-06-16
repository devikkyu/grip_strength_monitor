class TrainingSession {
  final String id;
  final DateTime date;
  final String type;
  final double gripStrength;
  final double maxGrip;
  final double minGrip;
  final int durationSeconds;
  final int roundCount;
  final String status;

  TrainingSession({
    required this.id,
    required this.date,
    required this.type,
    required this.gripStrength,
    required this.maxGrip,
    required this.minGrip,
    required this.durationSeconds,
    required this.roundCount,
    required this.status,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      gripStrength: (json['gripStrength'] as num).toDouble(),
      maxGrip: (json['maxGrip'] as num).toDouble(),
      minGrip: (json['minGrip'] as num).toDouble(),
      durationSeconds: json['durationSeconds'],
      roundCount: json['roundCount'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'gripStrength': gripStrength,
      'maxGrip': maxGrip,
      'minGrip': minGrip,
      'durationSeconds': durationSeconds,
      'roundCount': roundCount,
      'status': status,
    };
  }

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get dateFormatted {
    return '${date.day}/${date.month}/${date.year}';
  }
}

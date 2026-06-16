class GripData {
  final DateTime date;
  final double gripStrength;
  final int? sessionCount;

  GripData({
    required this.date,
    required this.gripStrength,
    this.sessionCount,
  });

  factory GripData.fromJson(Map<String, dynamic> json) {
    return GripData(
      date: DateTime.parse(json['date']),
      gripStrength: (json['gripStrength'] as num).toDouble(),
      sessionCount: json['sessionCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'gripStrength': gripStrength,
      'sessionCount': sessionCount,
    };
  }
}

enum GripStatus { normal, warning, risk }

extension GripStatusExtension on GripStatus {
  String get label {
    switch (this) {
      case GripStatus.normal:
        return 'Normal';
      case GripStatus.warning:
        return 'Warning';
      case GripStatus.risk:
        return 'Risk';
    }
  }
}

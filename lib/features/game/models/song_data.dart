class SongData {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String difficulty;
  final String assetPath;
  final double bpm;

  const SongData({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.difficulty,
    required this.assetPath,
    required this.bpm,
  });

  String get durationFormatted {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class BeatNote {
  final int timestampMs;
  final int lane;
  final bool isLong;

  const BeatNote({
    required this.timestampMs,
    this.lane = 0,
    this.isLong = false,
  });
}

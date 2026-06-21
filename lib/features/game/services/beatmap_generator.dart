import 'package:grip_strength_monitor/features/game/models/song_data.dart';

class BeatmapGenerator {
  static List<BeatNote> generate({
    required double bpm,
    required Duration duration,
    double startOffsetMs = 1000,
    double endPaddingMs = 2000,
  }) {
    if (bpm <= 0 || duration.inMilliseconds <= 0) return [];

    final intervalMs = 60000.0 / bpm;
    final availableMs = duration.inMilliseconds - startOffsetMs - endPaddingMs;
    if (availableMs <= 0) return [];

    final noteCount = (availableMs / intervalMs).floor();
    final notes = <BeatNote>[];

    for (int i = 0; i < noteCount; i++) {
      final ts = (startOffsetMs + i * intervalMs).round();
      notes.add(BeatNote(timestampMs: ts));
    }

    return notes;
  }

  static List<BeatNote> validate({
    required List<BeatNote> beatMap,
    required Duration songDuration,
  }) {
    if (beatMap.isEmpty) return beatMap;
    final maxTs = songDuration.inMilliseconds;
    return beatMap.where((n) => n.timestampMs <= maxTs).toList();
  }
}

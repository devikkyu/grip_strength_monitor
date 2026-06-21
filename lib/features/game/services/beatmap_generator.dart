import 'dart:math';
import 'package:grip_strength_monitor/features/game/models/song_data.dart';

class BeatmapGenerator {
  static final Random _rand = Random();

  static List<BeatNote> generate({
    required double bpm,
    required Duration duration,
    double startOffsetMs = 1000,
    double endPaddingMs = 2000,
  }) {
    if (bpm <= 0 || duration.inMilliseconds <= 0) return [];

    final beatIntervalMs = 60000.0 / bpm;
    final halfBeatMs = beatIntervalMs / 2;
    final availableMs = duration.inMilliseconds - startOffsetMs - endPaddingMs;
    if (availableMs <= 0) return [];

    final notes = <BeatNote>[];
    double currentMs = 0;

    while (currentMs < availableMs) {
      if (_rand.nextDouble() < 0.5) {
        final ts = (startOffsetMs + currentMs).round();
        notes.add(BeatNote(timestampMs: ts));
      }
      currentMs += halfBeatMs;
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

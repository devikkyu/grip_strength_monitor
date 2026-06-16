import 'dart:math';
import '../models/game_note.dart';

enum Difficulty { easy, medium, hard }

class PatternGenerator {
  static final Random _random = Random();

  static List<GameNote> generate({
    int noteCount = 30,
    Difficulty difficulty = Difficulty.medium,
  }) {
    final notes = <GameNote>[];
    final config = _getConfig(difficulty);

    for (int i = 0; i < noteCount; i++) {
      final type = _randomNoteType(config.shortLongRatio);
      final delay = _randomDelay(config.minDelay, config.maxDelay);
      final speed = _randomSpeed(config.minSpeed, config.maxSpeed);
      final duration = type == NoteType.long
          ? _randomDuration(config.minLongDuration, config.maxLongDuration)
          : 0.0;

      notes.add(GameNote(
        type: type,
        speed: speed,
        spawnDelay: delay,
        duration: duration,
      ));
    }

    return notes;
  }

  static _PatternConfig _getConfig(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _PatternConfig(
          shortLongRatio: 0.7,
          minDelay: 1.2,
          maxDelay: 2.5,
          minSpeed: 120,
          maxSpeed: 160,
          minLongDuration: 1.0,
          maxLongDuration: 1.8,
        );
      case Difficulty.medium:
        return _PatternConfig(
          shortLongRatio: 0.5,
          minDelay: 0.8,
          maxDelay: 2.0,
          minSpeed: 140,
          maxSpeed: 200,
          minLongDuration: 0.8,
          maxLongDuration: 2.2,
        );
      case Difficulty.hard:
        return _PatternConfig(
          shortLongRatio: 0.3,
          minDelay: 0.5,
          maxDelay: 1.5,
          minSpeed: 180,
          maxSpeed: 260,
          minLongDuration: 0.6,
          maxLongDuration: 2.5,
        );
    }
  }

  static NoteType _randomNoteType(double shortRatio) {
    return _random.nextDouble() < shortRatio
        ? NoteType.short
        : NoteType.long;
  }

  static double _randomDelay(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  static double _randomSpeed(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  static double _randomDuration(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}

class _PatternConfig {
  final double shortLongRatio;
  final double minDelay;
  final double maxDelay;
  final double minSpeed;
  final double maxSpeed;
  final double minLongDuration;
  final double maxLongDuration;

  _PatternConfig({
    required this.shortLongRatio,
    required this.minDelay,
    required this.maxDelay,
    required this.minSpeed,
    required this.maxSpeed,
    required this.minLongDuration,
    required this.maxLongDuration,
  });
}

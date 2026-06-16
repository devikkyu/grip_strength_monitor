import 'package:flutter/material.dart';

enum NoteType { short, long }

enum NoteState { waiting, active, hit, missed }

class GameNote {
  final NoteType type;
  final double speed;
  final double spawnDelay;
  final double duration;
  NoteState state;
  double currentX;
  bool isBeingSqueezed;

  GameNote({
    required this.type,
    required this.speed,
    required this.spawnDelay,
    this.duration = 0,
    this.state = NoteState.waiting,
    this.currentX = 0,
    this.isBeingSqueezed = false,
  });

  double get width => type == NoteType.short ? 56 : 76;
  double get height => type == NoteType.short ? 56 : 130;

  Color get color {
    switch (state) {
      case NoteState.waiting:
        return const Color(0xFF007AFF);
      case NoteState.active:
        return const Color(0xFF34C759);
      case NoteState.hit:
        return const Color(0xFF30D158);
      case NoteState.missed:
        return const Color(0xFFFF3B30);
    }
  }

  IconData get icon {
    switch (type) {
      case NoteType.short:
        return Icons.bolt_rounded;
      case NoteType.long:
        return Icons.keyboard_double_arrow_down_rounded;
    }
  }

  String get label {
    switch (type) {
      case NoteType.short:
        return 'สั้น';
      case NoteType.long:
        return 'ยาว';
    }
  }
}

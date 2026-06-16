import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  void playClick() {
    HapticFeedback.selectionClick();
  }

  void playTap() {
    HapticFeedback.lightImpact();
  }

  void playBeat() {
    HapticFeedback.mediumImpact();
  }

  void playSuccess() {
    HapticFeedback.heavyImpact();
  }

  void playError() {
    HapticFeedback.vibrate();
  }

  void playCountdown() {
    HapticFeedback.lightImpact();
  }

  void playGameStart() {
    HapticFeedback.mediumImpact();
    Future.delayed(Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });
  }

  void playPerfect() {
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(milliseconds: 50), () {
      HapticFeedback.mediumImpact();
    });
  }

  void playGameOver() {
    HapticFeedback.vibrate();
    Future.delayed(Duration(milliseconds: 200), () {
      HapticFeedback.vibrate();
    });
  }
}

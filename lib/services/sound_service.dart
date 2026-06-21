import 'package:flutter/services.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  final PersistenceService _persistence = PersistenceService();
  bool _enabled = true;

  bool get enabled => _enabled;

  void init() {
    final saved = _persistence.get('settings', 'sound_enabled');
    if (saved != null) {
      _enabled = saved == true;
    }
  }

  void setEnabled(bool value) {
    _enabled = value;
    _persistence.save('settings', 'sound_enabled', value);
  }

  void toggle() => setEnabled(!_enabled);

  void playClick() { if (_enabled) HapticFeedback.selectionClick(); }
  void playTap() { if (_enabled) HapticFeedback.lightImpact(); }
  void playBeat() { if (_enabled) HapticFeedback.mediumImpact(); }
  void playSuccess() { if (_enabled) HapticFeedback.heavyImpact(); }
  void playError() { if (_enabled) HapticFeedback.vibrate(); }
  void playCountdown() { if (_enabled) HapticFeedback.lightImpact(); }
  void playNavigation() { if (_enabled) HapticFeedback.selectionClick(); }
  void playButton() { if (_enabled) HapticFeedback.lightImpact(); }

  void playGameStart() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
    Future.delayed(Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
  }

  void playPerfect() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(milliseconds: 50), () => HapticFeedback.mediumImpact());
  }

  void playGameOver() {
    if (!_enabled) return;
    HapticFeedback.vibrate();
    Future.delayed(Duration(milliseconds: 200), () => HapticFeedback.vibrate());
  }

  void playLevelUp() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(milliseconds: 80), () => HapticFeedback.heavyImpact());
    Future.delayed(Duration(milliseconds: 160), () => HapticFeedback.mediumImpact());
  }

  void playAchievement() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(milliseconds: 60), () => HapticFeedback.mediumImpact());
    Future.delayed(Duration(milliseconds: 120), () => HapticFeedback.lightImpact());
  }

  void playSave() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(Duration(milliseconds: 50), () => HapticFeedback.lightImpact());
  }
}

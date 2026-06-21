import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  final PersistenceService _persistence = PersistenceService();
  bool _enabled = true;
  AudioPlayer? _hitPlayer;

  bool get enabled => _enabled;

  void init() {
    final saved = _persistence.get('settings', 'sound_enabled');
    if (saved != null) {
      _enabled = saved == true;
    }
    _initHitPlayer();
  }

  void _initHitPlayer() {
    _hitPlayer = AudioPlayer();
    _hitPlayer?.setVolume(0.7);
    _hitPlayer?.setSpeed(1.0);
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

  void playTileHit() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
    _playHitSound();
  }

  Future<void> _playHitSound() async {
    try {
      if (_hitPlayer == null) {
        _hitPlayer = AudioPlayer();
        await _hitPlayer!.setVolume(0.7);
      }
      await _hitPlayer!.setAsset('assets/sounds/tile_hit.mp3');
      _hitPlayer!.play();
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

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
    _playHitSound();
  }

  void playGood() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    _playHitSound();
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

  void dispose() {
    _hitPlayer?.dispose();
    _hitPlayer = null;
  }
}

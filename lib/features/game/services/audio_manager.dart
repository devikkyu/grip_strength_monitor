import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:grip_strength_monitor/features/game/models/song_data.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final AudioPlayer _player = AudioPlayer();
  SongData? _currentSong;
  Duration? _loadedDuration;

  AudioPlayer get player => _player;
  SongData? get currentSong => _currentSong;
  Duration get position => _player.position;
  Duration get duration => _loadedDuration ?? _player.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<bool> loadSong(SongData song) async {
    try {
      await _player.setAsset(song.assetPath);
      _currentSong = song;
      _loadedDuration = _player.duration;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}

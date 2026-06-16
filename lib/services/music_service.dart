import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicService {
  static final MusicService _instance = MusicService._();
  factory MusicService() => _instance;
  MusicService._();

  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  bool _isPlaying = false;
  String _currentTitle = '';
  Duration _totalDuration = Duration.zero;
  double _currentBPM = 100;

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  String get currentTitle => _currentTitle;
  Duration get totalDuration => _totalDuration;
  double get currentBPM => _currentBPM;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  String _extractVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
    if (url.length == 11) {
      return url;
    }
    return url;
  }

  Future<bool> loadFromYouTube(String url) async {
    try {
      final videoId = _extractVideoId(url);
      if (videoId.isEmpty) {
        _currentTitle = 'URL ไม่ถูกต้อง';
        return false;
      }

      final video = await _yt.videos.get(videoId);
      _currentTitle = video.title;

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      final audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) {
        final muxedStreams = manifest.muxed;
        if (muxedStreams.isNotEmpty) {
          final stream = muxedStreams.last;
          await _player.setUrl(stream.url.toString());
          _totalDuration = _player.duration ?? Duration.zero;
          _currentBPM = _estimateBPM(_currentTitle);
          return true;
        }
        _currentTitle = 'ไม่พบไฟล์เสียง';
        return false;
      }

      final stream = audioStreams.last;
      await _player.setUrl(stream.url.toString());

      _totalDuration = _player.duration ?? Duration.zero;
      _currentBPM = _estimateBPM(_currentTitle);

      return true;
    } catch (e) {
      _currentTitle = 'เกิดข้อผิดพลาด: ${e.toString().substring(0, 50)}';
      return false;
    }
  }

  Future<void> play() async {
    await _player.play();
    _isPlaying = true;
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void setBPM(double bpm) {
    _currentBPM = bpm;
  }

  double _estimateBPM(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('slow') || lower.contains('ballad')) return 65;
    if (lower.contains('fast') || lower.contains('dance')) return 130;
    if (lower.contains('rock')) return 120;
    if (lower.contains('hip hop') || lower.contains('rap')) return 90;
    if (lower.contains('pop')) return 110;
    return 100;
  }

  void dispose() {
    _player.dispose();
    _yt.close();
  }
}

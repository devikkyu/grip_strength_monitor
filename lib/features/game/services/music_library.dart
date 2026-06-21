import 'package:grip_strength_monitor/features/game/models/song_data.dart';

class MusicLibrary {
  static final MusicLibrary _instance = MusicLibrary._();
  factory MusicLibrary() => _instance;
  MusicLibrary._();

  static const List<SongData> songs = [
    SongData(
      id: 'happy_day',
      title: 'Happy Day',
      artist: 'Demo',
      duration: Duration(minutes: 1, seconds: 30),
      difficulty: 'ง่าย',
      assetPath: 'assets/music/happy_day.mp3',
      bpm: 100,
    ),
    SongData(
      id: 'morning_light',
      title: 'Morning Light',
      artist: 'Demo',
      duration: Duration(minutes: 2, seconds: 0),
      difficulty: 'ปานกลาง',
      assetPath: 'assets/music/morning_light.mp3',
      bpm: 120,
    ),
    SongData(
      id: 'canon_d',
      title: 'Canon in D',
      artist: 'Demo',
      duration: Duration(minutes: 2, seconds: 30),
      difficulty: 'ยาก',
      assetPath: 'assets/music/canon_d.mp3',
      bpm: 80,
    ),
    SongData(
      id: 'twinkle_star',
      title: 'Twinkle Star',
      artist: 'Demo',
      duration: Duration(minutes: 1, seconds: 0),
      difficulty: 'ง่าย',
      assetPath: 'assets/music/twinkle_star.mp3',
      bpm: 90,
    ),
  ];

  List<SongData> getSongs() => songs;

  SongData? getSongById(String id) {
    try {
      return songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

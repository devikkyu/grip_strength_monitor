import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/features/game/models/song_data.dart';
import 'package:grip_strength_monitor/features/game/services/music_library.dart';
import 'package:grip_strength_monitor/features/game/music_rhythm_screen.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';

class MusicSelectionScreen extends StatefulWidget {
  const MusicSelectionScreen({super.key});

  @override
  State<MusicSelectionScreen> createState() => _MusicSelectionScreenState();
}

class _MusicSelectionScreenState extends State<MusicSelectionScreen> {
  final _library = MusicLibrary();
  final _sound = SoundService();
  String _selectedDifficulty = 'ทั้งหมด';
  final _difficulties = ['ทั้งหมด', 'ง่าย', 'ปานกลาง', 'ยาก'];

  List<SongData> get _filteredSongs {
    if (_selectedDifficulty == 'ทั้งหมด') return _library.getSongs();
    return _library.getSongs().where((s) => s.difficulty == _selectedDifficulty).toList();
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'ง่าย': return AppTheme.accentGreen;
      case 'ปานกลาง': return AppTheme.warningOrange;
      case 'ยาก': return AppTheme.riskRed;
      default: return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('เลือกเพลง'),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(child: _buildSongList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.library_music_rounded, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text('เพลงทั้งหมด ${_library.getSongs().length} เพลง',
              style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          SizedBox(height: 4),
          Text('เลือกเพลงแล้วบีบมือตามจังหวะ!',
              style: GoogleFonts.sarabun(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: _difficulties.map((d) {
          final selected = _selectedDifficulty == d;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(d, style: GoogleFonts.sarabun(
                  fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : AppTheme.textSecondary)),
              selected: selected,
              onSelected: (_) {
                _sound.playTap();
                setState(() => _selectedDifficulty = d);
              },
              selectedColor: AppTheme.primary,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSongList() {
    final songs = _filteredSongs;
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off_rounded, size: 64, color: AppTheme.textTertiary),
            SizedBox(height: 16),
            Text('ไม่พบเพลง', style: GoogleFonts.sarabun(fontSize: 16, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: songs.length,
      itemBuilder: (context, index) => _buildSongCard(songs[index]),
    );
  }

  Widget _buildSongCard(SongData song) {
    final color = _difficultyColor(song.difficulty);
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _sound.playButton();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MusicRhythmScreen(song: song)),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.music_note_rounded, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: GoogleFonts.sarabun(
                          fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      SizedBox(height: 4),
                      Text(song.artist, style: GoogleFonts.sarabun(
                          fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(song.difficulty, style: GoogleFonts.sarabun(
                          fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                    ),
                    SizedBox(height: 6),
                    Text(song.durationFormatted, style: GoogleFonts.sarabun(
                        fontSize: 12, color: AppTheme.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

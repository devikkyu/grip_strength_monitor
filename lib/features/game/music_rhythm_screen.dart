import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/features/game/models/song_data.dart';
import 'package:grip_strength_monitor/features/game/services/audio_manager.dart';
import 'package:grip_strength_monitor/features/game/services/beatmap_generator.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';

class MusicRhythmScreen extends StatefulWidget {
  final SongData song;
  const MusicRhythmScreen({super.key, required this.song});

  @override
  State<MusicRhythmScreen> createState() => _MusicRhythmScreenState();
}

class _ActiveNote {
  final BeatNote beat;
  double y = -80;
  bool hit = false;
  bool missed = false;

  _ActiveNote({required this.beat});
}

class _MusicRhythmScreenState extends State<MusicRhythmScreen> {
  final SoundService _sound = SoundService();
  final AudioManager _audio = AudioManager();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  bool _endGameCalled = false;

  bool _isGameStarted = false;
  bool _isGameOver = false;
  bool _isPaused = false;
  bool _isLoading = true;
  bool _loadFailed = false;

  int _score = 0;
  int _perfect = 0;
  int _good = 0;
  int _miss = 0;
  int _maxCombo = 0;
  int _combo = 0;

  List<_ActiveNote> _activeNotes = [];
  List<BeatNote> _beatMap = [];
  int _nextBeatIndex = 0;
  int _processedBeats = 0;

  static const double _travelTimeMs = 2000;
  static const double _hitWindowPerfect = 50;
  static const double _hitWindowGood = 120;
  static const double _hitWindowOk = 200;

  @override
  void initState() {
    super.initState();
    _loadSong();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _audio.stop();
    super.dispose();
  }

  Future<void> _loadSong() async {
    final success = await _audio.loadSong(widget.song);
    if (!mounted) return;

    if (success) {
      final actualDuration = _audio.duration;
      _beatMap = BeatmapGenerator.generate(
        bpm: widget.song.bpm,
        duration: actualDuration,
      );
      _beatMap = BeatmapGenerator.validate(
        beatMap: _beatMap,
        songDuration: actualDuration,
      );
      setState(() => _isLoading = false);
    } else {
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _startGame() async {
    if (_beatMap.isEmpty) return;

    _sound.playGameStart();
    _endGameCalled = false;

    setState(() {
      _isGameStarted = true;
      _isGameOver = false;
      _score = 0;
      _perfect = 0;
      _good = 0;
      _miss = 0;
      _maxCombo = 0;
      _combo = 0;
      _activeNotes = [];
      _nextBeatIndex = 0;
      _processedBeats = 0;
    });

    await _audio.play();

    if (!mounted) return;

    _positionSub?.cancel();
    _positionSub = _audio.positionStream.listen(_onAudioPosition);

    _stateSub?.cancel();
    _stateSub = _audio.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _checkGameEnd(audioCompleted: true);
      }
    });
  }

  void _onAudioPosition(Duration position) {
    if (!mounted || _isPaused || _isGameOver || !_isGameStarted) return;

    final nowMs = position.inMilliseconds;
    final h = MediaQuery.of(context).size.height;
    final hitY = h * 0.60;

    while (_nextBeatIndex < _beatMap.length) {
      final beat = _beatMap[_nextBeatIndex];
      final spawnTimeMs = beat.timestampMs - _travelTimeMs.toInt();
      if (nowMs >= spawnTimeMs) {
        _activeNotes.add(_ActiveNote(beat: beat));
        _nextBeatIndex++;
      } else {
        break;
      }
    }

    for (var note in List<_ActiveNote>.from(_activeNotes)) {
      if (note.hit || note.missed) continue;

      final timeUntilHit = note.beat.timestampMs - nowMs;
      note.y = hitY - (timeUntilHit / _travelTimeMs * hitY);

      if (timeUntilHit < -_hitWindowOk) {
        note.missed = true;
        _miss++;
        _combo = 0;
        _processedBeats++;
        _sound.playError();
      }
    }

    _activeNotes.removeWhere((n) => n.y > h + 200);

    _checkGameEnd(audioCompleted: false);

    if (mounted) setState(() {});
  }

  void _checkGameEnd({required bool audioCompleted}) {
    if (_endGameCalled) return;

    final allNotesProcessed = _processedBeats >= _beatMap.length;
    final noActiveNotes = _activeNotes.every((n) => n.hit || n.missed);

    if (audioCompleted || (allNotesProcessed && noActiveNotes)) {
      _endGame();
    }
  }

  void _onTap() {
    if (!mounted || _isGameOver || !_isGameStarted || _isPaused) return;

    final nowMs = _audio.position.inMilliseconds;

    _ActiveNote? bestNote;
    double bestDist = double.infinity;

    for (var note in _activeNotes) {
      if (note.hit || note.missed) continue;

      final timeDiff = (note.beat.timestampMs - nowMs).abs().toDouble();
      if (timeDiff < bestDist && timeDiff < _hitWindowOk) {
        bestDist = timeDiff;
        bestNote = note;
      }
    }

    if (bestNote != null) {
      bestNote.hit = true;
      _processedBeats++;
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;

      if (bestDist < _hitWindowPerfect) {
        _score += 100;
        _perfect++;
        _sound.playPerfect();
        _fb('PERFECT!', AppTheme.accentGreen);
      } else if (bestDist < _hitWindowGood) {
        _score += 50;
        _good++;
        _sound.playBeat();
        _fb('GOOD', AppTheme.primary);
      } else {
        _score += 20;
        _good++;
        _sound.playTap();
        _fb('OK', AppTheme.warningOrange);
      }
    } else {
      _miss++;
      _combo = 0;
      _sound.playError();
      _fb('MISS', AppTheme.riskRed);
    }
  }

  void _fb(String t, Color c) {
    if (!mounted) return;
    final o = Overlay.of(context);
    final e = OverlayEntry(builder: (_) => Positioned(
      top: MediaQuery.of(context).size.height * 0.35, left: 0, right: 0,
      child: Center(child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0), duration: Duration(milliseconds: 500),
        builder: (_, v, __) => Transform.translate(
          offset: Offset(0, -20 * (1 - v)),
          child: Opacity(opacity: v, child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
            child: Text(t, style: GoogleFonts.sarabun(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          )),
        ),
      )),
    ));
    o.insert(e);
    Future.delayed(Duration(milliseconds: 500), () {
      if (e.mounted) e.remove();
    });
  }

  void _endGame() {
    if (_endGameCalled) return;
    _endGameCalled = true;

    _positionSub?.cancel();
    _stateSub?.cancel();
    _audio.stop();
    _sound.playGameOver();
    if (mounted) context.read<TodoProvider>().onGameCompleted(_score);

    if (!mounted) return;
    setState(() { _isGameOver = true; _isGameStarted = false; });

    final totalNotes = _beatMap.length;
    final accuracy = totalNotes > 0 ? ((_perfect + _good) / totalNotes * 100).round() : 0;

    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]), shape: BoxShape.circle),
          child: Icon(Icons.music_note_rounded, color: Colors.white, size: 40)),
        SizedBox(height: 16),
        Text('เล่นจบแล้ว!', style: GoogleFonts.sarabun(fontSize: 22, fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        _resultRow('คะแนน', '$_score', AppTheme.primary),
        _resultRow('ความแม่น', '$accuracy%', AppTheme.accentGreen),
        _resultRow('Max Combo', '$_maxCombo', AppTheme.warningOrange),
        _resultRow('PERFECT', '$_perfect', AppTheme.accentGreen),
        _resultRow('GOOD', '$_good', AppTheme.primary),
        _resultRow('MISS', '$_miss', AppTheme.riskRed),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); },
          child: Text('กลับ', style: GoogleFonts.sarabun(color: AppTheme.primary))),
        ElevatedButton(onPressed: () { Navigator.pop(context); _startGame(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: Text('เล่นอีก', style: GoogleFonts.sarabun(color: Colors.white))),
      ],
    ));
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.sarabun(fontSize: 14, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  void _togglePause() {
    _sound.playTap();
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _audio.pause();
    } else {
      _audio.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(widget.song.title),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          if (_isGameStarted && !_isGameOver)
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
              onPressed: _togglePause,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _loadFailed
              ? _buildErrorView()
              : _isGameStarted ? _buildGameView() : _buildSetupView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.riskRed),
          SizedBox(height: 16),
          Text('ไม่สามารถโหลดเพลงได้', style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('ตรวจสอบไฟล์เพลงใน assets/music/', style: GoogleFonts.sarabun(fontSize: 14, color: AppTheme.textSecondary)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: Text('กลับ', style: GoogleFonts.sarabun(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupView() {
    final song = widget.song;
    final noteCount = _beatMap.length;
    final lastNoteMs = noteCount > 0 ? _beatMap.last.timestampMs : 0;
    final lastNoteSec = (lastNoteMs / 1000).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Icon(Icons.music_note_rounded, color: Colors.white, size: 48),
              SizedBox(height: 12),
              Text(song.title, style: GoogleFonts.sarabun(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 4),
              Text(song.artist, style: GoogleFonts.sarabun(fontSize: 14, color: Colors.white70)),
            ]),
          ),
          SizedBox(height: 24),
          _infoRow('BPM', '${song.bpm.round()}'),
          _infoRow('Difficulty', song.difficulty),
          _infoRow('Duration', '${_audio.duration.inSeconds} วินาที'),
          _infoRow('Notes', '$noteCount'),
          _infoRow('Last Note', '$lastNoteSec วินาที'),
          Spacer(),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _beatMap.isNotEmpty ? _startGame : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_arrow_rounded, size: 28),
                SizedBox(width: 8),
                Text('เริ่มเล่น', style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.sarabun(fontSize: 15, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.sarabun(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final hitY = h * 0.60;
    final totalBeats = _beatMap.length;
    final progress = totalBeats > 0 ? _processedBeats / totalBeats : 0.0;

    return GestureDetector(
      onTap: _onTap, behavior: HitTestBehavior.opaque,
      child: Column(children: [
        _buildHeader(),
        Expanded(child: Stack(children: [
          Container(color: AppTheme.backgroundWhite),
          Positioned(left: 0, right: 0, top: hitY - 2, child: Container(height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary.withValues(alpha: 0), AppTheme.primary, AppTheme.primary.withValues(alpha: 0)]),
              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8)]))),
          for (var note in _activeNotes.where((n) => !n.hit))
            Positioned(
              left: (w - 60) / 2, top: note.y,
              child: Container(
                width: 60, height: note.beat.isLong ? 120 : 60,
                decoration: BoxDecoration(
                  color: note.missed ? AppTheme.riskRed : (note.beat.isLong ? AppTheme.primaryLight : AppTheme.primary),
                  borderRadius: BorderRadius.circular(note.beat.isLong ? 14 : 30),
                  boxShadow: [BoxShadow(color: (note.beat.isLong ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.4), blurRadius: 12, offset: Offset(0, 4))]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(note.beat.isLong ? Icons.keyboard_double_arrow_down_rounded : Icons.bolt_rounded, color: Colors.white, size: note.beat.isLong ? 24 : 22),
                ]))),
          Positioned(bottom: 20, left: 20, right: 20, child: Column(children: [
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: progress, minHeight: 6,
              backgroundColor: AppTheme.systemGray6, valueColor: AlwaysStoppedAnimation(AppTheme.primary))),
            SizedBox(height: 8),
            Text('$_processedBeats / $totalBeats', style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ])),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.08), blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('คะแนน', style: GoogleFonts.sarabun(fontSize: 11, color: AppTheme.textSecondary)),
          Text('$_score', style: GoogleFonts.sarabun(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('Combo', style: GoogleFonts.sarabun(fontSize: 11, color: AppTheme.textSecondary)),
          Text('$_combo', style: GoogleFonts.sarabun(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('PERFECT', style: GoogleFonts.sarabun(fontSize: 11, color: AppTheme.accentGreen)),
          Text('$_perfect', style: GoogleFonts.sarabun(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.accentGreen)),
        ]),
      ]),
    );
  }
}

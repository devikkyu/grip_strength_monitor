import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/services/music_service.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';

class MusicRhythmScreen extends StatefulWidget {
  const MusicRhythmScreen({super.key});

  @override
  State<MusicRhythmScreen> createState() => _MusicRhythmScreenState();
}

class _GameNote {
  double y;
  final bool isLong;
  bool hit;
  bool missed;
  _GameNote({required this.y, required this.isLong, this.hit = false, this.missed = false});
}

class _MusicRhythmScreenState extends State<MusicRhythmScreen> {
  final SoundService _sound = SoundService();
  final MusicService _music = MusicService();
  final TextEditingController _urlController = TextEditingController();
  final Random _rand = Random();

  bool _isLoading = false;
  bool _isGameStarted = false;
  bool _isGameOver = false;
  bool _isPaused = false;
  String? _loadError;
  bool _songLoaded = false;
  bool _useDemo = false;

  int _score = 0;
  int _lives = 3;
  int _perfect = 0;
  int _good = 0;
  int _miss = 0;
  int _combo = 0;

  List<_GameNote> _notes = [];
  Timer? _gameTimer;
  double _elapsed = 0;
  double _nextSpawn = 0;
  int _spawned = 0;
  int _total = 25;
  double _bpm = 100;

  @override
  void dispose() {
    _urlController.dispose();
    _gameTimer?.cancel();
    _music.stop();
    super.dispose();
  }

  Future<void> _loadSong() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _loadError = 'กรุณาใส่ YouTube URL');
      return;
    }

    setState(() { _isLoading = true; _loadError = null; });

    try {
      final success = await _music.loadFromYouTube(url);
      if (success) {
        setState(() {
          _isLoading = false;
          _songLoaded = true;
          _bpm = _music.currentBPM;
          _total = (_music.totalDuration.inSeconds * (_bpm / 60)).round().clamp(15, 50);
        });
      } else {
        setState(() {
          _isLoading = false;
          _loadError = 'ไม่สามารถโหลดเพลงได้ ลองใส่ URL ใหม่ หรือใช้โหมดสาธิต';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  void _startDemoMode() {
    setState(() {
      _useDemo = true;
      _songLoaded = true;
      _bpm = 100;
      _total = 25;
    });
  }

  void _startGame() {
    _sound.playGameStart();
    if (!_useDemo && _songLoaded) {
      _music.play();
    }

    setState(() {
      _isGameStarted = true;
      _isGameOver = false;
      _score = 0;
      _lives = 3;
      _perfect = 0;
      _good = 0;
      _miss = 0;
      _combo = 0;
      _notes = [];
      _elapsed = 0;
      _nextSpawn = 0;
      _spawned = 0;
    });

    _startGameLoop();
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    if (_isPaused || _isGameOver || !_isGameStarted) return;
    final dt = 0.016;
    _elapsed += dt;

    final h = MediaQuery.of(context).size.height;
    final speed = _bpm * 2.2;
    final beatInterval = 60.0 / _bpm;

    if (_spawned < _total && _elapsed >= _nextSpawn) {
      final isLong = _rand.nextDouble() < 0.3;
      _notes.add(_GameNote(y: -80, isLong: isLong));
      _spawned++;
      _nextSpawn = _elapsed + beatInterval + (_rand.nextDouble() * 0.2 - 0.1);
    }

    for (var n in _notes) {
      if (!n.hit && !n.missed) n.y += speed * dt;
    }

    final hitY = h * 0.60;
    for (var n in _notes) {
      if (!n.hit && !n.missed && n.y > hitY + 100) {
        n.missed = true;
        _miss++;
        _lives--;
        _combo = 0;
        _sound.playError();
      }
    }

    _notes.removeWhere((n) => n.y > h + 100);

    if (_lives <= 0 || (_spawned >= _total && _notes.every((n) => n.hit || n.missed))) {
      _endGame();
      return;
    }
    setState(() {});
  }

  void _tap() {
    if (_isGameOver || !_isGameStarted) return;
    final h = MediaQuery.of(context).size.height;
    final hitY = h * 0.60;

    _GameNote? best;
    for (var n in _notes) {
      if (!n.hit && !n.missed && (n.y - hitY).abs() < 150) {
        if (best == null || (n.y - hitY).abs() < (best.y - hitY).abs()) best = n;
      }
    }

    if (best != null) {
      final d = (best.y - hitY).abs();
      if (d < 30) { _score += 100; _perfect++; _combo++; _sound.playPerfect(); _fb('PERFECT!', AppTheme.accentGreen); }
      else if (d < 80) { _score += 50; _good++; _combo++; _sound.playBeat(); _fb('GOOD', AppTheme.primaryPink); }
      else { _score += 20; _good++; _combo++; _sound.playTap(); _fb('OK', AppTheme.warningOrange); }
      best.hit = true;
    } else {
      _miss++;
      _lives--;
      _combo = 0;
      _sound.playError();
      _fb('MISS', AppTheme.riskRed);
    }
  }

  void _fb(String t, Color c) {
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
    Future.delayed(Duration(milliseconds: 500), () => e.remove());
  }

  void _endGame() {
    _gameTimer?.cancel();
    _music.stop();
    _sound.playGameOver();
    if (mounted) context.read<TodoProvider>().onGameCompleted(_score);

    setState(() { _isGameOver = true; _isGameStarted = false; });

    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryPink, AppTheme.primaryLightPink]), shape: BoxShape.circle),
          child: Icon(Icons.music_note_rounded, color: Colors.white, size: 40)),
        SizedBox(height: 16),
        Text('เล่นจบแล้ว!', style: GoogleFonts.sarabun(fontSize: 22, fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Text('$_score คะแนน', style: GoogleFonts.sarabun(fontSize: 18, color: AppTheme.primaryPink, fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text('PERFECT $_perfect | GOOD $_good | MISS $_miss', style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); },
          child: Text('กลับ', style: GoogleFonts.sarabun(color: AppTheme.primaryPink))),
        ElevatedButton(onPressed: () { Navigator.pop(context); _startGame(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink),
          child: Text('เล่นอีก', style: GoogleFonts.sarabun(color: Colors.white))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('เล่นเพลงจาก YouTube'),
        backgroundColor: AppTheme.backgroundWhite, foregroundColor: AppTheme.textPrimary, elevation: 0,
        actions: [
          if (_isGameStarted && !_isGameOver)
            IconButton(icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
              onPressed: () {
                setState(() => _isPaused = !_isPaused);
                if (!_isPaused && !_useDemo) _music.play();
                else if (!_useDemo) _music.pause();
              }),
        ],
      ),
      body: _isGameStarted ? _buildGameView() : _buildSetupView(),
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryPink, AppTheme.primaryLightPink]),
            borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Icon(Icons.library_music_rounded, color: Colors.white, size: 48),
            SizedBox(height: 12),
            Text('เล่นเพลงจาก YouTube', style: GoogleFonts.sarabun(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 4),
            Text('ใส่ลิงก์เพลง แล้วบีบมือตามจังหวะ!', style: GoogleFonts.sarabun(fontSize: 14, color: Colors.white70)),
          ])),
        SizedBox(height: 24),
        Text('YouTube URL', style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        SizedBox(height: 8),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'https://youtube.com/watch?v=...',
            hintStyle: GoogleFonts.sarabun(color: AppTheme.textTertiary),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: Icon(Icons.link_rounded, color: AppTheme.primaryPink),
          ),
          style: GoogleFonts.sarabun(),
        ),
        if (_loadError != null) ...[
          SizedBox(height: 8),
          Container(width: double.infinity, padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.riskRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.riskRed, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text(_loadError!, style: GoogleFonts.sarabun(color: AppTheme.riskRed, fontSize: 13))),
            ])),
        ],
        SizedBox(height: 16),
        Row(children: [
          Expanded(child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loadSong,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('โหลดเพลง', style: GoogleFonts.sarabun(fontWeight: FontWeight.w600)),
            ))),
          SizedBox(width: 12),
          Expanded(child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _startDemoMode,
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryPink,
                side: BorderSide(color: AppTheme.primaryPink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('โหมดสาธิต', style: GoogleFonts.sarabun(fontWeight: FontWeight.w600)),
            ))),
        ]),
        if (_songLoaded) ...[
          SizedBox(height: 24),
          Container(width: double.infinity, padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.1), blurRadius: 8, offset: Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_useDemo ? Icons.music_off_rounded : Icons.music_note_rounded,
                  color: AppTheme.primaryPink, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text(
                  _useDemo ? 'โหมดสาธิต (ไม่มีเสียงเพลง)' : (_music.currentTitle.isNotEmpty ? _music.currentTitle : 'เพลงพร้อมเล่น'),
                  style: GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
              SizedBox(height: 8),
              Row(children: [
                _chip('BPM ${_bpm.round()}', AppTheme.primaryPink),
                SizedBox(width: 8),
                _chip('$_total โน้ต', AppTheme.accentGreen),
              ]),
            ])),
          SizedBox(height: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('ความเร็ว (BPM)', style: GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${_bpm.round()}', style: GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryPink)),
            ]),
            Slider(value: _bpm, min: 40, max: 160, activeColor: AppTheme.primaryPink,
              onChanged: (v) => setState(() { _bpm = v; _music.setBPM(v); })),
          ]),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_arrow_rounded, size: 28), SizedBox(width: 8),
                Text('เริ่มเล่น', style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w600)),
              ]))),
        ],
      ]),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.sarabun(fontSize: 12, fontWeight: FontWeight.w600, color: color)));
  }

  Widget _buildGameView() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final hitY = h * 0.60;

    return GestureDetector(
      onTap: _tap, behavior: HitTestBehavior.opaque,
      child: Column(children: [
        _buildHeader(),
        Expanded(child: Stack(children: [
          Container(color: AppTheme.backgroundWhite),
          Positioned(left: 0, right: 0, top: hitY - 2, child: Container(height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryPink.withValues(alpha: 0), AppTheme.primaryPink, AppTheme.primaryPink.withValues(alpha: 0)],
                begin: Alignment.centerLeft, end: Alignment.centerRight),
              boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.3), blurRadius: 8)]))),
          for (var n in _notes.where((n) => !n.hit))
            Positioned(
              left: (w - 60) / 2, top: n.y,
              child: Container(
                width: 60, height: n.isLong ? 120 : 60,
                decoration: BoxDecoration(
                  color: n.missed ? AppTheme.riskRed : (n.isLong ? AppTheme.primaryLightPink : AppTheme.primaryPink),
                  borderRadius: BorderRadius.circular(n.isLong ? 14 : 30),
                  boxShadow: [BoxShadow(color: (n.isLong ? AppTheme.primaryLightPink : AppTheme.primaryPink).withValues(alpha: 0.4), blurRadius: 12, offset: Offset(0, 4))]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(n.isLong ? Icons.keyboard_double_arrow_down_rounded : Icons.bolt_rounded, color: Colors.white, size: n.isLong ? 24 : 22),
                  if (n.isLong) ...[SizedBox(height: 2),
                    Text('ยาว', style: GoogleFonts.sarabun(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))],
                ]))),
          Positioned(bottom: 20, left: 20, right: 20, child: Column(children: [
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: _total > 0 ? _spawned / _total : 0, minHeight: 6,
              backgroundColor: AppTheme.systemGray6, valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink))),
            SizedBox(height: 8),
            Text('$_spawned / $_total', style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ])),
      ]));
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.08), blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('คะแนน', style: GoogleFonts.sarabun(fontSize: 11, color: AppTheme.textSecondary)),
          Text('$_score', style: GoogleFonts.sarabun(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primaryPink)),
        ]),
        Row(children: List.generate(3, (i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Icon(i < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: i < _lives ? AppTheme.riskRed : AppTheme.textTertiary, size: 24)))),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('BPM', style: GoogleFonts.sarabun(fontSize: 11, color: AppTheme.textSecondary)),
          Text('${_bpm.round()}', style: GoogleFonts.sarabun(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ]),
      ]));
  }
}

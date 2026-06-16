import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';
import 'widgets/game_over_dialog.dart';

class GripRhythmGameScreen extends StatefulWidget {
  const GripRhythmGameScreen({super.key});

  @override
  State<GripRhythmGameScreen> createState() => _GripRhythmGameScreenState();
}

class _GameNote {
  double y;
  final bool isLong;
  bool hit;
  bool missed;
  _GameNote({required this.y, required this.isLong, this.hit = false, this.missed = false});
}

class _GripRhythmGameScreenState extends State<GripRhythmGameScreen> {
  final SoundService _sound = SoundService();
  final Random _rand = Random();

  bool _started = false;
  bool _over = false;
  bool _paused = false;
  int _difficulty = 1;

  int _score = 0;
  int _lives = 3;
  int _perfect = 0;
  int _good = 0;
  int _miss = 0;
  int _combo = 0;

  List<_GameNote> _notes = [];
  Timer? _timer;
  double _elapsed = 0;
  double _nextSpawn = 0;
  int _spawned = 0;
  int _total = 20;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _start() {
    _sound.playGameStart();
    final count = _difficulty == 0 ? 12 : _difficulty == 1 ? 20 : 30;
    setState(() {
      _started = true; _over = false; _paused = false;
      _score = 0; _lives = 3; _perfect = 0; _good = 0; _miss = 0; _combo = 0;
      _notes = []; _elapsed = 0; _nextSpawn = 0.5; _spawned = 0; _total = count;
    });
    _timer = Timer.periodic(Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    if (_paused || _over || !_started) return;
    final dt = 0.016;
    _elapsed += dt;

    final h = MediaQuery.of(context).size.height;
    final speed = _difficulty == 0 ? 180.0 : _difficulty == 1 ? 250.0 : 350.0;

    if (_spawned < _total && _elapsed >= _nextSpawn) {
      final isLong = _rand.nextDouble() < 0.35;
      _notes.add(_GameNote(y: -60, isLong: isLong));
      _spawned++;
      final minD = _difficulty == 0 ? 1.2 : _difficulty == 1 ? 0.8 : 0.5;
      final maxD = _difficulty == 0 ? 2.5 : _difficulty == 1 ? 1.8 : 1.2;
      _nextSpawn = _elapsed + minD + _rand.nextDouble() * (maxD - minD);
    }

    for (var n in _notes) {
      if (!n.hit && !n.missed) n.y += speed * dt;
    }

    final hitY = h * 0.60;
    for (var n in _notes) {
      if (!n.hit && !n.missed && n.y > hitY + 80) {
        n.missed = true;
        _miss++; _lives--; _combo = 0;
        _sound.playError();
      }
    }

    _notes.removeWhere((n) => n.y > h + 100);

    if (_lives <= 0) { _end(); return; }
    if (_spawned >= _total && _notes.every((n) => n.hit || n.missed)) { _end(); return; }
    setState(() {});
  }

  void _tap() {
    if (_over || !_started) return;
    final h = MediaQuery.of(context).size.height;
    final hitY = h * 0.60;

    _GameNote? best;
    for (var n in _notes) {
      if (!n.hit && !n.missed && (n.y - hitY).abs() < 120) {
        if (best == null || (n.y - hitY).abs() < (best.y - hitY).abs()) best = n;
      }
    }

    if (best != null) {
      final d = (best.y - hitY).abs();
      if (d < 30) { _score += 100; _perfect++; _combo++; _sound.playPerfect(); _fb('PERFECT!', AppTheme.accentGreen); }
      else if (d < 70) { _score += 50; _good++; _combo++; _sound.playBeat(); _fb('GOOD', AppTheme.primaryPink); }
      else { _score += 20; _good++; _combo++; _sound.playTap(); _fb('OK', AppTheme.warningOrange); }
      best.hit = true;
    } else {
      _miss++; _lives--; _combo = 0; _sound.playError(); _fb('MISS', AppTheme.riskRed);
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

  void _end() {
    _timer?.cancel();
    _sound.playGameOver();
    if (mounted) context.read<TodoProvider>().onGameCompleted(_score);
    setState(() { _over = true; _started = false; });
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameOverDialog(
      score: _score, perfectCount: _perfect, goodCount: _good, missCount: _miss,
      onPlayAgain: () { Navigator.pop(context); _start(); },
      onGoHome: () { Navigator.pop(context); Navigator.pop(context); },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.get('gripRhythm')),
        backgroundColor: AppTheme.backgroundWhite, foregroundColor: AppTheme.textPrimary, elevation: 0,
        actions: [
          if (_started && !_over) IconButton(
            icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: () { _sound.playTap(); setState(() => _paused = !_paused); },
          ),
        ],
      ),
      body: _started ? _game() : _menu(),
    );
  }

  Widget _menu() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(children: [
        Container(width: 120, height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryPink, AppTheme.primaryLightPink]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.4), blurRadius: 24, offset: Offset(0, 12))],
          ),
          child: Icon(Icons.music_note_rounded, color: Colors.white, size: 56),
        ),
        SizedBox(height: 24),
        Text(AppLocalizations.get('gripRhythm'), style: GoogleFonts.sarabun(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        SizedBox(height: 8),
        Text(AppLocalizations.get('gripRhythmDesc'), textAlign: TextAlign.center,
          style: GoogleFonts.sarabun(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        SizedBox(height: 32),
        _diffRow(),
        SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
          onPressed: _start,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.play_arrow_rounded, size: 28), SizedBox(width: 8),
            Text(AppLocalizations.get('startGame'), style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w600)),
          ]),
        )),
      ]),
    );
  }

  Widget _diffRow() {
    final labels = ['ง่าย', 'ปานกลาง', 'ยาก'];
    final icons = [Icons.sentiment_satisfied_rounded, Icons.sentiment_neutral_rounded, Icons.sentiment_very_dissatisfied_rounded];
    final cols = [AppTheme.accentGreen, AppTheme.primaryPink, AppTheme.riskRed];
    return Row(children: List.generate(3, (i) {
      final sel = _difficulty == i;
      return Expanded(child: GestureDetector(
        onTap: () { _sound.playClick(); setState(() => _difficulty = i); },
        child: AnimatedContainer(duration: Duration(milliseconds: 250), margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: sel ? cols[i] : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12),
            boxShadow: sel ? [BoxShadow(color: cols[i].withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 4))] : [],
          ),
          child: Column(children: [
            Icon(icons[i], color: sel ? Colors.white : AppTheme.textSecondary, size: 28),
            SizedBox(height: 8),
            Text(labels[i], style: GoogleFonts.sarabun(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary)),
          ]),
        ),
      ));
    }));
  }

  Widget _game() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final hitY = h * 0.60;

    return GestureDetector(
      onTap: _tap, behavior: HitTestBehavior.opaque,
      child: Column(children: [
        _header(),
        Expanded(child: Stack(children: [
          Container(color: AppTheme.backgroundWhite),
          Positioned(left: 0, right: 0, top: hitY - 2, child: Container(height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryPink.withValues(alpha: 0), AppTheme.primaryPink, AppTheme.primaryPink.withValues(alpha: 0)],
                begin: Alignment.centerLeft, end: Alignment.centerRight),
              boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.3), blurRadius: 8)],
            ),
          )),
          for (var n in _notes.where((n) => !n.hit))
            Positioned(
              left: (w - 60) / 2,
              top: n.y,
              child: Container(
                width: 60, height: n.isLong ? 120 : 60,
                decoration: BoxDecoration(
                  color: n.missed ? AppTheme.riskRed : (n.isLong ? AppTheme.primaryLightPink : AppTheme.primaryPink),
                  borderRadius: BorderRadius.circular(n.isLong ? 14 : 30),
                  boxShadow: [BoxShadow(
                    color: (n.isLong ? AppTheme.primaryLightPink : AppTheme.primaryPink).withValues(alpha: 0.4),
                    blurRadius: 12, offset: Offset(0, 4),
                  )],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(n.isLong ? Icons.keyboard_double_arrow_down_rounded : Icons.bolt_rounded,
                    color: Colors.white, size: n.isLong ? 24 : 22),
                  if (n.isLong) ...[SizedBox(height: 2),
                    Text('ยาว', style: GoogleFonts.sarabun(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))],
                ]),
              ),
            ),
          Positioned(bottom: 20, left: 20, right: 20, child: Column(children: [
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: _total > 0 ? _spawned / _total : 0, minHeight: 6,
              backgroundColor: AppTheme.systemGray6, valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink))),
            SizedBox(height: 8),
            Text('$_spawned / $_total', style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ])),
      ]),
    );
  }

  Widget _header() {
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
            color: i < _lives ? AppTheme.riskRed : AppTheme.textTertiary, size: 24),
        ))),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('COMBO', style: GoogleFonts.sarabun(fontSize: 11, color: AppTheme.textSecondary)),
          Text('$_combo', style: GoogleFonts.sarabun(fontSize: 24, fontWeight: FontWeight.w700,
            color: _combo >= 5 ? AppTheme.accentGreen : AppTheme.textPrimary)),
        ]),
      ]),
    );
  }
}

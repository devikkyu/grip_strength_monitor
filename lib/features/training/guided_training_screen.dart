import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';

class GuidedTrainingScreen extends StatefulWidget {
  const GuidedTrainingScreen({super.key});

  @override
  State<GuidedTrainingScreen> createState() => _GuidedTrainingScreenState();
}

class _GuidedTrainingScreenState extends State<GuidedTrainingScreen>
    with SingleTickerProviderStateMixin {
  final SoundService _sound = SoundService();
  int _selectedLevel = 1;
  bool _isTraining = false;
  bool _isPaused = false;

  int _currentPhase = 0;
  int _currentRep = 0;
  int _totalReps = 0;
  double _elapsed = 0;
  double _phaseDuration = 0;
  bool _isOnBeat = false;
  int _bpm = 60;

  Timer? _timer;
  Timer? _metronomeTimer;
  int _metronomeCount = 0;

  final _phases = [
    {'name': 'วอร์มอัพ', 'icon': Icons.wb_sunny_rounded, 'color': Color(0xFFFFB366), 'reps': 5, 'duration': 30, 'instruction': 'บีบมือเบาๆ ตามจังหวะ'},
    {'name': 'ฝึกหลัก', 'icon': Icons.fitness_center_rounded, 'color': Color(0xFFFF6B9D), 'reps': 10, 'duration': 60, 'instruction': 'บีบมือเต็มแรงตามจังหวะ'},
    {'name': 'คูลดาวน์', 'icon': Icons.ac_unit_rounded, 'color': Color(0xFF7DD3A8), 'reps': 5, 'duration': 30, 'instruction': 'บีบมือเบาๆ ผ่อนคลาย'},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _metronomeTimer?.cancel();
    super.dispose();
  }

  void _startTraining() {
    _sound.playGameStart();
    final level = _selectedLevel;
    final repsMultiplier = level == 0 ? 0.7 : level == 1 ? 1.0 : 1.5;
    final bpmBase = level == 0 ? 50 : level == 1 ? 60 : 75;

    setState(() {
      _isTraining = true;
      _isPaused = false;
      _currentPhase = 0;
      _currentRep = 0;
      _totalReps = ((_phases[0]['reps'] as int) * repsMultiplier).round();
      _phaseDuration = (_phases[0]['duration'] as int).toDouble();
      _elapsed = 0;
      _bpm = bpmBase;
      _metronomeCount = 0;
    });

    _startMetronome();
    _startTimer();
  }

  void _startMetronome() {
    _metronomeTimer?.cancel();
    final interval = 60000 ~/ _bpm;
    _metronomeTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (!_isPaused && _isTraining) {
        HapticFeedback.lightImpact();
        setState(() {
          _metronomeCount++;
          _isOnBeat = true;
        });
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) setState(() => _isOnBeat = false);
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_isPaused || !_isTraining) return;
      _elapsed += 0.1;

      if (_elapsed >= _phaseDuration) {
        _nextRep();
      }
      setState(() {});
    });
  }

  void _nextRep() {
    _currentRep++;
    _sound.playBeat();

    if (_currentRep >= _totalReps) {
      _nextPhase();
    } else {
      _elapsed = 0;
    }
  }

  void _nextPhase() {
    _currentPhase++;
    if (_currentPhase >= _phases.length) {
      _completeTraining();
      return;
    }

    final level = _selectedLevel;
    final repsMultiplier = level == 0 ? 0.7 : level == 1 ? 1.0 : 1.5;

    setState(() {
      _currentRep = 0;
      _totalReps = ((_phases[_currentPhase]['reps'] as int) * repsMultiplier).round();
      _phaseDuration = (_phases[_currentPhase]['duration'] as int).toDouble();
      _elapsed = 0;
      _bpm += 10;
    });

    _startMetronome();
    _sound.playSuccess();
  }

  void _completeTraining() {
    _timer?.cancel();
    _metronomeTimer?.cancel();
    _sound.playGameOver();

    if (mounted) {
      context.read<TodoProvider>().onAudioRhythm();
      context.read<TodoProvider>().onConsecutiveTraining();
    }

    setState(() {
      _isTraining = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.accentGreen, AppTheme.primaryPink]),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            SizedBox(height: 16),
            Text('ฝึกเสร็จแล้ว!', style: GoogleFonts.sarabun(fontSize: 22, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('ทำได้ดีมาก ฝึกต่อไปเรื่อยๆ', style: GoogleFonts.sarabun(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: Text('กลับหน้าหลัก', style: GoogleFonts.sarabun(color: AppTheme.primaryPink)),
          ),
        ],
      ),
    );
  }

  void _pauseTraining() {
    _sound.playTap();
    setState(() => _isPaused = !_isPaused);
  }

  void _stopTraining() {
    _timer?.cancel();
    _metronomeTimer?.cancel();
    setState(() { _isTraining = false; _isPaused = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.get('guidedTraining')),
        backgroundColor: AppTheme.backgroundWhite, foregroundColor: AppTheme.textPrimary, elevation: 0,
        actions: [
          if (_isTraining)
            IconButton(icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded), onPressed: _pauseTraining),
          if (_isTraining)
            IconButton(icon: Icon(Icons.close_rounded), onPressed: _stopTraining),
        ],
      ),
      body: _isTraining ? _buildTrainingView() : _buildMenuView(),
    );
  }

  Widget _buildMenuView() {
    final levels = [
      {'name': 'เริ่มต้น', 'desc': 'ฝึกเบาๆ 15 นาที', 'bpm': '50 BPM', 'color': AppTheme.accentGreen, 'icon': Icons.sentiment_satisfied_rounded},
      {'name': 'ปานกลาง', 'desc': 'ฝึกปานกลาง 20 นาที', 'bpm': '60 BPM', 'color': AppTheme.primaryPink, 'icon': Icons.sentiment_neutral_rounded},
      {'name': 'ขั้นสูง', 'desc': 'ฝึกเข้มข้น 25 นาที', 'bpm': '75 BPM', 'color': AppTheme.riskRed, 'icon': Icons.sentiment_very_dissatisfied_rounded},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('เลือกระดับ', style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          SizedBox(height: 16),
          ...levels.asMap().entries.map((entry) {
            final i = entry.key;
            final l = entry.value;
            final sel = _selectedLevel == i;
            final color = l['color'] as Color;
            return GestureDetector(
              onTap: () { _sound.playClick(); setState(() => _selectedLevel = i); },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sel ? color : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: sel ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))] : [],
                ),
                child: Row(children: [
                  Icon(l['icon'] as IconData, color: sel ? Colors.white : color, size: 32),
                  SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l['name'] as String, style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textPrimary)),
                      Text(l['desc'] as String, style: GoogleFonts.sarabun(fontSize: 13, color: sel ? Colors.white70 : AppTheme.textSecondary)),
                    ],
                  )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l['bpm'] as String, style: GoogleFonts.sarabun(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : color)),
                  ),
                ]),
              ),
            );
          }),
          SizedBox(height: 24),
          Text('ขั้นตอนการฝึก', style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          ..._phases.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final color = p['color'] as Color;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(p['icon'] as IconData, color: color, size: 18),
                ),
                SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, style: GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(p['instruction'] as String, style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                )),
                Text('${p['reps']} ครั้ง', style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            );
          }),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _startTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_arrow_rounded, size: 28), SizedBox(width: 8),
                Text('เริ่มฝึก', style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingView() {
    final phase = _phases[_currentPhase];
    final color = phase['color'] as Color;
    final progress = _totalReps > 0 ? _currentRep / _totalReps : 0.0;
    final timeProgress = _phaseDuration > 0 ? _elapsed / _phaseDuration : 0.0;

    return Column(children: [
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(phase['name'] as String, style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('ขั้นที่ ${_currentPhase + 1}/${_phases.length}', style: GoogleFonts.sarabun(fontSize: 13, color: Colors.white70)),
            ]),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('$_bpm BPM', style: GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
          SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
            value: progress, minHeight: 6, backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          )),
          SizedBox(height: 8),
          Text('$_currentRep / $_totalReps ครั้ง', style: GoogleFonts.sarabun(fontSize: 13, color: Colors.white70)),
        ]),
      ),
      Expanded(child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            width: _isOnBeat ? 160 : 140,
            height: _isOnBeat ? 160 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isOnBeat ? color : color.withValues(alpha: 0.3),
              boxShadow: _isOnBeat ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 30)] : [],
            ),
            child: Icon(phase['icon'] as IconData, color: Colors.white, size: 64),
          ),
          SizedBox(height: 24),
          Text(phase['instruction'] as String, style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          SizedBox(height: 8),
          Text('จังหวะที่ $_metronomeCount', style: GoogleFonts.sarabun(fontSize: 14, color: AppTheme.textSecondary)),
          SizedBox(height: 32),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: timeProgress, minHeight: 8,
              backgroundColor: AppTheme.systemGray6, valueColor: AlwaysStoppedAnimation(color),
            ),
          )),
          SizedBox(height: 8),
          Text('${(_phaseDuration - _elapsed).toStringAsFixed(0)} วินาที', style: GoogleFonts.sarabun(fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ))),
    ]);
  }
}

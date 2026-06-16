import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';

class SmartRhythmScreen extends StatefulWidget {
  const SmartRhythmScreen({super.key});

  @override
  State<SmartRhythmScreen> createState() => _SmartRhythmScreenState();
}

class _SmartRhythmScreenState extends State<SmartRhythmScreen> {
  final SoundService _sound = SoundService();
  bool _isPlaying = false;
  int _currentBeat = 0;
  int _completedBeats = 0;
  Timer? _timer;
  int _selectedSpeed = 1;
  bool _isOnBeat = false;

  final _speeds = [
    {'label': 'ช้า', 'icon': Icons.hourglass_bottom_rounded, 'interval': 1200, 'color': AppTheme.accentGreen},
    {'label': 'กลาง', 'icon': Icons.schedule_rounded, 'interval': 800, 'color': AppTheme.primaryPink},
    {'label': 'เร็ว', 'icon': Icons.bolt_rounded, 'interval': 500, 'color': AppTheme.riskRed},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _sound.playGameStart();
    setState(() {
      _isPlaying = true;
      _currentBeat = 1;
      _completedBeats = 0;
    });
    _startMetronome();
  }

  void _stop() {
    _timer?.cancel();
    _sound.playError();
    setState(() {
      _isPlaying = false;
      _currentBeat = 0;
    });
    context.read<TodoProvider>().onAudioRhythm();
  }

  void _startMetronome() {
    _timer?.cancel();
    final interval = _speeds[_selectedSpeed]['interval'] as int;
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (!_isPlaying) return;
      _sound.playBeat();
      HapticFeedback.lightImpact();
      setState(() {
        _isOnBeat = true;
        _currentBeat++;
        if (_currentBeat > 4) {
          _currentBeat = 1;
          _completedBeats++;
          _sound.playSuccess();
        }
      });
      Future.delayed(Duration(milliseconds: 150), () {
        if (mounted) setState(() => _isOnBeat = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('ฝึกจังหวะ'),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBeatCircle(),
              SizedBox(height: 40),
              _buildBeatDots(),
              SizedBox(height: 40),
              _buildSpeedButtons(),
              SizedBox(height: 40),
              if (_isPlaying) _buildStopButton() else _buildStartButton(),
              if (_completedBeats > 0) ...[
                SizedBox(height: 24),
                Text(
                  '$_completedBeats รอบ',
                  style: GoogleFonts.sarabun(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeatCircle() {
    final speed = _speeds[_selectedSpeed];
    final color = speed['color'] as Color;

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: _isOnBeat ? 180 : 160,
      height: _isOnBeat ? 180 : 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _isPlaying
            ? LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [AppTheme.systemGray6, AppTheme.systemGray6],
              ),
        boxShadow: _isPlaying
            ? [
                BoxShadow(
                  color: color.withValues(alpha: _isOnBeat ? 0.5 : 0.3),
                  blurRadius: _isOnBeat ? 40 : 30,
                  offset: Offset(0, 12),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          _isPlaying ? '$_currentBeat' : '0',
          style: GoogleFonts.sarabun(
            fontSize: 72,
            fontWeight: FontWeight.w700,
            color: _isPlaying ? Colors.white : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildBeatDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isActive = _currentBeat == i + 1 && _isPlaying;
        return AnimatedContainer(
          duration: Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: 12),
          width: isActive ? 16 : 10,
          height: isActive ? 16 : 10,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryPink : AppTheme.separator,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.5), blurRadius: 8)]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildSpeedButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final speed = _speeds[i];
        final color = speed['color'] as Color;
        final label = speed['label'] as String;
        final icon = speed['icon'] as IconData;
        final sel = _selectedSpeed == i;

        return GestureDetector(
          onTap: () {
            _sound.playClick();
            setState(() => _selectedSpeed = i);
            if (_isPlaying) _startMetronome();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 90,
            margin: EdgeInsets.symmetric(horizontal: 6),
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: sel ? color : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: sel
                  ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 4))]
                  : [],
            ),
            child: Column(
              children: [
                Icon(icon, color: sel ? Colors.white : color, size: 28),
                SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.sarabun(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _start,
        icon: Icon(Icons.play_arrow_rounded, size: 32),
        label: Text('เริ่มนับ', style: GoogleFonts.sarabun(fontSize: 20, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _stop,
        icon: Icon(Icons.stop_rounded, size: 32),
        label: Text('หยุด', style: GoogleFonts.sarabun(fontSize: 20, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.riskRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

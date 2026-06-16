import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/core/utils/animations.dart';
import 'package:grip_strength_monitor/services/measurement_provider.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';

class GripMeasurementScreen extends StatefulWidget {
  const GripMeasurementScreen({super.key});

  @override
  State<GripMeasurementScreen> createState() => _GripMeasurementScreenState();
}

class _GripMeasurementScreenState extends State<GripMeasurementScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.get('gripMeasurement')),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.separator),
        ),
      ),
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, child) {
          if (provider.state.isCompleted) {
            return _buildResultView(provider);
          }
          return _buildMeasurementView(provider);
        },
      ),
    );
  }

  Widget _buildMeasurementView(MeasurementProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        children: [
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.0,
            child: _buildGripDisplay(provider),
          ),
          SizedBox(height: 40),
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.1,
            child: _buildGripChart(provider),
          ),
          SizedBox(height: 40),
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.2,
            child: _buildControls(provider),
          ),
          SizedBox(height: 40),
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.3,
            child: _buildStatsRow(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildGripDisplay(MeasurementProvider provider) {
    final isMeasuring = provider.state.isMeasuring;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isMeasuring ? 1.0 + 0.03 * _pulseController.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMeasuring
                  ? LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryLightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [AppTheme.systemGray6, AppTheme.systemGray6],
                    ),
              boxShadow: isMeasuring
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: Offset(0, 16),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isMeasuring
                        ? provider.state.currentGrip.toStringAsFixed(1)
                        : '0.0',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: isMeasuring ? Colors.white : AppTheme.textTertiary,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isMeasuring
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGripChart(MeasurementProvider provider) {
    final history = provider.state.gripHistory;
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        height: 120,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            AppLocalizations.get('pressToStart'),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(double.infinity, 88),
        painter: _GripChartPainter(history),
      ),
    );
  }

  Widget _buildControls(MeasurementProvider provider) {
    final isMeasuring = provider.state.isMeasuring;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isMeasuring)
          _buildControlButton(
            icon: Icons.play_arrow_rounded,
            label: AppLocalizations.get('startMeasurement'),
            color: AppTheme.accentGreen,
            onTap: () {
              SoundService().playGameStart();
              provider.startMeasurement();
            },
            size: 72,
          )
        else ...[
          _buildControlButton(
            icon: Icons.stop_rounded,
            label: AppLocalizations.get('stop'),
            color: AppTheme.riskRed,
            onTap: () {
              SoundService().playSuccess();
              provider.stopMeasurement();
              context.read<TodoProvider>().onMeasurementCompleted();
            },
            size: 72,
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(MeasurementProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            AppLocalizations.get('maxGrip'),
            provider.state.maxGrip.toStringAsFixed(1),
            Icons.trending_up_rounded,
            AppTheme.accentGreen,
          ),
          Container(width: 0.5, height: 40, color: AppTheme.separator),
          _buildStatItem(
            AppLocalizations.get('minGrip'),
            provider.state.minGrip.toStringAsFixed(1),
            Icons.trending_down_rounded,
            AppTheme.warningOrange,
          ),
          Container(width: 0.5, height: 40, color: AppTheme.separator),
          _buildStatItem(
            AppLocalizations.get('time'),
            _formatTime(provider.state.elapsedSeconds),
            Icons.timer_outlined,
            AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildResultView(MeasurementProvider provider) {
    final status = _getGripStatus(provider.state.avgGrip);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        children: [
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.0,
            child: _buildResultHeader(provider, status),
          ),
          SizedBox(height: 24),
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.1,
            child: _buildResultDetails(provider),
          ),
          SizedBox(height: 24),
          AppAnimations.fadeSlideUp(
            controller: _animController,
            delay: 0.2,
            child: _buildResultActions(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(MeasurementProvider provider, String status) {
    final statusColor = _getStatusColor(status);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            status == 'normal'
                ? Icons.check_circle_rounded
                : status == 'warning'
                    ? Icons.warning_rounded
                    : Icons.error_rounded,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.get('measurementComplete'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${provider.state.avgGrip.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDetails(MeasurementProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.get('details'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            AppLocalizations.get('averageGrip'),
            '${provider.state.avgGrip.toStringAsFixed(1)} kg',
            AppTheme.primaryBlue,
          ),
          _buildDetailRow(
            AppLocalizations.get('maxGrip'),
            '${provider.state.maxGrip.toStringAsFixed(1)} kg',
            AppTheme.accentGreen,
          ),
          _buildDetailRow(
            AppLocalizations.get('minGrip'),
            '${provider.state.minGrip.toStringAsFixed(1)} kg',
            AppTheme.warningOrange,
          ),
          _buildDetailRow(
            AppLocalizations.get('duration'),
            _formatTime(provider.state.elapsedSeconds),
            AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultActions(MeasurementProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              provider.resetMeasurement();
              _animController.reset();
              _animController.forward();
            },
            icon: Icon(Icons.refresh_rounded, size: 20),
            label: Text(AppLocalizations.get('measureAgain')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.home_rounded, size: 20),
            label: Text(AppLocalizations.get('backToHome')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppTheme.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  String _getGripStatus(double grip) {
    if (grip >= 40) return 'normal';
    if (grip >= 25) return 'warning';
    return 'risk';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return AppTheme.accentGreen;
      case 'warning':
        return AppTheme.warningOrange;
      case 'risk':
        return AppTheme.riskRed;
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _GripChartPainter extends CustomPainter {
  final List<double> data;

  _GripChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withValues(alpha: 0.2),
          AppTheme.primaryBlue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue =
          range > 0 ? (data[i] - minVal) / range : 0.5;
      final y =
          size.height - (normalizedValue * size.height * 0.7 + size.height * 0.15);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GripChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

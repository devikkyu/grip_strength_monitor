import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/core/utils/animations.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';
import 'package:grip_strength_monitor/services/grip_provider.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/services/websocket_service.dart';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/features/smart_rhythm/smart_rhythm_screen.dart';
import 'package:grip_strength_monitor/features/measurement/grip_measurement_screen.dart';
import 'package:grip_strength_monitor/features/streak/streak_calendar_screen.dart';
import 'package:grip_strength_monitor/features/history/training_history_screen.dart';
import 'package:grip_strength_monitor/features/report/health_report_screen.dart';
import 'package:grip_strength_monitor/features/training/guided_training_screen.dart';
import 'package:grip_strength_monitor/features/achievements/achievements_screen.dart';
import 'package:grip_strength_monitor/features/game/grip_rhythm_game_screen.dart';
import 'package:grip_strength_monitor/features/game/music_selection_screen.dart';
import 'package:grip_strength_monitor/features/game/widgets/connection_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      body: Consumer2<GripProvider, ConnectionProvider>(
        builder: (context, gripProvider, connProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.0,
                  child: _buildGreetingSection(),
                ),
                SizedBox(height: 24),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.1,
                  child: AppAnimations.pulse(
                    controller: _pulseController,
                    child: _buildStatusBanner(gripProvider, connProvider),
                  ),
                ),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.2,
                  child: _buildMainMetrics(context, gripProvider),
                ),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.3,
                  child: _buildBrainScoreCard(context, gripProvider),
                ),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.4,
                  child: _buildConnectionSection(context, connProvider),
                ),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.5,
                  child: _buildStartMeasurementButton(context),
                ),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.6,
                  child: _buildQuickActions(context),
                ),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.7,
                  child: _buildProgressSection(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = AppLocalizations.get('goodMorning');
    } else if (hour < 17) {
      greeting = AppLocalizations.get('goodAfternoon');
    } else {
      greeting = AppLocalizations.get('goodEvening');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          AppLocalizations.get('gripOverview'),
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(GripProvider gripProvider, ConnectionProvider connProvider) {
    final statusColor = _getStatusColor(gripProvider.status);
    final connStatus = connProvider.status;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
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
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(connStatus == ConnectionStatus.connected ? Icons.wifi_rounded : _getStatusIcon(gripProvider.status), color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.get('currentStatus'),
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  connStatus == ConnectionStatus.connected
                    ? 'เชื่อมต่อแล้ว'
                    : _getStatusText(gripProvider.status),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              connStatus == ConnectionStatus.connected ? 'Online' : AppLocalizations.get('viewDetails'),
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(GripStatus status) {
    switch (status) {
      case GripStatus.normal:
        return AppLocalizations.get('normal');
      case GripStatus.warning:
        return AppLocalizations.get('warning');
      case GripStatus.risk:
        return AppLocalizations.get('risk');
    }
  }

  Color _getStatusColor(GripStatus status) {
    switch (status) {
      case GripStatus.normal:
        return AppTheme.accentGreen;
      case GripStatus.warning:
        return AppTheme.warningOrange;
      case GripStatus.risk:
        return AppTheme.riskRed;
    }
  }

  IconData _getStatusIcon(GripStatus status) {
    switch (status) {
      case GripStatus.normal:
        return Icons.check_rounded;
      case GripStatus.warning:
        return Icons.warning_rounded;
      case GripStatus.risk:
        return Icons.error_rounded;
    }
  }

  Widget _buildMainMetrics(BuildContext context, GripProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            AppLocalizations.get('gripStrength'),
            '${provider.currentGrip.toStringAsFixed(0)}',
            'kg',
            Icons.fitness_center_rounded,
            AppTheme.primaryBlue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            AppLocalizations.get('maxToday'),
            '${provider.maxGripToday.toStringAsFixed(0)}',
            'kg',
            Icons.trending_up_rounded,
            AppTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: -0.5)),
              SizedBox(width: 2),
              Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(unit, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrainScoreCard(BuildContext context, GripProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryLightBlue]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
                    ),
                    SizedBox(width: 10),
                    Text(
                      AppLocalizations.get('brainScore'),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: -0.2),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '${provider.brainScore}',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, letterSpacing: -1),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.get('excellentCognitive'),
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: provider.brainScore / 100,
                  strokeWidth: 5,
                  backgroundColor: AppTheme.systemGray6,
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${provider.brainScore}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryPink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSection(BuildContext context, ConnectionProvider connProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.wifi_rounded, color: AppTheme.primaryBlue, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'การเชื่อมต่อ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  connProvider.status == ConnectionStatus.connected
                    ? 'เชื่อมต่อกับ ESP32 แล้ว'
                    : 'ยังไม่ได้เชื่อมต่ออุปกรณ์',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SoundService().playButton();
              _showConnectionDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              connProvider.status == ConnectionStatus.connected ? 'เปลี่ยน IP' : 'เชื่อมต่อ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    final connProvider = Provider.of<ConnectionProvider>(context, listen: false);
    final wsService = Provider.of<WebSocketService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => ConnectionDialog(
        connProvider: connProvider,
        wsService: wsService,
      ),
    );
  }

  Widget _buildStartMeasurementButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryLightPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            SoundService().playButton();
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 400),
                reverseTransitionDuration: Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    GripMeasurementScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.get('startMeasurement'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.get('quickActions'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickActionButton(
                Icons.music_note_rounded,
                'ฝึกจังหวะ',
                AppTheme.accentGreen,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => SmartRhythmScreen())),
              ),
              _buildQuickActionButton(
                Icons.school_rounded,
                'โปรแกรมฝึก',
                AppTheme.warningOrange,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuidedTrainingScreen())),
              ),
              _buildQuickActionButton(
                Icons.history_rounded,
                'ประวัติ',
                AppTheme.primaryBlue,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainingHistoryScreen())),
              ),
              _buildQuickActionButton(
                Icons.calendar_month_rounded,
                'ความต่อเนื่อง',
                AppTheme.warningOrange,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => StreakCalendarScreen())),
              ),
              _buildQuickActionButton(
                Icons.assessment_rounded,
                'รายงาน',
                AppTheme.primaryBlue,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthReportScreen())),
              ),
              _buildQuickActionButton(
                Icons.emoji_events_rounded,
                'รางวัล',
                AppTheme.accentGreen,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => AchievementsScreen())),
              ),
              _buildQuickActionButton(
                Icons.sports_esports_rounded,
                'เกม',
                AppTheme.primaryPink,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => GripRhythmGameScreen())),
              ),
              _buildQuickActionButton(
                Icons.library_music_rounded,
                'เล่นเพลง',
                AppTheme.accentGreen,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => MusicSelectionScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final sound = SoundService();
    return GestureDetector(
      onTap: () {
        sound.playClick();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppTheme.accentGreen.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.get('todaysProgress'),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: -0.2),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${todoProvider.completedRounds} ${AppLocalizations.get('rounds')}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentGreen),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: LinearProgressIndicator(
                    value: todoProvider.todayProgress / 100,
                    minHeight: 8,
                    backgroundColor: AppTheme.systemGray6,
                    valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                '${todoProvider.todayProgress}% ${AppLocalizations.get('completed')}',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

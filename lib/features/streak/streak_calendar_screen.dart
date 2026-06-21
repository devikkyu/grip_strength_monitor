import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/core/utils/animations.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _currentMonth = DateTime.now();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Set<DateTime> _getTrainingDates(HistoryProvider history) {
    return history.sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
  }

  List<int> _getStreakDays(HistoryProvider history) {
    final trainingDates = _getTrainingDates(history);
    return trainingDates
        .where((d) => d.year == _currentMonth.year && d.month == _currentMonth.month)
        .map((d) => d.day)
        .toList()
      ..sort();
  }

  int _getCurrentStreak(HistoryProvider history) {
    final trainingDates = _getTrainingDates(history);
    if (trainingDates.isEmpty) return 0;

    var checkDate = DateTime.now();
    var streak = 0;

    while (trainingDates.contains(DateTime(checkDate.year, checkDate.month, checkDate.day))) {
      streak++;
      checkDate = checkDate.subtract(Duration(days: 1));
    }

    return streak;
  }

  int _getLongestStreak(HistoryProvider history) {
    final trainingDates = _getTrainingDates(history);
    if (trainingDates.isEmpty) return 0;

    final sorted = trainingDates.toList()..sort();
    var longest = 1;
    var current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }

    return longest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.get('streakCalendar')),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.separator),
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, history, child) {
          final streakDays = _getStreakDays(history);
          final currentStreak = _getCurrentStreak(history);
          final longestStreak = _getLongestStreak(history);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.0,
                  child: _buildStreakStats(currentStreak, longestStreak),
                ),
                SizedBox(height: 24),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.1,
                  child: _buildCalendar(streakDays),
                ),
                SizedBox(height: 24),
                AppAnimations.fadeSlideUp(
                  controller: _animController,
                  delay: 0.2,
                  child: _buildStreakInfo(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakStats(int currentStreak, int longestStreak) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            currentStreak.toString(),
            AppLocalizations.get('currentStreak'),
            Icons.local_fire_department_rounded,
            AppTheme.warningOrange,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            longestStreak.toString(),
            AppLocalizations.get('longestStreak'),
            Icons.emoji_events_rounded,
            AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            AppLocalizations.get('days'),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<int> streakDays) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthName(_currentMonth.month),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${streakDays.length} ${AppLocalizations.get('trainingDays')}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildWeekdayHeaders(),
          SizedBox(height: 8),
          _buildCalendarGrid(streakDays),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<int> streakDays) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    final today = DateTime.now();
    final cells = <Widget>[];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isTrainingDay = streakDays.contains(day);
      final isToday = day == today.day;
      cells.add(_buildDayCell(day, isTrainingDay, isToday));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }

  Widget _buildDayCell(int day, bool isTrainingDay, bool isToday) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isTrainingDay
            ? AppTheme.primaryBlue
            : isToday
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isToday && !isTrainingDay
            ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isTrainingDay
                ? Colors.white
                : isToday
                    ? AppTheme.primaryBlue
                    : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                AppLocalizations.get('keepTraining'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.get('streakTip'),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return months[month];
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/core/utils/animations.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';
import 'package:grip_strength_monitor/shared/models/training_session.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<TrainingSession> _getFilteredSessions(List<TrainingSession> sessions) {
    if (_selectedFilter == 'all') return sessions;
    return sessions.where((s) => s.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.get('trainingHistory')),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.separator),
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          final filteredSessions = _getFilteredSessions(historyProvider.sessions);
          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filteredSessions.isEmpty
                    ? _buildEmptyState()
                    : _buildSessionList(filteredSessions),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'ทั้งหมด'),
            SizedBox(width: 8),
            _buildFilterChip('measurement', 'วัดแรงบีบ'),
            SizedBox(width: 8),
            _buildFilterChip('grip_rhythm', 'เกมจังหวะ'),
            SizedBox(width: 8),
            _buildFilterChip('music_rhythm', 'เล่นเพลง'),
            SizedBox(width: 8),
            _buildFilterChip('guided_training', 'โปรแกรมฝึก'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.get('noHistory'),
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<TrainingSession> sessions) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return AppAnimations.fadeSlideUp(
          controller: _animController,
          delay: index * 0.05,
          child: _buildSessionCard(session),
        );
      },
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    final typeColor = _getTypeColor(session.type);
    final typeIcon = _getTypeIcon(session.type);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTypeName(session.type),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${session.dateFormatted} • ${session.durationFormatted}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.gripStrength.toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(session.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusLabel(session.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(session.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'measurement':
        return AppTheme.primaryBlue;
      case 'grip_rhythm':
        return AppTheme.primaryPink;
      case 'music_rhythm':
        return AppTheme.accentGreen;
      case 'guided_training':
        return AppTheme.warningOrange;
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'measurement':
        return Icons.fitness_center_rounded;
      case 'grip_rhythm':
        return Icons.sports_esports_rounded;
      case 'music_rhythm':
        return Icons.music_note_rounded;
      case 'guided_training':
        return Icons.school_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'measurement':
        return AppLocalizations.get('gripSession');
      case 'grip_rhythm':
        return 'เกมจังหวะ';
      case 'music_rhythm':
        return 'เล่นเพลง';
      case 'guided_training':
        return AppLocalizations.get('guidedSession');
      default:
        return '';
    }
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
        return AppTheme.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'normal':
        return AppLocalizations.get('normal');
      case 'warning':
        return AppLocalizations.get('warning');
      case 'risk':
        return AppLocalizations.get('risk');
      default:
        return '';
    }
  }
}

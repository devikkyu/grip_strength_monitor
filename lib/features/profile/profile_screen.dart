import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/features/profile/settings_screen.dart';
import 'package:grip_strength_monitor/features/streak/streak_calendar_screen.dart';
import 'package:grip_strength_monitor/features/history/training_history_screen.dart';
import 'package:grip_strength_monitor/features/report/health_report_screen.dart';
import 'package:grip_strength_monitor/features/achievements/achievements_screen.dart';
import 'package:grip_strength_monitor/services/user_profile_provider.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(profile),
              SizedBox(height: 20),
              _buildUserInfoCard(context, profile),
              SizedBox(height: 20),
              _buildFeatureLinks(context),
              SizedBox(height: 20),
              _buildSettingsButton(context),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfileProvider profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryLightPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(Icons.person_rounded, size: 44, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(profile.name, style: GoogleFonts.sarabun(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 4),
          Text('เป็นสมาชิกตั้งแต่ ${profile.memberSince}', style: GoogleFonts.sarabun(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserProfileProvider profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline_rounded, 'ชื่อ', profile.name),
          Divider(height: 1, indent: 44),
          _buildInfoRow(Icons.cake_outlined, 'อายุ', '${profile.age} ปี'),
          Divider(height: 1, indent: 44),
          _buildInfoRow(Icons.calendar_today_rounded, 'สมาชิกตั้งแต่', profile.memberSince),
          Divider(height: 1, indent: 44),
          _buildInfoRow(Icons.fitness_center_rounded, 'เซสชันทั้งหมด', '${profile.totalSessions} เซสชัน'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppTheme.primaryPink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.primaryPink, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
                SizedBox(height: 2),
                Text(value, style: GoogleFonts.sarabun(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureLinks(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ฟีเจอร์', style: GoogleFonts.sarabun(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          SizedBox(height: 12),
          _buildLinkItem(Icons.calendar_month_rounded, 'ปฏิทินความต่อเนื่อง', AppTheme.warningOrange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => StreakCalendarScreen()))),
          _buildLinkItem(Icons.history_rounded, 'ประวัติการฝึก', AppTheme.primaryPink,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainingHistoryScreen()))),
          _buildLinkItem(Icons.assessment_rounded, 'รายงานสุขภาพ', AppTheme.accentGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthReportScreen()))),
          _buildLinkItem(Icons.emoji_events_rounded, 'รางวัล', AppTheme.primaryPink,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => AchievementsScreen()))),
        ],
      ),
    );
  }

  Widget _buildLinkItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SoundService().playButton();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(child: Text(title, style: GoogleFonts.sarabun(fontSize: 15, color: AppTheme.textPrimary))),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          SoundService().playButton();
          Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.primaryPink.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppTheme.primaryPink.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.settings_rounded, color: AppTheme.primaryPink, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('ตั้งค่า', style: GoogleFonts.sarabun(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/services/theme_provider.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sound = SoundService();
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.get('settings')),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(preferredSize: Size.fromHeight(0.5), child: Container(height: 0.5, color: AppTheme.separator)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildSectionTitle(AppLocalizations.get('account')),
            _buildGroupedCard(context, [
              _buildSettingsItem(context, Icons.person_outline_rounded, AppLocalizations.get('editProfile'), AppLocalizations.get('editProfileDesc'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('editProfile'), 'แก้ไขข้อมูลโปรไฟล์ได้จากหน้าโปรไฟล์');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.lock_outline_rounded, AppLocalizations.get('changePassword'), AppLocalizations.get('changePasswordDesc'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('changePassword'), 'ฟีเจอร์นี้จะเปิดให้ใช้งานเร็วๆ นี้');
              }),
            ]),
            SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.get('notifications')),
            _buildGroupedCard(context, [
              _buildSettingsItem(context, Icons.notifications_outlined, AppLocalizations.get('notificationPrefs'), AppLocalizations.get('notificationPrefsDesc'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('notificationPrefs'), 'ฟีเจอร์นี้จะเปิดให้ใช้งานเร็วๆ นี้');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.alarm_outlined, AppLocalizations.get('trainingReminder'), AppLocalizations.get('trainingReminderDesc'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('trainingReminder'), 'ฟีเจอร์นี้จะเปิดให้ใช้งานเร็วๆ นี้');
              }),
            ]),
            SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.get('appearance')),
            _buildGroupedCard(context, [
              _buildThemeToggle(context),
              _buildDivider(),
              _buildSoundToggle(context),
            ]),
            SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.get('data')),
            _buildGroupedCard(context, [
              _buildSettingsItem(context, Icons.backup_outlined, AppLocalizations.get('backupData'), AppLocalizations.get('backupDesc'), () {
                sound.playSave();
                _showInfoDialog(context, AppLocalizations.get('backupData'), 'ข้อมูลถูกสำรองลงในอุปกรณ์แล้ว');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.restore_outlined, AppLocalizations.get('restoreData'), AppLocalizations.get('restoreDesc'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('restoreData'), 'ไม่พบข้อมูลสำรองที่ต้องกู้คืน');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.download_outlined, AppLocalizations.get('exportData'), AppLocalizations.get('exportDesc'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('exportData'), 'ฟีเจอร์ส่งออกข้อมูลจะเปิดให้ใช้งานเร็วๆ นี้');
              }),
            ]),
            SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.get('support')),
            _buildGroupedCard(context, [
              _buildSettingsItem(context, Icons.help_outline_rounded, AppLocalizations.get('helpAndSupport'), '', () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('helpAndSupport'), 'ติดต่อเราได้ที่ support@gripstrength.app');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.description_outlined, AppLocalizations.get('termsOfService'), '', () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('termsOfService'), 'เงื่อนไขการใช้งานจะเปิดให้ใช้งานเร็วๆ นี้');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.privacy_tip_outlined, AppLocalizations.get('privacyPolicy'), '', () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('privacyPolicy'), 'นโยบายความเป็นส่วนตัวจะเปิดให้ใช้งานเร็วๆ นี้');
              }),
              _buildDivider(),
              _buildSettingsItem(context, Icons.info_outline_rounded, AppLocalizations.get('about'), AppLocalizations.get('appVersion'), () {
                sound.playButton();
                _showInfoDialog(context, AppLocalizations.get('about'), 'Grip Strength Monitor v1.0.0\nแอปฝึกบีบมือสำหรับผู้สูงอายุ');
              }),
            ]),
            SizedBox(height: 24),
            _buildDangerZone(context),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
    );
  }

  Widget _buildGroupedCard(BuildContext context, List<Widget> children) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue, size: 22),
      title: Text(title, style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, letterSpacing: -0.2)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 0.5, indent: 52);
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SwitchListTile(
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppTheme.primaryBlue,
            size: 22,
          ),
          title: Text(AppLocalizations.get('darkMode'), style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, letterSpacing: -0.2)),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            SoundService().playTap();
            themeProvider.toggleTheme();
          },
          activeThumbColor: Colors.white,
          activeTrackColor: AppTheme.primaryBlue,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }

  Widget _buildSoundToggle(BuildContext context) {
    final sound = SoundService();
    return SwitchListTile(
      secondary: Icon(
        sound.enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        color: AppTheme.primaryBlue,
        size: 22,
      ),
      title: Text('เสียงและระบบสั่น', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, letterSpacing: -0.2)),
      subtitle: Text(sound.enabled ? 'เปิดใช้งาน' : 'ปิดใช้งาน', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      value: sound.enabled,
      onChanged: (value) {
        sound.toggle();
      },
      activeThumbColor: Colors.white,
      activeTrackColor: AppTheme.primaryBlue,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.get('deleteAccount')),
                  content: Text(AppLocalizations.get('deleteConfirm')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.get('cancel'))),
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.get('deleteAccount'), style: TextStyle(color: AppTheme.riskRed))),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete_outline_rounded, color: AppTheme.riskRed, size: 20),
            label: Text(AppLocalizations.get('deleteAccount'), style: TextStyle(color: AppTheme.riskRed)),
            style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ตกลง', style: TextStyle(color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }
}

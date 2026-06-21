import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/features/dashboard/dashboard_screen.dart';
import 'package:grip_strength_monitor/features/statistics/statistics_screen.dart';
import 'package:grip_strength_monitor/features/goals/goals_screen.dart';
import 'package:grip_strength_monitor/features/profile/profile_screen.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _sound = SoundService();

  final List<Widget> _screens = [
    DashboardScreen(),
    StatisticsScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  List<String> get _titles => [
    AppLocalizations.get('dashboard'),
    AppLocalizations.get('statistics'),
    AppLocalizations.get('goals'),
    AppLocalizations.get('profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(preferredSize: Size.fromHeight(0.5), child: Container(height: 0.5, color: AppTheme.separator)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.94),
          border: Border(top: BorderSide(color: AppTheme.separator.withValues(alpha: 0.3), width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            _sound.playNavigation();
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 24),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryBlue, size: 24),
              label: AppLocalizations.get('dashboard'),
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined, size: 24),
              selectedIcon: Icon(Icons.analytics_rounded, color: AppTheme.primaryBlue, size: 24),
              label: AppLocalizations.get('statistics'),
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined, size: 24),
              selectedIcon: Icon(Icons.flag_rounded, color: AppTheme.primaryBlue, size: 24),
              label: AppLocalizations.get('goals'),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, size: 24),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryBlue, size: 24),
              label: AppLocalizations.get('profile'),
            ),
          ],
        ),
      ),
    );
  }
}

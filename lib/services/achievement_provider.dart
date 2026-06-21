import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/achievement.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';

class AchievementProvider extends ChangeNotifier {
  final HistoryProvider _historyProvider;
  final PersistenceService _persistence = PersistenceService();
  List<Achievement> _achievements = [];

  AchievementProvider(this._historyProvider) {
    _historyProvider.addListener(_checkAchievements);
    _loadAchievements();
  }

  List<Achievement> get achievements => _achievements;
  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;

  void _loadAchievements() {
    final saved = _persistence.get('achievements', 'unlocked_ids') as List?;
    final unlockedIds = saved != null ? saved.cast<String>() : [];

    _achievements = [
      Achievement(
        id: 'first_step',
        title: 'ก้าวแรก',
        description: 'เริ่มการฝึกครั้งแรก',
        icon: Icons.star_rounded,
        isUnlocked: unlockedIds.contains('first_step'),
      ),
      Achievement(
        id: 'consistent',
        title: 'สม่ำเสมอ',
        description: 'ฝึกครบ 5 ครั้ง',
        icon: Icons.trending_up_rounded,
        isUnlocked: unlockedIds.contains('consistent'),
      ),
      Achievement(
        id: 'iron_grip',
        title: 'มือเหล็ก',
        description: 'บีบได้แรงกว่า 50 kg',
        icon: Icons.fitness_center_rounded,
        isUnlocked: unlockedIds.contains('iron_grip'),
      ),
      Achievement(
        id: 'master',
        title: 'ผู้เชี่ยวชาญ',
        description: 'ฝึกครบ 20 ครั้ง',
        icon: Icons.emoji_events_rounded,
        isUnlocked: unlockedIds.contains('master'),
      ),
    ];
    _checkAchievements();
  }

  void _checkAchievements() {
    final sessions = _historyProvider.sessions;
    if (sessions.isEmpty) return;

    bool changed = false;

    // First Step
    if (!_achievements[0].isUnlocked && sessions.length >= 1) {
      _achievements[0] = _achievements[0].copyWith(isUnlocked: true);
      changed = true;
    }

    // Consistent
    if (!_achievements[1].isUnlocked && sessions.length >= 5) {
      _achievements[1] = _achievements[1].copyWith(isUnlocked: true);
      changed = true;
    }

    // Iron Grip
    if (!_achievements[2].isUnlocked) {
      final maxGrip = sessions.map((s) => s.gripStrength).reduce((a, b) => a > b ? a : b);
      if (maxGrip >= 50.0) {
        _achievements[2] = _achievements[2].copyWith(isUnlocked: true);
        changed = true;
      }
    }

    // Master
    if (!_achievements[3].isUnlocked && sessions.length >= 20) {
      _achievements[3] = _achievements[3].copyWith(isUnlocked: true);
      changed = true;
    }

    if (changed) {
      final unlockedIds = _achievements.where((a) => a.isUnlocked).map((a) => a.id).toList();
      _persistence.save('achievements', 'unlocked_ids', unlockedIds);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _historyProvider.removeListener(_checkAchievements);
    super.dispose();
  }
}

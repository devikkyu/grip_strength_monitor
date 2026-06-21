import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';

enum TimePeriod { days7, days30, days90 }

class StatisticsProvider extends ChangeNotifier {
  TimePeriod _selectedPeriod = TimePeriod.days7;
  final HistoryProvider _historyProvider;

  StatisticsProvider(this._historyProvider) {
    _historyProvider.addListener(_handleHistoryChange);
  }

  TimePeriod get selectedPeriod => _selectedPeriod;

  void updatePeriod(TimePeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  List<GripData> get data {
    final now = DateTime.now();
    final days = _selectedPeriod == TimePeriod.days7 ? 7 : (_selectedPeriod == TimePeriod.days30 ? 30 : 90);
    final cutoff = now.subtract(Duration(days: days));

    return _historyProvider.sessions
        .where((s) => s.date.isAfter(cutoff))
        .map((s) => GripData(date: s.date, gripStrength: s.gripStrength))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double get averageGrip {
    final currentData = data;
    if (currentData.isEmpty) return 0.0;
    return currentData.fold<double>(0, (sum, item) => sum + item.gripStrength) / currentData.length;
  }

  double get maxGrip {
    final currentData = data;
    if (currentData.isEmpty) return 0.0;
    return currentData.map((e) => e.gripStrength).reduce((a, b) => a > b ? a : b);
  }

  double get trend {
    final currentData = data;
    if (currentData.length < 2) return 0.0;

    final recentCount = (currentData.length / 2).ceil();
    final recent = currentData.sublist(currentData.length - recentCount);
    final early = currentData.sublist(0, currentData.length - recentCount);

    final avgRecent = recent.fold<double>(0, (sum, item) => sum + item.gripStrength) / recent.length;
    final avgEarly = early.fold<double>(0, (sum, item) => sum + item.gripStrength) / early.length;

    if (avgEarly == 0) return 0.0;
    return ((avgRecent - avgEarly) / avgEarly) * 100;
  }

  void _handleHistoryChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    _historyProvider.removeListener(_handleHistoryChange);
    super.dispose();
  }
}

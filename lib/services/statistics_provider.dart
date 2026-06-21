import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';

enum TimePeriod { days7, days30, days90 }

class StatisticsProvider extends ChangeNotifier {
  TimePeriod _selectedPeriod = TimePeriod.days7;
  final HistoryProvider _historyProvider;
  List<GripData>? _cachedData;

  StatisticsProvider(this._historyProvider) {
    _historyProvider.addListener(_handleHistoryChange);
  }

  TimePeriod get selectedPeriod => _selectedPeriod;

  void updatePeriod(TimePeriod period) {
    _selectedPeriod = period;
    _cachedData = null;
    notifyListeners();
  }

  List<GripData> get data {
    if (_cachedData != null) return _cachedData!;
    
    final now = DateTime.now();
    final days = _selectedPeriod == TimePeriod.days7 ? 7 : (_selectedPeriod == TimePeriod.days30 ? 30 : 90);
    final cutoff = now.subtract(Duration(days: days));

    _cachedData = _historyProvider.sessions
        .where((s) => s.date.isAfter(cutoff))
        .map((s) => GripData(date: s.date, gripStrength: s.gripStrength))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return _cachedData!;
  }

  double get averageGrip {
    final currentData = data;
    if (currentData.isEmpty) return 0.0;
    double sum = 0;
    for (final item in currentData) {
      sum += item.gripStrength;
    }
    return sum / currentData.length;
  }

  double get maxGrip {
    final currentData = data;
    if (currentData.isEmpty) return 0.0;
    double max = currentData[0].gripStrength;
    for (int i = 1; i < currentData.length; i++) {
      if (currentData[i].gripStrength > max) max = currentData[i].gripStrength;
    }
    return max;
  }

  double get trend {
    final currentData = data;
    if (currentData.length < 2) return 0.0;

    final recentCount = (currentData.length / 2).ceil();
    final recent = currentData.sublist(currentData.length - recentCount);
    final early = currentData.sublist(0, currentData.length - recentCount);

    double sumRecent = 0;
    for (final item in recent) {
      sumRecent += item.gripStrength;
    }
    final avgRecent = sumRecent / recent.length;

    double sumEarly = 0;
    for (final item in early) {
      sumEarly += item.gripStrength;
    }
    final avgEarly = sumEarly / early.length;

    if (avgEarly == 0) return 0.0;
    return ((avgRecent - avgEarly) / avgEarly) * 100;
  }

  void _handleHistoryChange() {
    _cachedData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _historyProvider.removeListener(_handleHistoryChange);
    super.dispose();
  }
}

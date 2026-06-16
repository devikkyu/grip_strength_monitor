import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/services/mock_data_service.dart';

enum TimePeriod { days7, days30, days90 }

class StatisticsProvider extends ChangeNotifier {
  TimePeriod _selectedPeriod = TimePeriod.days7;
  List<GripData> _data = MockDataService.getWeeklyData();

  TimePeriod get selectedPeriod => _selectedPeriod;
  List<GripData> get data => _data;

  void updatePeriod(TimePeriod period) {
    _selectedPeriod = period;
    switch (period) {
      case TimePeriod.days7:
        _data = MockDataService.getWeeklyData();
        break;
      case TimePeriod.days30:
        _data = MockDataService.getMonthlyData();
        break;
      case TimePeriod.days90:
        _data = MockDataService.get90DayData();
        break;
    }
    notifyListeners();
  }

  double get averageGrip => MockDataService.getAverageGrip(_data);
  double get maxGrip => MockDataService.getMaxGrip(_data);
  double get trend => MockDataService.getTrend(_data);
}

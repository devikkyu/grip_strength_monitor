import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/services/mock_data_service.dart';

class GripProvider extends ChangeNotifier {
  GripData _currentGrip = MockDataService.getCurrentGripData();
  double _maxGripToday = MockDataService.getMaxGripToday();
  int _brainScore = MockDataService.getBrainScore();
  GripStatus _status = MockDataService.getStatus(MockDataService.getCurrentGripData().gripStrength);

  GripData get currentGrip => _currentGrip;
  double get maxGripToday => _maxGripToday;
  int get brainScore => _brainScore;
  GripStatus get status => _status;

  void updateGrip(double newGrip) {
    _currentGrip = GripData(
      date: DateTime.now(),
      gripStrength: newGrip,
    );
    _status = MockDataService.getStatus(newGrip);
    if (newGrip > _maxGripToday) {
      _maxGripToday = newGrip;
    }
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';
import 'package:grip_strength_monitor/services/websocket_service.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';

class GripProvider extends ChangeNotifier {
  GripData _currentGrip = GripData(date: DateTime.now(), gripStrength: 0.0);
  double _maxGripToday = 0.0;
  int _brainScore = 0;
  GripStatus _status = GripStatus.normal;
  final PersistenceService _persistence = PersistenceService();
  StreamSubscription? _wsSubscription;

  GripProvider(WebSocketService wsService, ConnectionProvider connProvider) {
    _loadState();
    _subscribeToGripStream(wsService);
    connProvider.addListener(_handleConnectionChange);
    _connProvider = connProvider;
  }

  late final ConnectionProvider _connProvider;

  double get currentGrip => _currentGrip.gripStrength;
  double get maxGripToday => _maxGripToday;
  int get brainScore => _brainScore;
  GripStatus get status => _status;

  void _handleConnectionChange() {
    if (_connProvider.status == ConnectionStatus.disconnected ||
        _connProvider.status == ConnectionStatus.error) {
      resetValues();
    }
  }

  void resetValues() {
    _currentGrip = GripData(date: DateTime.now(), gripStrength: 0.0);
    _maxGripToday = 0.0;
    _status = GripStatus.normal;
    notifyListeners();
  }

  void _subscribeToGripStream(WebSocketService wsService) {
    _wsSubscription?.cancel();
    _wsSubscription = wsService.gripStream.listen(
      (value) => updateGrip(value),
      onError: (_) {},
    );
  }

  void _loadState() {
    final savedMax = _persistence.get('statistics', 'max_grip_today');
    if (savedMax != null) _maxGripToday = savedMax.toDouble();

    final savedScore = _persistence.get('statistics', 'brain_score');
    if (savedScore != null) _brainScore = savedScore;
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _connProvider.removeListener(_handleConnectionChange);
    super.dispose();
  }

  void updateGrip(double newGrip) {
    _currentGrip = GripData(
      date: DateTime.now(),
      gripStrength: newGrip,
    );

    _status = _calculateStatus(newGrip);

    if (newGrip > _maxGripToday) {
      _maxGripToday = newGrip;
      _persistence.save('statistics', 'max_grip_today', _maxGripToday);
    }
    notifyListeners();
  }

  void updateBrainScore(int score) {
    _brainScore = score;
    _persistence.save('statistics', 'brain_score', _brainScore);
    notifyListeners();
  }

  GripStatus _calculateStatus(double grip) {
    if (grip > 80) return GripStatus.risk;
    if (grip > 50) return GripStatus.warning;
    return GripStatus.normal;
  }
}

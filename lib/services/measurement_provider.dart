import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MeasurementState {
  final bool isMeasuring;
  final bool isCompleted;
  final double currentGrip;
  final double maxGrip;
  final double minGrip;
  final double avgGrip;
  final int elapsedSeconds;
  final int roundCount;
  final List<double> gripHistory;

  MeasurementState({
    this.isMeasuring = false,
    this.isCompleted = false,
    this.currentGrip = 0,
    this.maxGrip = 0,
    this.minGrip = 0,
    this.avgGrip = 0,
    this.elapsedSeconds = 0,
    this.roundCount = 0,
    this.gripHistory = const [],
  });

  MeasurementState copyWith({
    bool? isMeasuring,
    bool? isCompleted,
    double? currentGrip,
    double? maxGrip,
    double? minGrip,
    double? avgGrip,
    int? elapsedSeconds,
    int? roundCount,
    List<double>? gripHistory,
  }) {
    return MeasurementState(
      isMeasuring: isMeasuring ?? this.isMeasuring,
      isCompleted: isCompleted ?? this.isCompleted,
      currentGrip: currentGrip ?? this.currentGrip,
      maxGrip: maxGrip ?? this.maxGrip,
      minGrip: minGrip ?? this.minGrip,
      avgGrip: avgGrip ?? this.avgGrip,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      roundCount: roundCount ?? this.roundCount,
      gripHistory: gripHistory ?? this.gripHistory,
    );
  }
}

class MeasurementProvider extends ChangeNotifier {
  MeasurementState _state = MeasurementState();
  Timer? _timer;
  final Random _random = Random();

  MeasurementState get state => _state;

  void startMeasurement() {
    _state = MeasurementState(
      isMeasuring: true,
      isCompleted: false,
      gripHistory: [],
    );
    _startTimer();
    _startGripSimulation();
    notifyListeners();
  }

  void stopMeasurement() {
    _timer?.cancel();
    final avg = _state.gripHistory.isNotEmpty
        ? _state.gripHistory.reduce((a, b) => a + b) / _state.gripHistory.length
        : 0.0;
    _state = _state.copyWith(
      isMeasuring: false,
      isCompleted: true,
      avgGrip: avg,
    );
    notifyListeners();
  }

  void resetMeasurement() {
    _timer?.cancel();
    _state = MeasurementState();
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_state.isMeasuring) {
        timer.cancel();
        return;
      }
      _state = _state.copyWith(elapsedSeconds: _state.elapsedSeconds + 1);
      notifyListeners();
    });
  }

  void _startGripSimulation() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_state.isMeasuring) {
        timer.cancel();
        return;
      }
      final baseGrip = 40.0;
      final variation = _random.nextDouble() * 15 - 5;
      final newGrip = baseGrip + variation;

      final history = List<double>.from(_state.gripHistory)..add(newGrip);
      final maxVal = history.reduce(max);
      final minVal = history.reduce(min);

      _state = _state.copyWith(
        currentGrip: newGrip,
        maxGrip: maxVal,
        minGrip: minVal,
        gripHistory: history,
      );
      notifyListeners();
    });
  }

  void incrementRound() {
    _state = _state.copyWith(roundCount: _state.roundCount + 1);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

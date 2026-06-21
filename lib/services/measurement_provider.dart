import 'package:flutter/material.dart';
import 'dart:async';
import 'package:grip_strength_monitor/services/websocket_service.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';
import 'package:grip_strength_monitor/shared/models/training_session.dart';

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
  final WebSocketService _wsService;
  final HistoryProvider _historyProvider;
  StreamSubscription? _wsSubscription;
  static const int _maxHistory = 200;

  MeasurementProvider(this._wsService, this._historyProvider);

  MeasurementState get state => _state;

  void startMeasurement() {
    _state = MeasurementState(
      isMeasuring: true,
      isCompleted: false,
      gripHistory: [],
    );
    _startTimer();
    _subscribeToGripStream();
    notifyListeners();
  }

  void _subscribeToGripStream() {
    _wsSubscription?.cancel();
    _wsSubscription = _wsService.gripStream.listen(
      (value) {
        final history = _state.gripHistory;
        final newHistory = history.length >= _maxHistory
            ? [...history.sublist(1), value]
            : [...history, value];

        final maxVal = value > _state.maxGrip ? value : _state.maxGrip;
        final minVal = (_state.gripHistory.isEmpty || value < _state.minGrip) ? value : _state.minGrip;

        _state = _state.copyWith(
          currentGrip: value,
          maxGrip: maxVal,
          minGrip: minVal,
          gripHistory: newHistory,
        );
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void stopMeasurement() {
    _timer?.cancel();
    _wsSubscription?.cancel();
    final avg = _state.gripHistory.isNotEmpty
        ? _state.gripHistory.reduce((a, b) => a + b) / _state.gripHistory.length
        : 0.0;
    _state = _state.copyWith(
      isMeasuring: false,
      isCompleted: true,
      avgGrip: avg,
    );

    if (_state.gripHistory.isNotEmpty) {
      _historyProvider.addSession(TrainingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        type: 'measurement',
        gripStrength: avg,
        maxGrip: _state.maxGrip,
        minGrip: _state.minGrip,
        durationSeconds: _state.elapsedSeconds,
        roundCount: _state.roundCount,
        status: 'completed',
      ));
    }

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

  void incrementRound() {
    _state = _state.copyWith(roundCount: _state.roundCount + 1);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wsSubscription?.cancel();
    super.dispose();
  }
}

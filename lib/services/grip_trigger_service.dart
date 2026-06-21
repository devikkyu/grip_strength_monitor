import 'dart:async';

class GripTriggerService {
  static final GripTriggerService _instance = GripTriggerService._();
  factory GripTriggerService() => _instance;
  GripTriggerService._();

  static const double threshold = 2.0;
  static const Duration debounceDuration = Duration(milliseconds: 200);

  double _previousGrip = 0.0;
  bool _armed = true;
  DateTime? _lastHitTime;
  final StreamController<void> _hitController = StreamController<void>.broadcast();
  Stream<void> get onHit => _hitController.stream;

  double get previousGrip => _previousGrip;
  bool get isArmed => _armed;

  void processGrip(double currentGrip) {
    final now = DateTime.now();
    
    if (_previousGrip <= threshold && currentGrip > threshold && _armed) {
      if (_lastHitTime == null || now.difference(_lastHitTime!) >= debounceDuration) {
        _armed = false;
        _lastHitTime = now;
        _hitController.add(null);
      }
    } else if (currentGrip < threshold) {
      _armed = true;
    }
    _previousGrip = currentGrip;
  }

  void reset() {
    _previousGrip = 0.0;
    _armed = true;
    _lastHitTime = null;
  }

  void dispose() {
    _hitController.close();
  }
}

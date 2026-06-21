import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/training_session.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<TrainingSession> _sessions = [];
  final PersistenceService _persistence = PersistenceService();

  HistoryProvider() {
    _loadHistory();
  }

  List<TrainingSession> get sessions => List.unmodifiable(_sessions);

  void _loadHistory() {
    final savedSessions = _persistence.get('training_history', 'sessions') as List?;
    if (savedSessions != null) {
      _sessions = savedSessions.map((s) => TrainingSession.fromJson(Map<String, dynamic>.from(s))).toList();
    }
  }

  void addSession(TrainingSession session) {
    _sessions.insert(0, session);
    _saveHistory();
    notifyListeners();
  }

  void _saveHistory() {
    _persistence.save('training_history', 'sessions', _sessions.map((s) => s.toJson()).toList());
  }

  void clearHistory() {
    _sessions = [];
    _saveHistory();
    notifyListeners();
  }
}

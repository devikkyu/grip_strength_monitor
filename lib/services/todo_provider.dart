import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/todo.dart';
import 'package:grip_strength_monitor/services/mock_data_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = MockDataService.getDailyTasks();
  int _expProgress = MockDataService.getExpProgress();
  int _expRequired = MockDataService.getExpRequired();
  int _level = MockDataService.getLevel();
  int _completedRounds = MockDataService.getCompletedRounds();
  int _todayProgress = MockDataService.getTodayProgress();

  List<Todo> get todos => List.unmodifiable(_todos);
  int get expProgress => _expProgress;
  int get expRequired => _expRequired;
  int get level => _level;
  int get completedRounds => _completedRounds;
  int get todayProgress => _todayProgress;

  void toggleTodo(String id) {
    final todoIndex = _todos.indexWhere((t) => t.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      _updateProgress();
      notifyListeners();
    }
  }

  void completeTodo(String id) {
    final todoIndex = _todos.indexWhere((t) => t.id == id);
    if (todoIndex != -1 && !_todos[todoIndex].isCompleted) {
      _todos[todoIndex].isCompleted = true;
      _updateProgress();
      notifyListeners();
    }
  }

  void onGripExercise() {
    completeTodo('1');
    _completedRounds++;
    _addExp(25);
  }

  void onAudioRhythm() {
    completeTodo('2');
    _addExp(30);
  }

  void onConsecutiveTraining() {
    completeTodo('3');
    _addExp(50);
  }

  void onMeasurementCompleted() {
    _completedRounds++;
    _addExp(20);
  }

  void onGameCompleted(int score) {
    _addExp((score / 10).round().clamp(10, 100));
  }

  void _addExp(int amount) {
    _expProgress += amount;
    if (_expProgress >= _expRequired) {
      _level++;
      _expProgress = 0;
      _expRequired = (_expRequired * 1.5).round();
    }
    notifyListeners();
  }

  void _updateProgress() {
    final completedCount = _todos.where((t) => t.isCompleted).length;
    _todayProgress = (completedCount / _todos.length * 100).round();
  }
}

import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/shared/models/todo.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [
    Todo(id: '1', title: 'ทำแบบฝึกหัดกริบ'),
    Todo(id: '2', title: 'ฝึกตามจังหวะเสียง'),
    Todo(id: '3', title: 'ฝึกอย่างต่อเนื่อง'),
  ];
  int _expProgress = 0;
  int _expRequired = 100;
  int _level = 1;
  int _completedRounds = 0;
  int _todayProgress = 0;
  final PersistenceService _persistence = PersistenceService();

  TodoProvider() {
    _loadState();
  }

  List<Todo> get todos => List.unmodifiable(_todos);
  int get expProgress => _expProgress;
  int get expRequired => _expRequired;
  int get level => _level;
  int get completedRounds => _completedRounds;
  int get todayProgress => _todayProgress;

  void _loadState() {
    final savedLevel = _persistence.get('todo_progress', 'level');
    if (savedLevel != null) _level = savedLevel;

    final savedExp = _persistence.get('todo_progress', 'exp_progress');
    if (savedExp != null) _expProgress = savedExp;

    final savedReq = _persistence.get('todo_progress', 'exp_required');
    if (savedReq != null) _expRequired = savedReq;

    final savedRounds = _persistence.get('todo_progress', 'completed_rounds');
    if (savedRounds != null) _completedRounds = savedRounds;

    final savedTodos = _persistence.get('todo_progress', 'todos') as List?;
    if (savedTodos != null) {
      _todos = savedTodos.map((t) => Todo.fromJson(Map<String, dynamic>.from(t))).toList();
    }
    _updateProgress();
  }

  void _saveState() {
    _persistence.save('todo_progress', 'level', _level);
    _persistence.save('todo_progress', 'exp_progress', _expProgress);
    _persistence.save('todo_progress', 'exp_required', _expRequired);
    _persistence.save('todo_progress', 'completed_rounds', _completedRounds);
    _persistence.save('todo_progress', 'todos', _todos.map((t) => t.toJson()).toList());
    _persistence.save('todo_progress', 'today_progress', _todayProgress);
  }

  void toggleTodo(String id) {
    final todoIndex = _todos.indexWhere((t) => t.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      _updateProgress();
      _saveState();
      notifyListeners();
    }
  }

  void completeTodo(String id) {
    final todoIndex = _todos.indexWhere((t) => t.id == id);
    if (todoIndex != -1 && !_todos[todoIndex].isCompleted) {
      _todos[todoIndex].isCompleted = true;
      _updateProgress();
      _saveState();
      notifyListeners();
    }
  }

  void onGripExercise() {
    completeTodo('1');
    _completedRounds++;
    _addExp(25);
    _saveState();
  }

  void onAudioRhythm() {
    completeTodo('2');
    _addExp(30);
    _saveState();
  }

  void onConsecutiveTraining() {
    completeTodo('3');
    _addExp(50);
    _saveState();
  }

  void onMeasurementCompleted() {
    _completedRounds++;
    _addExp(20);
    _saveState();
  }

  void onGameCompleted(int score) {
    _addExp((score / 10).round().clamp(10, 100));
    _saveState();
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
    _todayProgress = (_todos.isEmpty) ? 0 : (completedCount / _todos.length * 100).round();
  }
}

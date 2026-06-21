import 'package:hive_flutter/hive_flutter.dart';

class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();

  factory PersistenceService() {
    return _instance;
  }

  PersistenceService._internal();

  Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox('user_profile');
    await Hive.openBox('settings');
    await Hive.openBox('training_history');
    await Hive.openBox('achievements');
    await Hive.openBox('statistics');
    await Hive.openBox('todo_progress');
    await Hive.openBox('devices');
  }

  Box get userBox => Hive.box('user_profile');
  Box get settingsBox => Hive.box('settings');
  Box get historyBox => Hive.box('training_history');
  Box get achievementsBox => Hive.box('achievements');
  Box get statsBox => Hive.box('statistics');
  Box get todoBox => Hive.box('todo_progress');
  Box get devicesBox => Hive.box('devices');

  void save(String boxName, String key, dynamic value) {
    Hive.box(boxName).put(key, value);
  }

  dynamic get(String boxName, String key) {
    return Hive.box(boxName).get(key);
  }

  void remove(String boxName, String key) {
    Hive.box(boxName).delete(key);
  }
}

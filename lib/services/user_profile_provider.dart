import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class UserProfileProvider extends ChangeNotifier {
  String _name = 'สมชาย ใจดี';
  int _age = 72;
  String _memberSince = 'มกราคม 2024';
  int _totalSessions = 156;
  final PersistenceService _persistence = PersistenceService();

  UserProfileProvider() {
    _loadProfile();
  }

  String get name => _name;
  int get age => _age;
  String get memberSince => _memberSince;
  int get totalSessions => _totalSessions;

  void _loadProfile() {
    final savedName = _persistence.get('user_profile', 'name');
    if (savedName != null) _name = savedName;

    final savedAge = _persistence.get('user_profile', 'age');
    if (savedAge != null) _age = savedAge;

    final savedMemberSince = _persistence.get('user_profile', 'member_since');
    if (savedMemberSince != null) _memberSince = savedMemberSince;

    final savedSessions = _persistence.get('user_profile', 'total_sessions');
    if (savedSessions != null) _totalSessions = savedSessions;
  }

  void updateName(String newName) {
    _name = newName;
    _persistence.save('user_profile', 'name', _name);
    notifyListeners();
  }

  void updateAge(int newAge) {
    _age = newAge;
    _persistence.save('user_profile', 'age', _age);
    notifyListeners();
  }

  void updateMemberSince(String date) {
    _memberSince = date;
    _persistence.save('user_profile', 'member_since', _memberSince);
    notifyListeners();
  }

  void incrementSessions() {
    _totalSessions++;
    _persistence.save('user_profile', 'total_sessions', _totalSessions);
    notifyListeners();
  }
}

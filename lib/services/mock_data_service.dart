import 'package:grip_strength_monitor/shared/models/grip_data.dart';
import 'package:grip_strength_monitor/shared/models/todo.dart';
import 'package:grip_strength_monitor/shared/models/training_session.dart';
import 'package:grip_strength_monitor/shared/models/achievement.dart';

class MockDataService {
  static GripData getCurrentGripData() {
    return GripData(
      date: DateTime.now(),
      gripStrength: 42,
      sessionCount: 3,
    );
  }

  static double getMaxGripToday() => 51;
  static int getBrainScore() => 82;

  static GripStatus getStatus(double grip) {
    if (grip >= 40) return GripStatus.normal;
    if (grip >= 25) return GripStatus.warning;
    return GripStatus.risk;
  }

  static List<GripData> getWeeklyData() {
    return List.generate(7, (index) {
      return GripData(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        gripStrength: 35 + (index * 2).toDouble(),
      );
    });
  }

  static List<GripData> getMonthlyData() {
    return List.generate(30, (index) {
      return GripData(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        gripStrength: 30 + (index % 10) * 2,
      );
    });
  }

  static List<GripData> get90DayData() {
    return List.generate(90, (index) {
      return GripData(
        date: DateTime.now().subtract(Duration(days: 89 - index)),
        gripStrength: 28 + (index % 15) * 1.5,
      );
    });
  }

  static double getAverageGrip(List<GripData> data) {
    if (data.isEmpty) return 0;
    final sum = data.fold<double>(0, (sum, item) => sum + item.gripStrength);
    return sum / data.length;
  }

  static double getMaxGrip(List<GripData> data) {
    if (data.isEmpty) return 0;
    return data.map((e) => e.gripStrength).reduce((a, b) => a > b ? a : b);
  }

  static double getTrend(List<GripData> data) {
    if (data.length < 2) return 0;
    final lastFive = data.length > 5 ? data.sublist(data.length - 5) : data;
    final firstFive = data.length > 5 ? data.sublist(0, 5) : data;

    final avgRecent = lastFive.fold<double>(0, (sum, item) => sum + item.gripStrength) / lastFive.length;
    final avgFirst = firstFive.fold<double>(0, (sum, item) => sum + item.gripStrength) / firstFive.length;

    if (avgFirst == 0) return 0;
    return ((avgRecent - avgFirst) / avgFirst) * 100;
  }

  static List<Todo> getDailyTasks() {
    return [
      Todo(id: '1', title: 'Grip Exercise 3 Times', isCompleted: true),
      Todo(id: '2', title: 'Audio Rhythm Training', isCompleted: false),
      Todo(id: '3', title: 'Consecutive Training', isCompleted: false),
    ];
  }

  static int getExpProgress() => 750;
  static int getExpRequired() => 1000;
  static int getLevel() => 2;
  static int getCompletedRounds() => 5;
  static int getTodayProgress() => 75;

  static List<TrainingSession> getTrainingHistory() {
    return [
      TrainingSession(
        id: '1',
        date: DateTime.now().subtract(Duration(days: 0, hours: 2)),
        type: 'grip',
        gripStrength: 42.5,
        maxGrip: 51.0,
        minGrip: 35.0,
        durationSeconds: 180,
        roundCount: 5,
        status: 'normal',
      ),
      TrainingSession(
        id: '2',
        date: DateTime.now().subtract(Duration(days: 1, hours: 3)),
        type: 'rhythm',
        gripStrength: 40.0,
        maxGrip: 48.0,
        minGrip: 32.0,
        durationSeconds: 240,
        roundCount: 8,
        status: 'normal',
      ),
      TrainingSession(
        id: '3',
        date: DateTime.now().subtract(Duration(days: 2, hours: 1)),
        type: 'grip',
        gripStrength: 38.5,
        maxGrip: 45.0,
        minGrip: 30.0,
        durationSeconds: 150,
        roundCount: 4,
        status: 'warning',
      ),
      TrainingSession(
        id: '4',
        date: DateTime.now().subtract(Duration(days: 3, hours: 5)),
        type: 'guided',
        gripStrength: 41.0,
        maxGrip: 49.0,
        minGrip: 33.0,
        durationSeconds: 300,
        roundCount: 6,
        status: 'normal',
      ),
      TrainingSession(
        id: '5',
        date: DateTime.now().subtract(Duration(days: 5, hours: 2)),
        type: 'rhythm',
        gripStrength: 37.0,
        maxGrip: 44.0,
        minGrip: 28.0,
        durationSeconds: 200,
        roundCount: 7,
        status: 'warning',
      ),
    ];
  }

  static List<int> getStreakDays() {
    final now = DateTime.now();
    return [
      now.subtract(Duration(days: 0)).day,
      now.subtract(Duration(days: 1)).day,
      now.subtract(Duration(days: 2)).day,
      now.subtract(Duration(days: 4)).day,
      now.subtract(Duration(days: 5)).day,
      now.subtract(Duration(days: 6)).day,
    ];
  }

  static int getCurrentStreak() => 3;
  static int getLongestStreak() => 7;

  static List<Achievement> getAchievements() {
    return [
      Achievement(
        id: '1',
        title: 'First Step',
        description: 'Complete your first measurement',
        icon: '🎯',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 10)),
        requirement: 1,
        currentProgress: 1,
      ),
      Achievement(
        id: '2',
        title: 'Week Warrior',
        description: 'Train 7 days in a row',
        icon: '🔥',
        isUnlocked: false,
        requirement: 7,
        currentProgress: 3,
      ),
      Achievement(
        id: '3',
        title: 'Strong Hand',
        description: 'Reach 50kg grip strength',
        icon: '💪',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 5)),
        requirement: 50,
        currentProgress: 51,
      ),
      Achievement(
        id: '4',
        title: 'Century Club',
        description: 'Complete 100 training sessions',
        icon: '🏆',
        isUnlocked: false,
        requirement: 100,
        currentProgress: 45,
      ),
      Achievement(
        id: '5',
        title: 'Early Bird',
        description: 'Train before 7 AM',
        icon: '🌅',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 3)),
        requirement: 1,
        currentProgress: 1,
      ),
      Achievement(
        id: '6',
        title: 'Rhythm Master',
        description: 'Complete 50 rhythm sessions',
        icon: '🎵',
        isUnlocked: false,
        requirement: 50,
        currentProgress: 20,
      ),
    ];
  }
}

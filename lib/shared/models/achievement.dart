import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requirement;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    this.requirement = 1,
    this.currentProgress = 0,
  });

  Achievement copyWith({
    bool? isUnlocked,
    int? currentProgress,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requirement: requirement,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: Icons.star_rounded,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      requirement: json['requirement'] ?? 1,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'requirement': requirement,
      'currentProgress': currentProgress,
    };
  }

  double get progress => requirement > 0 ? currentProgress / requirement : 0.0;
}

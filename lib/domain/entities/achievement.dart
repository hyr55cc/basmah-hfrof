import 'package:equatable/equatable.dart';

/// Achievement types
enum AchievementType {
  levels,
  words,
  coins,
  bonus,
  speed,
  daily,
  perfect,
  social,
  special,
}

extension AchievementTypeX on AchievementType {
  String get arabicName {
    switch (this) {
      case AchievementType.levels:
        return 'مستويات';
      case AchievementType.words:
        return 'كلمات';
      case AchievementType.coins:
        return 'عملات';
      case AchievementType.bonus:
        return 'كلمات إضافية';
      case AchievementType.speed:
        return 'سرعة';
      case AchievementType.daily:
        return 'يومي';
      case AchievementType.perfect:
        return 'إتقان';
      case AchievementType.social:
        return 'اجتماعي';
      case AchievementType.special:
        return 'خاص';
    }
  }
}

/// Achievement definition
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.rewardCoins,
    this.icon,
    this.color,
  });

  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int target;
  final int rewardCoins;
  final String? icon;
  final int? color;

  @override
  List<Object?> get props =>
      [id, title, description, type, target, rewardCoins];
}

/// User's progress on an achievement
class AchievementProgress extends Equatable {
  const AchievementProgress({
    required this.achievement,
    required this.current,
    this.completed = false,
    this.completedAt,
    this.claimed = false,
  });

  final Achievement achievement;
  final int current;
  final bool completed;
  final DateTime? completedAt;
  final bool claimed;

  double get progressPercent =>
      (current / achievement.target).clamp(0, 1).toDouble();

  AchievementProgress copyWith({
    Achievement? achievement,
    int? current,
    bool? completed,
    DateTime? completedAt,
    bool? claimed,
  }) {
    return AchievementProgress(
      achievement: achievement ?? this.achievement,
      current: current ?? this.current,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      claimed: claimed ?? this.claimed,
    );
  }

  @override
  List<Object?> get props =>
      [achievement, current, completed, completedAt, claimed];
}

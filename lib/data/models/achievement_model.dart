import '../../domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.target,
    required super.rewardCoins,
    super.icon,
    super.color,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: _parseType(map['type'] as String?),
      target: map['target'] as int? ?? 1,
      rewardCoins: map['rewardCoins'] as int? ?? 0,
      icon: map['icon'] as String?,
      color: map['color'] as int?,
    );
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel.fromMap(json);

  factory AchievementModel.fromEntity(Achievement achievement) {
    return AchievementModel(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      type: achievement.type,
      target: achievement.target,
      rewardCoins: achievement.rewardCoins,
      icon: achievement.icon,
      color: achievement.color,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'target': target,
        'rewardCoins': rewardCoins,
        'icon': icon,
        'color': color,
      };

  Map<String, dynamic> toJson() => toMap();

  static AchievementType _parseType(String? value) {
    switch (value) {
      case 'levels':
        return AchievementType.levels;
      case 'words':
        return AchievementType.words;
      case 'coins':
        return AchievementType.coins;
      case 'bonus':
        return AchievementType.bonus;
      case 'speed':
        return AchievementType.speed;
      case 'daily':
        return AchievementType.daily;
      case 'perfect':
        return AchievementType.perfect;
      case 'social':
        return AchievementType.social;
      default:
        return AchievementType.special;
    }
  }
}

class AchievementProgressModel extends AchievementProgress {
  const AchievementProgressModel({
    required super.achievement,
    required super.current,
    super.completed = false,
    super.completedAt,
    super.claimed = false,
  });

  factory AchievementProgressModel.fromMap(
    Map<String, dynamic> map,
    Achievement achievement,
  ) {
    return AchievementProgressModel(
      achievement: achievement,
      current: map['current'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      completedAt: _parseDate(map['completedAt']),
      claimed: map['claimed'] as bool? ?? false,
    );
  }

  factory AchievementProgressModel.fromEntity(
    AchievementProgress progress,
  ) {
    return AchievementProgressModel(
      achievement: progress.achievement,
      current: progress.current,
      completed: progress.completed,
      completedAt: progress.completedAt,
      claimed: progress.claimed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievement.id,
      'current': current,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'claimed': claimed,
    };
  }

  @override
  AchievementProgressModel copyWith({
    Achievement? achievement,
    int? current,
    bool? completed,
    DateTime? completedAt,
    bool? claimed,
  }) {
    return AchievementProgressModel(
      achievement: achievement ?? this.achievement,
      current: current ?? this.current,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      claimed: claimed ?? this.claimed,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

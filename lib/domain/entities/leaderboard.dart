import 'package:equatable/equatable.dart';

/// Leaderboard entry
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.rank,
    this.photoUrl,
    this.country,
    this.avatar,
    this.isCurrentUser = false,
    this.metadata = const <String, dynamic>{},
  });

  final String userId;
  final String displayName;
  final int score;
  final int rank;
  final String? photoUrl;
  final String? country;
  final String? avatar;
  final bool isCurrentUser;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        userId,
        displayName,
        score,
        rank,
        photoUrl,
        country,
        avatar,
        isCurrentUser,
        metadata,
      ];
}

/// Leaderboard type
enum LeaderboardType {
  highestLevel,
  mostCoins,
  mostBonusWords,
  fastestPlayers,
  mostWordsFound,
  mostAchievements,
}

extension LeaderboardTypeX on LeaderboardType {
  String get arabicName {
    switch (this) {
      case LeaderboardType.highestLevel:
        return 'أعلى مستوى';
      case LeaderboardType.mostCoins:
        return 'أكثر العملات';
      case LeaderboardType.mostBonusWords:
        return 'أكثر الكلمات الإضافية';
      case LeaderboardType.fastestPlayers:
        return 'أسرع اللاعبين';
      case LeaderboardType.mostWordsFound:
        return 'أكثر الكلمات';
      case LeaderboardType.mostAchievements:
        return 'أكثر الإنجازات';
    }
  }

  String get collectionName {
    switch (this) {
      case LeaderboardType.highestLevel:
        return 'leaderboard_levels';
      case LeaderboardType.mostCoins:
        return 'leaderboard_coins';
      case LeaderboardType.mostBonusWords:
        return 'leaderboard_bonus';
      case LeaderboardType.fastestPlayers:
        return 'leaderboard_speed';
      case LeaderboardType.mostWordsFound:
        return 'leaderboard_words';
      case LeaderboardType.mostAchievements:
        return 'leaderboard_achievements';
    }
  }
}

/// Leaderboard time period
enum LeaderboardPeriod { daily, weekly, monthly, allTime }

extension LeaderboardPeriodX on LeaderboardPeriod {
  String get arabicName {
    switch (this) {
      case LeaderboardPeriod.daily:
        return 'اليوم';
      case LeaderboardPeriod.weekly:
        return 'الأسبوع';
      case LeaderboardPeriod.monthly:
        return 'الشهر';
      case LeaderboardPeriod.allTime:
        return 'كل الأوقات';
    }
  }
}

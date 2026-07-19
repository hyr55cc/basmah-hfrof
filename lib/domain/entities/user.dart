import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.coins = 0,
    this.gems = 0,
    this.hints = 5,
    this.currentLevel = 1,
    this.maxUnlockedLevel = 1,
    this.totalScore = 0,
    this.totalWordsFound = 0,
    this.totalBonusWords = 0,
    this.achievements = const <String>[],
    this.country,
    this.avatar,
    this.dailyRewardStreak = 0,
    this.lastDailyRewardDate,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final int coins;
  final int gems;
  final int hints;
  final int currentLevel;
  final int maxUnlockedLevel;
  final int totalScore;
  final int totalWordsFound;
  final int totalBonusWords;
  final List<String> achievements;
  final String? country;
  final String? avatar;
  final int dailyRewardStreak;
  final DateTime? lastDailyRewardDate;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    int? coins,
    int? gems,
    int? hints,
    int? currentLevel,
    int? maxUnlockedLevel,
    int? totalScore,
    int? totalWordsFound,
    int? totalBonusWords,
    List<String>? achievements,
    String? country,
    String? avatar,
    int? dailyRewardStreak,
    DateTime? lastDailyRewardDate,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      hints: hints ?? this.hints,
      currentLevel: currentLevel ?? this.currentLevel,
      maxUnlockedLevel: maxUnlockedLevel ?? this.maxUnlockedLevel,
      totalScore: totalScore ?? this.totalScore,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalBonusWords: totalBonusWords ?? this.totalBonusWords,
      achievements: achievements ?? this.achievements,
      country: country ?? this.country,
      avatar: avatar ?? this.avatar,
      dailyRewardStreak: dailyRewardStreak ?? this.dailyRewardStreak,
      lastDailyRewardDate: lastDailyRewardDate ?? this.lastDailyRewardDate,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        isAnonymous,
        isPremium,
        premiumExpiryDate,
        coins,
        gems,
        hints,
        currentLevel,
        maxUnlockedLevel,
        totalScore,
        totalWordsFound,
        totalBonusWords,
        achievements,
        country,
        avatar,
        dailyRewardStreak,
        lastDailyRewardDate,
        createdAt,
        lastLoginAt,
      ];
}

/// Authentication provider
enum AuthProvider { google, apple, anonymous, email, guest }

/// Auth result
class AuthResult {
  const AuthResult({required this.user, required this.isNewUser});
  final User user;
  final bool isNewUser;
}

import '../../domain/entities/user.dart';

/// User model for Firestore serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.isAnonymous = false,
    super.isPremium = false,
    super.premiumExpiryDate,
    super.coins = 0,
    super.gems = 0,
    super.hints = 5,
    super.currentLevel = 1,
    super.maxUnlockedLevel = 1,
    super.totalScore = 0,
    super.totalWordsFound = 0,
    super.totalBonusWords = 0,
    super.achievements = const <String>[],
    super.country,
    super.avatar,
    super.dailyRewardStreak = 0,
    super.lastDailyRewardDate,
    super.createdAt,
    super.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      isPremium: map['isPremium'] as bool? ?? false,
      premiumExpiryDate: _parseDate(map['premiumExpiryDate']),
      coins: map['coins'] as int? ?? 0,
      gems: map['gems'] as int? ?? 0,
      hints: map['hints'] as int? ?? 5,
      currentLevel: map['currentLevel'] as int? ?? 1,
      maxUnlockedLevel: map['maxUnlockedLevel'] as int? ?? 1,
      totalScore: map['totalScore'] as int? ?? 0,
      totalWordsFound: map['totalWordsFound'] as int? ?? 0,
      totalBonusWords: map['totalBonusWords'] as int? ?? 0,
      achievements: List<String>.from(map['achievements'] as List? ?? []),
      country: map['country'] as String?,
      avatar: map['avatar'] as String?,
      dailyRewardStreak: map['dailyRewardStreak'] as int? ?? 0,
      lastDailyRewardDate: _parseDate(map['lastDailyRewardDate']),
      createdAt: _parseDate(map['createdAt']),
      lastLoginAt: _parseDate(map['lastLoginAt']),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isAnonymous: user.isAnonymous,
      isPremium: user.isPremium,
      premiumExpiryDate: user.premiumExpiryDate,
      coins: user.coins,
      gems: user.gems,
      hints: user.hints,
      currentLevel: user.currentLevel,
      maxUnlockedLevel: user.maxUnlockedLevel,
      totalScore: user.totalScore,
      totalWordsFound: user.totalWordsFound,
      totalBonusWords: user.totalBonusWords,
      achievements: user.achievements,
      country: user.country,
      avatar: user.avatar,
      dailyRewardStreak: user.dailyRewardStreak,
      lastDailyRewardDate: user.lastDailyRewardDate,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'coins': coins,
      'gems': gems,
      'hints': hints,
      'currentLevel': currentLevel,
      'maxUnlockedLevel': maxUnlockedLevel,
      'totalScore': totalScore,
      'totalWordsFound': totalWordsFound,
      'totalBonusWords': totalBonusWords,
      'achievements': achievements,
      'country': country,
      'avatar': avatar,
      'dailyRewardStreak': dailyRewardStreak,
      'lastDailyRewardDate': lastDailyRewardDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  UserModel copyWith({
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
    return UserModel(
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Map && value['seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['seconds'] as int) * 1000,
      );
    }
    return null;
  }
}

import '../../domain/entities/level.dart';

class LevelModel extends Level {
  const LevelModel({
    required super.id,
    required super.letters,
    required super.answers,
    super.bonusWords = const <String>[],
    super.difficulty = LevelDifficulty.easy,
    super.rewardCoins = 50,
    super.hintLetterIndices = const <int>[],
    super.maxAttempts = 0,
    super.timeLimitSeconds = 0,
    super.requiredWords = 0,
    super.createdAt,
    super.updatedAt,
  });

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      id: map['id'] as int? ?? map['level'] as int? ?? 0,
      letters: List<String>.from(map['letters'] as List? ?? []),
      answers: List<String>.from(map['answers'] as List? ?? []),
      bonusWords: List<String>.from(map['bonusWords'] as List? ?? []),
      difficulty: _parseDifficulty(map['difficulty'] as String?),
      rewardCoins: map['rewardCoins'] as int? ?? 50,
      hintLetterIndices:
          List<int>.from(map['hintLetterIndices'] as List? ?? []),
      maxAttempts: map['maxAttempts'] as int? ?? 0,
      timeLimitSeconds: map['timeLimitSeconds'] as int? ?? 0,
      requiredWords: map['requiredWords'] as int? ?? 0,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      LevelModel.fromMap(json);

  factory LevelModel.fromEntity(Level level) {
    return LevelModel(
      id: level.id,
      letters: level.letters,
      answers: level.answers,
      bonusWords: level.bonusWords,
      difficulty: level.difficulty,
      rewardCoins: level.rewardCoins,
      hintLetterIndices: level.hintLetterIndices,
      maxAttempts: level.maxAttempts,
      timeLimitSeconds: level.timeLimitSeconds,
      requiredWords: level.requiredWords,
      createdAt: level.createdAt,
      updatedAt: level.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': id, // alias for compatibility
      'letters': letters,
      'answers': answers,
      'bonusWords': bonusWords,
      'difficulty': difficulty.name,
      'rewardCoins': rewardCoins,
      'hintLetterIndices': hintLetterIndices,
      'maxAttempts': maxAttempts,
      'timeLimitSeconds': timeLimitSeconds,
      'requiredWords': requiredWords,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  LevelModel copyWith({
    int? id,
    List<String>? letters,
    List<String>? answers,
    List<String>? bonusWords,
    LevelDifficulty? difficulty,
    int? rewardCoins,
    List<int>? hintLetterIndices,
    int? maxAttempts,
    int? timeLimitSeconds,
    int? requiredWords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LevelModel(
      id: id ?? this.id,
      letters: letters ?? this.letters,
      answers: answers ?? this.answers,
      bonusWords: bonusWords ?? this.bonusWords,
      difficulty: difficulty ?? this.difficulty,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      hintLetterIndices: hintLetterIndices ?? this.hintLetterIndices,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      requiredWords: requiredWords ?? this.requiredWords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static LevelDifficulty _parseDifficulty(String? value) {
    switch (value) {
      case 'easy':
        return LevelDifficulty.easy;
      case 'medium':
        return LevelDifficulty.medium;
      case 'hard':
        return LevelDifficulty.hard;
      case 'expert':
        return LevelDifficulty.expert;
      default:
        return LevelDifficulty.easy;
    }
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

class LevelProgressModel extends LevelProgress {
  const LevelProgressModel({
    required super.levelId,
    super.completed = false,
    super.wordsFound = const <String>{},
    super.bonusWordsFound = const <String>{},
    super.coinsEarned = 0,
    super.attempts = 0,
    super.timeSpentSeconds = 0,
    super.stars = 0,
    super.bestTimeSeconds,
    super.completedAt,
  });

  factory LevelProgressModel.fromMap(Map<String, dynamic> map) {
    return LevelProgressModel(
      levelId: map['levelId'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      wordsFound: Set<String>.from(map['wordsFound'] as List? ?? []),
      bonusWordsFound:
          Set<String>.from(map['bonusWordsFound'] as List? ?? []),
      coinsEarned: map['coinsEarned'] as int? ?? 0,
      attempts: map['attempts'] as int? ?? 0,
      timeSpentSeconds: map['timeSpentSeconds'] as int? ?? 0,
      stars: map['stars'] as int? ?? 0,
      bestTimeSeconds: map['bestTimeSeconds'] as int?,
      completedAt: _parseDate(map['completedAt']),
    );
  }

  factory LevelProgressModel.fromEntity(LevelProgress progress) {
    return LevelProgressModel(
      levelId: progress.levelId,
      completed: progress.completed,
      wordsFound: progress.wordsFound,
      bonusWordsFound: progress.bonusWordsFound,
      coinsEarned: progress.coinsEarned,
      attempts: progress.attempts,
      timeSpentSeconds: progress.timeSpentSeconds,
      stars: progress.stars,
      bestTimeSeconds: progress.bestTimeSeconds,
      completedAt: progress.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'completed': completed,
      'wordsFound': wordsFound.toList(),
      'bonusWordsFound': bonusWordsFound.toList(),
      'coinsEarned': coinsEarned,
      'attempts': attempts,
      'timeSpentSeconds': timeSpentSeconds,
      'stars': stars,
      'bestTimeSeconds': bestTimeSeconds,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  LevelProgressModel copyWith({
    int? levelId,
    bool? completed,
    Set<String>? wordsFound,
    Set<String>? bonusWordsFound,
    int? coinsEarned,
    int? attempts,
    int? timeSpentSeconds,
    int? stars,
    int? bestTimeSeconds,
    DateTime? completedAt,
  }) {
    return LevelProgressModel(
      levelId: levelId ?? this.levelId,
      completed: completed ?? this.completed,
      wordsFound: wordsFound ?? this.wordsFound,
      bonusWordsFound: bonusWordsFound ?? this.bonusWordsFound,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      attempts: attempts ?? this.attempts,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      stars: stars ?? this.stars,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      completedAt: completedAt ?? this.completedAt,
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

import 'package:equatable/equatable.dart';

/// Level difficulty
enum LevelDifficulty { easy, medium, hard, expert }

extension LevelDifficultyX on LevelDifficulty {
  String get arabicName {
    switch (this) {
      case LevelDifficulty.easy:
        return 'سهل';
      case LevelDifficulty.medium:
        return 'متوسط';
      case LevelDifficulty.hard:
        return 'صعب';
      case LevelDifficulty.expert:
        return 'خبير';
    }
  }
}

/// A level / puzzle in the game
class Level extends Equatable {
  const Level({
    required this.id,
    required this.letters,
    required this.answers,
    this.bonusWords = const <String>[],
    this.difficulty = LevelDifficulty.easy,
    this.rewardCoins = 50,
    this.hintLetterIndices = const <int>[],
    this.maxAttempts = 0,
    this.timeLimitSeconds = 0,
    this.requiredWords = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final List<String> letters;
  final List<String> answers;
  final List<String> bonusWords;
  final LevelDifficulty difficulty;
  final int rewardCoins;
  final List<int> hintLetterIndices;
  final int maxAttempts;
  final int timeLimitSeconds;
  final int requiredWords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get totalWords => answers.length;
  int get totalLetters => letters.length;
  bool get isTimed => timeLimitSeconds > 0;
  bool get hasAttemptsLimit => maxAttempts > 0;

  /// Get all possible words that could be formed (answers + bonus)
  Set<String> get allValidWords {
    final set = <String>{};
    set.addAll(answers);
    set.addAll(bonusWords);
    return set;
  }

  Level copyWith({
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
    return Level(
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

  @override
  List<Object?> get props => [
        id,
        letters,
        answers,
        bonusWords,
        difficulty,
        rewardCoins,
        hintLetterIndices,
        maxAttempts,
        timeLimitSeconds,
        requiredWords,
      ];
}

/// Progress on a specific level
class LevelProgress extends Equatable {
  const LevelProgress({
    required this.levelId,
    this.completed = false,
    this.wordsFound = const <String>{},
    this.bonusWordsFound = const <String>{},
    this.coinsEarned = 0,
    this.attempts = 0,
    this.timeSpentSeconds = 0,
    this.stars = 0,
    this.bestTimeSeconds,
    this.completedAt,
  });

  final int levelId;
  final bool completed;
  final Set<String> wordsFound;
  final Set<String> bonusWordsFound;
  final int coinsEarned;
  final int attempts;
  final int timeSpentSeconds;
  final int stars;
  final int? bestTimeSeconds;
  final DateTime? completedAt;

  int get totalFound => wordsFound.length + bonusWordsFound.length;

  LevelProgress copyWith({
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
    return LevelProgress(
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

  @override
  List<Object?> get props => [
        levelId,
        completed,
        wordsFound,
        bonusWordsFound,
        coinsEarned,
        attempts,
        timeSpentSeconds,
        stars,
        bestTimeSeconds,
        completedAt,
      ];
}

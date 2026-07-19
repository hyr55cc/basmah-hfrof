/// Type of word found
enum GameWordType {
  answer, // correct answer
  bonus, // bonus word
  dictionary, // valid word but not in this level
  invalid, // not a word
}

/// Game session state
class GameSessionState {
  const GameSessionState({
    required this.levelId,
    required this.startTime,
    this.endTime,
    this.wordsFound = 0,
    this.bonusWordsFound = 0,
    this.coinsEarned = 0,
    this.hintsUsed = 0,
    this.errors = 0,
  });

  final int levelId;
  final DateTime startTime;
  final DateTime? endTime;
  final int wordsFound;
  final int bonusWordsFound;
  final int coinsEarned;
  final int hintsUsed;
  final int errors;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  int get totalFound => wordsFound + bonusWordsFound;

  int get stars {
    if (wordsFound >= 10) return 3;
    if (wordsFound >= 5) return 2;
    if (wordsFound >= 1) return 1;
    return 0;
  }

  GameSessionState copyWith({
    int? levelId,
    DateTime? startTime,
    DateTime? endTime,
    int? wordsFound,
    int? bonusWordsFound,
    int? coinsEarned,
    int? hintsUsed,
    int? errors,
  }) {
    return GameSessionState(
      levelId: levelId ?? this.levelId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      wordsFound: wordsFound ?? this.wordsFound,
      bonusWordsFound: bonusWordsFound ?? this.bonusWordsFound,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      errors: errors ?? this.errors,
    );
  }
}

/// Hint types available in the game
enum HintType {
  revealLetter,
  revealWord,
  shuffle,
  skipLevel,
  removeWrongLetter,
}

extension HintTypeX on HintType {
  String get arabicName {
    switch (this) {
      case HintType.revealLetter:
        return 'كشف حرف';
      case HintType.revealWord:
        return 'كشف كلمة';
      case HintType.shuffle:
        return 'خلط الحروف';
      case HintType.skipLevel:
        return 'تخطي المستوى';
      case HintType.removeWrongLetter:
        return 'حذف حرف خاطئ';
    }
  }

  int get coinCost {
    switch (this) {
      case HintType.revealLetter:
        return 30;
      case HintType.revealWord:
        return 75;
      case HintType.shuffle:
        return 25;
      case HintType.skipLevel:
        return 150;
      case HintType.removeWrongLetter:
        return 50;
    }
  }
}

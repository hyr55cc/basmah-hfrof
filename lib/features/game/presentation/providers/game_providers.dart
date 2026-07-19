import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/audio/audio_service.dart';
import '../../../../core/services/haptics/haptic_service.dart';
import '../../../../data/datasources/remote/firebase_datasource.dart';
import '../../../../domain/entities/level.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/level_repository.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../domain/repositories/achievement_repository.dart';
import '../../core/game_controller.dart';
import '../../../../services/ads/ad_service.dart';
import '../../../../services/analytics/analytics_service.dart';

/// Current user provider - listens to firebase auth state
final currentUserProvider = StreamProvider<User?>((ref) {
  final firebase = sl<FirebaseDatasource>();
  final userRepo = sl<UserRepository>();
  return firebase.authStateChanges.asyncMap((fbUser) async {
    if (fbUser == null) return null;
    final result = await userRepo.getUser(fbUser.uid);
    return result.fold((_) => null, (user) => user);
  });
});

/// Level provider
final levelProvider = FutureProvider.family<Level?, int>((ref, levelId) async {
  final result = await sl<LevelRepository>().getLevel(levelId);
  return result.fold((failure) => null, (level) => level);
});

/// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) => sl<AudioService>());

/// Haptic service provider
final hapticServiceProvider = Provider<HapticService>((ref) => sl<HapticService>());

/// Analytics service provider
final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => sl<AnalyticsService>());

/// Ad service provider
final adServiceProvider = Provider<AdService>((ref) => sl<AdService>());

/// Game controller provider for a specific level
final gameControllerProvider =
    StateNotifierProvider.family<GameControllerNotifier, GameController, int>(
  (ref, levelId) {
    final notifier = GameControllerNotifier(
      levelId: levelId,
      haptic: ref.read(hapticServiceProvider),
      audio: ref.read(audioServiceProvider),
      analytics: ref.read(analyticsServiceProvider),
      adService: ref.read(adServiceProvider),
    );
    // Load the level
    notifier.loadLevel();
    return notifier;
  },
);

/// State notifier that wraps GameController and handles rewards/analytics
class GameControllerNotifier extends StateNotifier<GameController> {
  GameControllerNotifier({
    required this.levelId,
    required this.haptic,
    required this.audio,
    required this.analytics,
    required this.adService,
  }) : super(_emptyController());

  final int levelId;
  final HapticService haptic;
  final AudioService audio;
  final AnalyticsService analytics;
  final AdService adService;

  DateTime? _startTime;
  int _wordsFoundCount = 0;
  int _bonusWordsCount = 0;
  int _errorsCount = 0;
  int _coinsEarned = 0;
  bool _isCompleted = false;
  bool _isLoaded = false;
  Level? _level;

  bool get isLoaded => _isLoaded;
  bool get isCompleted => _isCompleted;
  int get coinsEarned => _coinsEarned;
  int get wordsFound => _wordsFoundCount;
  int get bonusWordsFound => _bonusWordsCount;
  int get errors => _errorsCount;
  Level? get level => _level;

  static GameController _emptyController() {
    return GameController(
      letters: ['ا', 'ب', 'ت', 'ث', 'ج', 'ح'],
      answers: ['بحث', 'حبت'],
      bonusWords: ['حب'],
    );
  }

  /// Load the level
  Future<void> loadLevel() async {
    _startTime = DateTime.now();
    final result = await sl<LevelRepository>().getLevel(levelId);
    final level = result.fold((_) => null, (l) => l);
    _level = level;
    if (level != null) {
      state = GameController(
        letters: level.letters,
        answers: level.answers,
        bonusWords: level.bonusWords,
      );
      analytics.logLevelStart(level.id, difficulty: level.difficulty.name);
    }
    _isLoaded = true;
  }

  /// Handle end of selection
  bool endSelection() {
    final result = state.endSelection();
    if (result) {
      _wordsFoundCount++;
      haptic.wordFound();
      audio.playSfx(SoundEffect.wordFound);
      analytics.logWordFound(state.currentWord);
      if (state.lastWordType?.name == 'bonus') {
        _bonusWordsCount++;
        _coinsEarned += 10;
      } else if (state.lastWordType?.name == 'dictionary') {
        _coinsEarned += 2;
      } else {
        _coinsEarned += 5;
      }
    } else {
      _errorsCount++;
      if (state.errorMessage != null) {
        haptic.wrong();
        audio.playSfx(SoundEffect.wrong);
      }
    }
    // Check if level is complete
    if (state.isCompleted && !_isCompleted) {
      _isCompleted = true;
      _onLevelComplete();
    }
    return result;
  }

  /// Use a hint
  bool useHint(HintType hintType) {
    switch (hintType) {
      case HintType.revealLetter:
        final result = state.revealLetter();
        if (result != null) {
          audio.playSfx(SoundEffect.hint);
          analytics.logHintUsed('reveal_letter', coinsSpent: hintType.coinCost);
          return true;
        }
        return false;
      case HintType.revealWord:
        final result = state.revealWord();
        if (result != null) {
          audio.playSfx(SoundEffect.hint);
          analytics.logHintUsed('reveal_word', coinsSpent: hintType.coinCost);
          _wordsFoundCount++;
          _coinsEarned += 5;
          return true;
        }
        return false;
      case HintType.shuffle:
        state.shuffle();
        audio.playSfx(SoundEffect.whoosh);
        analytics.logHintUsed('shuffle', coinsSpent: hintType.coinCost);
        return true;
      case HintType.removeWrongLetter:
        state.removeWrongLetter();
        audio.playSfx(SoundEffect.hint);
        analytics.logHintUsed(
          'remove_wrong_letter',
          coinsSpent: hintType.coinCost,
        );
        return true;
      case HintType.skipLevel:
        _isCompleted = true;
        analytics.logHintUsed('skip_level', coinsSpent: hintType.coinCost);
        return true;
    }
  }

  void _onLevelComplete() async {
    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;
    final userId = sl<FirebaseDatasource>().currentFirebaseUser?.uid;
    if (userId == null) return;

    final level = _level;
    if (level == null) return;

    haptic.levelComplete();
    audio.playSfx(SoundEffect.levelComplete);
    analytics.logLevelComplete(
      level.id,
      timeSpent: duration,
      wordsFound: _wordsFoundCount,
      stars: _wordsFoundCount >= 10
          ? 3
          : _wordsFoundCount >= 5
              ? 2
              : 1,
    );

    // Calculate coins
    final levelCoins = level.rewardCoins;
    final wordCoins = _wordsFoundCount * 5;
    final bonusCoins = _bonusWordsCount * 10;
    final totalCoins = levelCoins + wordCoins + bonusCoins;
    _coinsEarned += totalCoins;

    // Save progress
    final progress = LevelProgress(
      levelId: level.id,
      completed: true,
      coinsEarned: totalCoins,
      attempts: 1,
      timeSpentSeconds: duration,
      stars: _wordsFoundCount >= 10
          ? 3
          : _wordsFoundCount >= 5
              ? 2
              : 1,
      bestTimeSeconds: duration,
      completedAt: DateTime.now(),
    );
    await sl<LevelRepository>().saveLevelProgress(progress);

    // Update user coins and progress
    await sl<UserRepository>().addCoins(userId, totalCoins);
    await sl<UserRepository>().updateLevelProgress(
      userId: userId,
      newLevel: level.id + 1,
      score: totalCoins,
      wordsFound: _wordsFoundCount,
    );
    await sl<UserRepository>().updateStats(
      userId: userId,
      totalBonusWords: _bonusWordsCount,
    );

    // Update achievements
    await sl<AchievementRepository>().incrementProgress(
      userId: userId,
      achievementId: 'word_100',
      amount: _wordsFoundCount,
    );
    await sl<AchievementRepository>().incrementProgress(
      userId: userId,
      achievementId: 'level_${level.id}',
      amount: 1,
    );

    // Show ad after every 3 levels
    adService.showInterstitialAfterLevel();

    // Force notify listeners
    state = state;
  }
}

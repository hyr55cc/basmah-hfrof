import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/achievement_model.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  AchievementRepositoryImpl({
    required this.firebase,
    required this.storage,
  });

  final FirebaseDatasource firebase;
  final LocalStorage storage;

  /// All default achievements
  static final List<Achievement> _defaultAchievements = [
    Achievement(
      id: 'first_level',
      title: 'البداية',
      description: 'أكمل أول مستوى',
      type: AchievementType.levels,
      target: 1,
      rewardCoins: 50,
      icon: 'star',
    ),
    Achievement(
      id: 'level_10',
      title: 'متعلم',
      description: 'أكمل 10 مستويات',
      type: AchievementType.levels,
      target: 10,
      rewardCoins: 100,
      icon: 'school',
    ),
    Achievement(
      id: 'level_50',
      title: 'محترف',
      description: 'أكمل 50 مستوى',
      type: AchievementType.levels,
      target: 50,
      rewardCoins: 200,
      icon: 'military_tech',
    ),
    Achievement(
      id: 'level_100',
      title: 'خبير',
      description: 'أكمل 100 مستوى',
      type: AchievementType.levels,
      target: 100,
      rewardCoins: 500,
      icon: 'workspace_premium',
    ),
    Achievement(
      id: 'level_500',
      title: 'أسطورة',
      description: 'أكمل 500 مستوى',
      type: AchievementType.levels,
      target: 500,
      rewardCoins: 2000,
      icon: 'emoji_events',
    ),
    Achievement(
      id: 'level_1000',
      title: 'بطل',
      description: 'أكمل 1000 مستوى',
      type: AchievementType.levels,
      target: 1000,
      rewardCoins: 5000,
      icon: 'military_tech',
    ),
    Achievement(
      id: 'word_100',
      title: 'جامع الكلمات',
      description: 'اكتشف 100 كلمة',
      type: AchievementType.words,
      target: 100,
      rewardCoins: 100,
      icon: 'menu_book',
    ),
    Achievement(
      id: 'word_1000',
      title: 'معجمي',
      description: 'اكتشف 1000 كلمة',
      type: AchievementType.words,
      target: 1000,
      rewardCoins: 300,
      icon: 'auto_stories',
    ),
    Achievement(
      id: 'word_10000',
      title: 'قاموس متنقل',
      description: 'اكتشف 10,000 كلمة',
      type: AchievementType.words,
      target: 10000,
      rewardCoins: 1000,
      icon: 'library_books',
    ),
    Achievement(
      id: 'word_100000',
      title: 'عالم لغوي',
      description: 'اكتشف 100,000 كلمة',
      type: AchievementType.words,
      target: 100000,
      rewardCoins: 10000,
      icon: 'psychology',
    ),
    Achievement(
      id: 'bonus_20',
      title: 'صياد',
      description: 'اكتشف 20 كلمة إضافية',
      type: AchievementType.bonus,
      target: 20,
      rewardCoins: 100,
      icon: 'search',
    ),
    Achievement(
      id: 'bonus_100',
      title: 'صائد محترف',
      description: 'اكتشف 100 كلمة إضافية',
      type: AchievementType.bonus,
      target: 100,
      rewardCoins: 300,
      icon: 'travel_explore',
    ),
    Achievement(
      id: 'coins_1000',
      title: 'جامع الثروة',
      description: 'اجمع 1,000 عملة',
      type: AchievementType.coins,
      target: 1000,
      rewardCoins: 200,
      icon: 'savings',
    ),
    Achievement(
      id: 'coins_10000',
      title: 'ثري',
      description: 'اجمع 10,000 عملة',
      type: AchievementType.coins,
      target: 10000,
      rewardCoins: 1000,
      icon: 'account_balance',
    ),
    Achievement(
      id: 'coins_100000',
      title: 'مليونير',
      description: 'اجمع 100,000 عملة',
      type: AchievementType.coins,
      target: 100000,
      rewardCoins: 5000,
      icon: 'diamond',
    ),
    Achievement(
      id: 'perfect_10',
      title: 'مثالي',
      description: 'أكمل 10 مستويات دون أخطاء',
      type: AchievementType.perfect,
      target: 10,
      rewardCoins: 500,
      icon: 'verified',
    ),
    Achievement(
      id: 'speed_run',
      title: 'سريع البرق',
      description: 'أكمل 5 مستويات في أقل من دقيقة',
      type: AchievementType.speed,
      target: 5,
      rewardCoins: 200,
      icon: 'flash_on',
    ),
    Achievement(
      id: 'daily_7',
      title: 'منتظم',
      description: 'سجل دخول 7 أيام متتالية',
      type: AchievementType.daily,
      target: 7,
      rewardCoins: 200,
      icon: 'calendar_today',
    ),
    Achievement(
      id: 'daily_30',
      title: 'مداوم',
      description: 'سجل دخول 30 يومًا متتاليًا',
      type: AchievementType.daily,
      target: 30,
      rewardCoins: 1000,
      icon: 'event_available',
    ),
    Achievement(
      id: 'daily_365',
      title: 'سنوي',
      description: 'سجل دخول 365 يومًا متتاليًا',
      type: AchievementType.daily,
      target: 365,
      rewardCoins: 10000,
      icon: 'workspace_premium',
    ),
  ];

  @override
  Future<Either<Failure, List<Achievement>>> getAllAchievements() async {
    try {
      try {
        final remote = await firebase.getAllAchievements();
        if (remote.isNotEmpty) return Right(remote.cast<Achievement>());
      } catch (_) {}
      return Right(_defaultAchievements);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<AchievementProgress>>> getUserProgress(
    String userId,
  ) async {
    try {
      final allAchievements = await getAllAchievements();
      return allAchievements.fold((failure) => Left(failure), (achievements) async {
        final progress = await firebase.getAchievementProgress(userId);
        // Build a map of existing progress
        final progressMap = <String, AchievementProgressModel>{};
        for (final p in progress) {
          progressMap[p.achievement.id] = p;
        }
        // Create a progress for each achievement
        final result = <AchievementProgress>[];
        for (final achievement in achievements) {
          final existing = progressMap[achievement.id];
          if (existing != null) {
            result.add(existing);
          } else {
            result.add(AchievementProgress(
              achievement: achievement,
              current: 0,
            ));
          }
        }
        return Right(result);
      });
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, AchievementProgress>> updateProgress({
    required String userId,
    required String achievementId,
    required int current,
  }) async {
    try {
      final all = await getAllAchievements();
      return all.fold((failure) => Left(failure), (achievements) async {
        final achievement = achievements.firstWhere(
          (a) => a.id == achievementId,
          orElse: () => _defaultAchievements.first,
        );
        final progress = AchievementProgress(
          achievement: achievement,
          current: current,
          completed: current >= achievement.target,
          completedAt:
              current >= achievement.target ? DateTime.now() : null,
        );
        final model = AchievementProgressModel.fromEntity(progress);
        await firebase.saveAchievementProgress(userId, model);
        return Right(progress);
      });
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, AchievementProgress>> incrementProgress({
    required String userId,
    required String achievementId,
    required int amount,
  }) async {
    try {
      final existing = await firebase.getAchievementProgress(userId);
      final currentProgress = existing.firstWhere(
        (p) => p.achievement.id == achievementId,
        orElse: () => AchievementProgressModel(
          achievement: _defaultAchievements.firstWhere(
            (a) => a.id == achievementId,
            orElse: () => _defaultAchievements.first,
          ),
          current: 0,
        ),
      );
      final newCurrent = currentProgress.current + amount;
      return updateProgress(
        userId: userId,
        achievementId: achievementId,
        current: newCurrent,
      );
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> claimReward({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final progress = await firebase.getAchievementProgress(userId);
      final current = progress.firstWhere(
        (p) => p.achievement.id == achievementId,
        orElse: () => AchievementProgressModel(
          achievement: _defaultAchievements.first,
          current: 0,
        ),
      );
      if (!current.completed || current.claimed) {
        return const Left(ValidationFailure('لا يمكن استلام المكافأة'));
      }
      final model = AchievementProgressModel.fromEntity(
        current.copyWith(claimed: true),
      );
      await firebase.saveAchievementProgress(userId, model);
      return Right(current.achievement.rewardCoins);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Stream<List<AchievementProgress>> get progressStream {
    final userId = firebase.currentFirebaseUser?.uid;
    if (userId == null) {
      return const Stream<List<AchievementProgress>>.empty();
    }
    return firebase
        .firestore
        .collection('users')
        .doc(userId)
        .collection('achievement_progress')
        .snapshots()
        .asyncMap((_) async {
      final result = await getUserProgress(userId);
      return result.fold((_) => <AchievementProgress>[], (r) => r);
    });
  }

  @override
  Future<Either<Failure, void>> markAllAsSeen(String userId) async {
    try {
      final progress = await firebase.getAchievementProgress(userId);
      for (final p in progress) {
        if (!p.claimed) {
          // Mark as seen logic - we use seenAt timestamp
          await firebase.firestore
              .collection('users')
              .doc(userId)
              .collection('achievement_progress')
              .doc(p.achievement.id)
              .update({'seenAt': DateTime.now().toIso8601String()});
        }
      }
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<AchievementProgress>>> getUnseen(
    String userId,
  ) async {
    try {
      final all = await getUserProgress(userId);
      return all.fold((failure) => Left(failure), (progress) {
        final unseen = progress
            .where((p) => p.completed && !p.claimed)
            .toList();
        return Right(unseen);
      });
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  Failure _mapFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return UnknownFailure(e.message);
  }
}

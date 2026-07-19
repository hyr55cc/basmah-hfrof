import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/shop_model.dart';
import '../models/user_model.dart';
import '../../services/iap/purchase_service.dart';

class ShopRepositoryImpl implements ShopRepository {
  ShopRepositoryImpl({
    required this.firebase,
    required this.storage,
    required this.purchase,
  });

  final FirebaseDatasource firebase;
  final LocalStorage storage;
  final PurchaseService purchase;

  static final List<ShopItem> _defaultItems = [
    const ShopItem(
      id: 'coins_100',
      title: '100 عملة',
      description: '100 عملة ذهبية',
      category: ShopItemCategory.coins,
      price: 0.99,
      currency: 'USD',
      amount: 100,
      productId: AppConstants.iapCoinPack100,
      iconData: 0xe263, // coin icon
      color: 0xFFFFC93C,
    ),
    const ShopItem(
      id: 'coins_500',
      title: '500 عملة',
      description: '500 عملة ذهبية',
      category: ShopItemCategory.coins,
      price: 3.99,
      currency: 'USD',
      amount: 500,
      productId: AppConstants.iapCoinPack500,
      iconData: 0xe263,
      color: 0xFFFFC93C,
      discountPercent: 20,
      popular: true,
    ),
    const ShopItem(
      id: 'coins_1000',
      title: '1,000 عملة',
      description: '1,000 عملة ذهبية',
      category: ShopItemCategory.coins,
      price: 6.99,
      currency: 'USD',
      amount: 1000,
      productId: AppConstants.iapCoinPack1000,
      iconData: 0xe263,
      color: 0xFFFFC93C,
      discountPercent: 30,
    ),
    const ShopItem(
      id: 'coins_5000',
      title: '5,000 عملة',
      description: '5,000 عملة ذهبية - أفضل قيمة',
      category: ShopItemCategory.coins,
      price: 24.99,
      currency: 'USD',
      amount: 5000,
      productId: AppConstants.iapCoinPack5000,
      iconData: 0xe263,
      color: 0xFFFFC93C,
      discountPercent: 50,
      popular: true,
    ),
    const ShopItem(
      id: 'hints_pack',
      title: 'حزمة التلميحات',
      description: '20 تلميحًا إضافيًا',
      category: ShopItemCategory.hints,
      price: 1.99,
      currency: 'USD',
      amount: 20,
      productId: AppConstants.iapHintPack,
      iconData: 0xe88e, // lightbulb
      color: 0xFFFFA53D,
    ),
    const ShopItem(
      id: 'remove_ads',
      title: 'إزالة الإعلانات',
      description: 'استمتع باللعبة بدون إعلانات',
      category: ShopItemCategory.removeAds,
      price: 4.99,
      currency: 'USD',
      productId: AppConstants.iapRemoveAds,
      iconData: 0xe57f, // block
      color: 0xFFE74C3C,
    ),
    const ShopItem(
      id: 'premium_monthly',
      title: 'العضوية المميزة - شهري',
      description: 'إزالة الإعلانات + مكافآت يومية مضاعفة + تلميحات غير محدودة',
      category: ShopItemCategory.premium,
      price: 4.99,
      currency: 'USD',
      isSubscription: true,
      subscriptionDurationDays: 30,
      productId: AppConstants.iapPremiumMonthly,
      iconData: 0xea5e, // workspace_premium
      color: 0xFF6C63FF,
      popular: true,
    ),
    const ShopItem(
      id: 'premium_yearly',
      title: 'العضوية المميزة - سنوي',
      description: 'كل مزايا المميزة بسعر مخفض',
      category: ShopItemCategory.premium,
      price: 39.99,
      currency: 'USD',
      isSubscription: true,
      subscriptionDurationDays: 365,
      productId: AppConstants.iapPremiumYearly,
      iconData: 0xea5e,
      color: 0xFF6C63FF,
      discountPercent: 33,
      popular: true,
    ),
    const ShopItem(
      id: 'starter_pack',
      title: 'حزمة البداية',
      description: '500 عملة + 10 تلميحات + إزالة الإعلانات لمدة 7 أيام',
      category: ShopItemCategory.starterPack,
      price: 2.99,
      currency: 'USD',
      productId: AppConstants.iapStarterPack,
      iconData: 0xe8d1, // card_giftcard
      color: 0xFF00D4AA,
      limited: true,
      discountPercent: 70,
    ),
  ];

  static final List<DailyReward> _defaultDailyRewards = [
    const DailyReward(day: 1, coins: 25, icon: 0xe88e),
    const DailyReward(day: 2, coins: 50, icon: 0xe88e),
    const DailyReward(day: 3, coins: 75, icon: 0xe88e),
    const DailyReward(day: 4, coins: 100, icon: 0xe88e),
    const DailyReward(day: 5, coins: 125, hints: 1, icon: 0xe88e),
    const DailyReward(day: 6, coins: 150, hints: 2, icon: 0xe88e),
    const DailyReward(day: 7, coins: 200, hints: 3, gems: 5, icon: 0xea5e),
  ];

  @override
  Future<Either<Failure, List<ShopItem>>> getShopItems() async {
    try {
      try {
        final remote = await firebase.getShopItems();
        if (remote.isNotEmpty) return Right(remote.cast<ShopItem>());
      } catch (_) {}
      return Right(_defaultItems);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ShopItem>>> getShopItemsByCategory(
    ShopItemCategory category,
  ) async {
    final all = await getShopItems();
    return all.fold((failure) => Left(failure), (items) {
      return Right(items.where((i) => i.category == category).toList());
    });
  }

  @override
  Future<Either<Failure, ShopItem?>> getShopItem(String itemId) async {
    final all = await getShopItems();
    return all.fold((failure) => Left(failure), (items) {
      final found = items.where((i) => i.id == itemId).toList();
      return Right(found.isEmpty ? null : found.first);
    });
  }

  @override
  Future<Either<Failure, List<DailyReward>>> getDailyRewards() async {
    try {
      try {
        final remote = await firebase.getDailyRewards();
        if (remote.isNotEmpty) return Right(remote.cast<DailyReward>());
      } catch (_) {}
      return Right(_defaultDailyRewards);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, DailyRewardStatus>> getDailyRewardStatus(
    String userId,
  ) async {
    try {
      final user = await firebase.getUser(userId);
      final rewards = await getDailyRewards();
      return rewards.fold((failure) => Left(failure), (rewardsList) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        DateTime? lastClaim;
        if (user?.lastDailyRewardDate != null) {
          lastClaim = user!.lastDailyRewardDate!;
        }
        final canClaim = lastClaim == null ||
            today.isAfter(DateTime(
              lastClaim!.year,
              lastClaim.month,
              lastClaim.day,
            ));
        final currentStreak = user?.dailyRewardStreak ?? 0;
        final nextDay = canClaim
            ? (currentStreak % 7) + 1
            : currentStreak % 7;
        final nextReward = rewardsList.firstWhere(
          (r) => r.day == nextDay,
          orElse: () => rewardsList.first,
        );
        return Right(DailyRewardStatus(
          currentStreak: currentStreak,
          canClaimToday: canClaim,
          todayReward: nextReward,
          nextReward: nextReward,
          lastClaimDate: lastClaim,
        ));
      });
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, DailyReward>> claimDailyReward(String userId) async {
    try {
      final status = await getDailyRewardStatus(userId);
      return status.fold((failure) => Left(failure), (s) async {
        if (!s.canClaimToday) {
          return const Left(ValidationFailure('لا يمكنك استلام المكافأة اليوم'));
        }
        final reward = s.todayReward;
        final user = await firebase.getUser(userId);
        if (user == null) {
          return const Left(NotFoundFailure('المستخدم غير موجود'));
        }
        final newStreak = s.currentStreak + 1;
        final updated = user.copyWith(
          coins: user.coins + reward.coins,
          gems: user.gems + reward.gems,
          hints: user.hints + reward.hints,
          dailyRewardStreak: newStreak,
          lastDailyRewardDate: DateTime.now(),
        );
        await firebase.updateUserDocument(UserModel.fromEntity(updated));
        return Right(reward);
      });
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<DailyReward>>> getWeeklyRewards() async {
    final all = await getDailyRewards();
    return all.fold(
      (failure) => Left(failure),
      (rewards) => Right(rewards.take(7).toList()),
    );
  }

  @override
  Future<Either<Failure, List<DailyReward>>> getMonthlyRewards() async {
    final all = await getDailyRewards();
    return all.fold(
      (failure) => Left(failure),
      (rewards) => Right(rewards.toList()),
    );
  }

  @override
  Future<Either<Failure, void>> processPurchase({
    required String userId,
    required String productId,
    required String transactionId,
    Map<String, dynamic>? receiptData,
  }) async {
    try {
      final item = _defaultItems.firstWhere(
        (i) => i.productId == productId,
        orElse: () => _defaultItems.first,
      );
      final user = await firebase.getUser(userId);
      if (user == null) {
        return const Left(NotFoundFailure('المستخدم غير موجود'));
      }
      var updated = user;
      if (item.amount != null) {
        if (item.category == ShopItemCategory.coins) {
          updated = updated.copyWith(coins: updated.coins + item.amount!);
        } else if (item.category == ShopItemCategory.hints) {
          updated = updated.copyWith(hints: updated.hints + item.amount!);
        }
      }
      if (item.category == ShopItemCategory.removeAds) {
        updated = updated.copyWith(isPremium: true);
      }
      if (item.category == ShopItemCategory.premium) {
        updated = updated.copyWith(
          isPremium: true,
          premiumExpiryDate: DateTime.now().add(
            Duration(days: item.subscriptionDurationDays),
          ),
        );
      }
      if (item.category == ShopItemCategory.starterPack) {
        updated = updated.copyWith(
          coins: updated.coins + 500,
          hints: updated.hints + 10,
        );
      }
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      await firebase.recordPurchase(
        userId: userId,
        productId: productId,
        transactionId: transactionId,
        amount: item.price,
        currency: item.currency,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases(String userId) async {
    try {
      await purchase.restorePurchases();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ShopItem>>> getAvailableProducts() async {
    try {
      final products = await purchase.getProducts();
      if (products.isNotEmpty) {
        return Right(products);
      }
      return getShopItems();
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> grantStarterPack(String userId) async {
    return processPurchase(
      userId: userId,
      productId: AppConstants.iapStarterPack,
      transactionId: 'starter_grant_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Failure _mapFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is PurchaseException) return PurchaseFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return UnknownFailure(e.message);
  }
}

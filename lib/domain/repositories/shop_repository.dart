import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/shop.dart';

abstract class ShopRepository {
  /// Get all shop items
  Future<Either<Failure, List<ShopItem>>> getShopItems();

  /// Get shop items by category
  Future<Either<Failure, List<ShopItem>>> getShopItemsByCategory(
    ShopItemCategory category,
  );

  /// Get a single shop item
  Future<Either<Failure, ShopItem?>> getShopItem(String itemId);

  /// Get all daily rewards
  Future<Either<Failure, List<DailyReward>>> getDailyRewards();

  /// Get current daily reward status
  Future<Either<Failure, DailyRewardStatus>> getDailyRewardStatus(
    String userId,
  );

  /// Claim today's daily reward
  Future<Either<Failure, DailyReward>> claimDailyReward(String userId);

  /// Get weekly rewards
  Future<Either<Failure, List<DailyReward>>> getWeeklyRewards();

  /// Get monthly rewards
  Future<Either<Failure, List<DailyReward>>> getMonthlyRewards();

  /// Process purchase (called after IAP success)
  Future<Either<Failure, void>> processPurchase({
    required String userId,
    required String productId,
    required String transactionId,
    Map<String, dynamic>? receiptData,
  });

  /// Restore purchases
  Future<Either<Failure, void>> restorePurchases(String userId);

  /// Get available IAP products
  Future<Either<Failure, List<ShopItem>>> getAvailableProducts();

  /// Grant starter pack
  Future<Either<Failure, void>> grantStarterPack(String userId);
}

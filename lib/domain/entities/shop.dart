import 'package:equatable/equatable.dart';

/// Shop item category
enum ShopItemCategory {
  coins,
  hints,
  removeAds,
  premium,
  starterPack,
  special,
}

extension ShopItemCategoryX on ShopItemCategory {
  String get arabicName {
    switch (this) {
      case ShopItemCategory.coins:
        return 'العملات';
      case ShopItemCategory.hints:
        return 'التلميحات';
      case ShopItemCategory.removeAds:
        return 'إزالة الإعلانات';
      case ShopItemCategory.premium:
        return 'العضوية المميزة';
      case ShopItemCategory.starterPack:
        return 'حزمة البداية';
      case ShopItemCategory.special:
        return 'خاص';
    }
  }
}

/// Shop item
class ShopItem extends Equatable {
  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.currency,
    this.amount,
    this.productId,
    this.isSubscription = false,
    this.subscriptionDurationDays = 0,
    this.imageUrl,
    this.iconData,
    this.color,
    this.discountPercent = 0,
    this.popular = false,
    this.limited = false,
  });

  final String id;
  final String title;
  final String description;
  final ShopItemCategory category;
  final double price;
  final String currency;
  final int? amount;
  final String? productId;
  final bool isSubscription;
  final int subscriptionDurationDays;
  final String? imageUrl;
  final int? iconData;
  final int? color;
  final int discountPercent;
  final bool popular;
  final bool limited;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        price,
        currency,
        amount,
        productId,
        isSubscription,
        subscriptionDurationDays,
        imageUrl,
        iconData,
        color,
        discountPercent,
        popular,
        limited,
      ];
}

/// Daily reward
class DailyReward extends Equatable {
  const DailyReward({
    required this.day,
    required this.coins,
    this.gems = 0,
    this.hints = 0,
    this.specialItemId,
    this.icon,
  });

  final int day; // 1-7 for weekly
  final int coins;
  final int gems;
  final int hints;
  final String? specialItemId;
  final int? icon;

  @override
  List<Object?> get props => [day, coins, gems, hints, specialItemId, icon];
}

/// Daily reward claim status
class DailyRewardStatus extends Equatable {
  const DailyRewardStatus({
    required this.currentStreak,
    required this.canClaimToday,
    required this.todayReward,
    required this.nextReward,
    this.lastClaimDate,
  });

  final int currentStreak;
  final bool canClaimToday;
  final DailyReward todayReward;
  final DailyReward nextReward;
  final DateTime? lastClaimDate;

  @override
  List<Object?> get props =>
      [currentStreak, canClaimToday, todayReward, nextReward, lastClaimDate];
}

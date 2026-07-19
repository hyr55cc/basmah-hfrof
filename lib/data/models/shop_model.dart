import '../../domain/entities/shop.dart';

class ShopItemModel extends ShopItem {
  const ShopItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.currency,
    super.amount,
    super.productId,
    super.isSubscription = false,
    super.subscriptionDurationDays = 0,
    super.imageUrl,
    super.iconData,
    super.color,
    super.discountPercent = 0,
    super.popular = false,
    super.limited = false,
  });

  factory ShopItemModel.fromMap(Map<String, dynamic> map) {
    return ShopItemModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: _parseCategory(map['category'] as String?),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      amount: map['amount'] as int?,
      productId: map['productId'] as String?,
      isSubscription: map['isSubscription'] as bool? ?? false,
      subscriptionDurationDays: map['subscriptionDurationDays'] as int? ?? 0,
      imageUrl: map['imageUrl'] as String?,
      iconData: map['iconData'] as int?,
      color: map['color'] as int?,
      discountPercent: map['discountPercent'] as int? ?? 0,
      popular: map['popular'] as bool? ?? false,
      limited: map['limited'] as bool? ?? false,
    );
  }

  factory ShopItemModel.fromEntity(ShopItem item) {
    return ShopItemModel(
      id: item.id,
      title: item.title,
      description: item.description,
      category: item.category,
      price: item.price,
      currency: item.currency,
      amount: item.amount,
      productId: item.productId,
      isSubscription: item.isSubscription,
      subscriptionDurationDays: item.subscriptionDurationDays,
      imageUrl: item.imageUrl,
      iconData: item.iconData,
      color: item.color,
      discountPercent: item.discountPercent,
      popular: item.popular,
      limited: item.limited,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'price': price,
      'currency': currency,
      'amount': amount,
      'productId': productId,
      'isSubscription': isSubscription,
      'subscriptionDurationDays': subscriptionDurationDays,
      'imageUrl': imageUrl,
      'iconData': iconData,
      'color': color,
      'discountPercent': discountPercent,
      'popular': popular,
      'limited': limited,
    };
  }

  static ShopItemCategory _parseCategory(String? value) {
    switch (value) {
      case 'coins':
        return ShopItemCategory.coins;
      case 'hints':
        return ShopItemCategory.hints;
      case 'removeAds':
        return ShopItemCategory.removeAds;
      case 'premium':
        return ShopItemCategory.premium;
      case 'starterPack':
        return ShopItemCategory.starterPack;
      default:
        return ShopItemCategory.special;
    }
  }
}

class DailyRewardModel extends DailyReward {
  const DailyRewardModel({
    required super.day,
    required super.coins,
    super.gems = 0,
    super.hints = 0,
    super.specialItemId,
    super.icon,
  });

  factory DailyRewardModel.fromMap(Map<String, dynamic> map) {
    return DailyRewardModel(
      day: map['day'] as int? ?? 1,
      coins: map['coins'] as int? ?? 0,
      gems: map['gems'] as int? ?? 0,
      hints: map['hints'] as int? ?? 0,
      specialItemId: map['specialItemId'] as String?,
      icon: map['icon'] as int?,
    );
  }

  factory DailyRewardModel.fromEntity(DailyReward reward) {
    return DailyRewardModel(
      day: reward.day,
      coins: reward.coins,
      gems: reward.gems,
      hints: reward.hints,
      specialItemId: reward.specialItemId,
      icon: reward.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'coins': coins,
      'gems': gems,
      'hints': hints,
      'specialItemId': specialItemId,
      'icon': icon,
    };
  }
}

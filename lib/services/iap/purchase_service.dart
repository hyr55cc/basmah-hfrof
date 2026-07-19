import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/shop.dart';

/// In-app purchase service
class PurchaseService {
  PurchaseService() {
    _initialize();
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  final StreamController<List<ShopItem>> _productsController =
      StreamController<List<ShopItem>>.broadcast();
  List<ProductDetails> _products = [];
  bool _available = false;
  bool get available => _available;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Stream<List<ShopItem>> get productsStream => _productsController.stream;

  Future<void> _initialize() async {
    try {
      _available = await _iap.isAvailable();
      // Listen to purchase updates
      _iap.purchaseStream.listen(_handlePurchaseUpdates);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IAP init error: $e');
      }
    }
  }

  /// Load available products
  Future<List<ShopItem>> getProducts() async {
    if (!_available) return [];
    try {
      const productIds = <String>{
        AppConstants.iapRemoveAds,
        AppConstants.iapPremiumMonthly,
        AppConstants.iapPremiumYearly,
        AppConstants.iapCoinPack100,
        AppConstants.iapCoinPack500,
        AppConstants.iapCoinPack1000,
        AppConstants.iapCoinPack5000,
        AppConstants.iapHintPack,
        AppConstants.iapStarterPack,
      };
      final response = await _iap.queryProductDetails(productIds);
      _products = response.productDetails;
      final items = _products.map(_toShopItem).toList();
      _productsController.add(items);
      return items;
    } on InAppPurchaseException catch (e) {
      throw PurchaseException(e.message, e.code);
    } catch (e) {
      throw PurchaseException(e.toString());
    }
  }

  /// Buy a product
  Future<bool> buyProduct(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return result;
    } on InAppPurchaseException catch (e) {
      throw PurchaseException(e.message, e.code);
    } catch (e) {
      throw PurchaseException(e.toString());
    }
  }

  /// Buy a consumable
  Future<bool> buyConsumable(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      final result = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      return result;
    } on InAppPurchaseException catch (e) {
      throw PurchaseException(e.message, e.code);
    } catch (e) {
      throw PurchaseException(e.toString());
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } on InAppPurchaseException catch (e) {
      throw PurchaseException(e.message, e.code);
    } catch (e) {
      throw PurchaseException(e.toString());
    }
  }

  /// Complete a pending purchase
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          if (kDebugMode) debugPrint('Purchase pending: ${purchase.productID}');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          completePurchase(purchase);
          if (kDebugMode) {
            debugPrint('Purchase completed: ${purchase.productID}');
          }
          break;
        case PurchaseStatus.error:
          if (kDebugMode) {
            debugPrint('Purchase error: ${purchase.error}');
          }
          break;
        case PurchaseStatus.canceled:
          if (kDebugMode) {
            debugPrint('Purchase canceled: ${purchase.productID}');
          }
          break;
      }
    }
  }

  ShopItem _toShopItem(ProductDetails product) {
    final id = product.id;
    final category = _categoryFromProductId(id);
    final isSubscription = id == AppConstants.iapPremiumMonthly ||
        id == AppConstants.iapPremiumYearly;
    return ShopItem(
      id: id,
      title: product.title,
      description: product.description,
      category: category,
      price: product.price,
      currency: product.currencyCode,
      amount: _amountFromProductId(id),
      productId: id,
      isSubscription: isSubscription,
      subscriptionDurationDays: id == AppConstants.iapPremiumMonthly ? 30 : 365,
    );
  }

  ShopItemCategory _categoryFromProductId(String id) {
    if (id.contains('coin')) return ShopItemCategory.coins;
    if (id.contains('hint')) return ShopItemCategory.hints;
    if (id == AppConstants.iapRemoveAds) return ShopItemCategory.removeAds;
    if (id.contains('premium')) return ShopItemCategory.premium;
    if (id == AppConstants.iapStarterPack) return ShopItemCategory.starterPack;
    return ShopItemCategory.special;
  }

  int? _amountFromProductId(String id) {
    switch (id) {
      case AppConstants.iapCoinPack100:
        return 100;
      case AppConstants.iapCoinPack500:
        return 500;
      case AppConstants.iapCoinPack1000:
        return 1000;
      case AppConstants.iapCoinPack5000:
        return 5000;
      case AppConstants.iapHintPack:
        return 20;
      default:
        return null;
    }
  }

  Future<void> dispose() async {
    await _productsController.close();
  }
}

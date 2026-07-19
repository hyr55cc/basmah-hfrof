import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

/// Ad service for AdMob integration
class AdService {
  AdService();

  bool _initialized = false;
  bool _adsRemoved = false;
  DateTime? _lastInterstitialShown;
  DateTime? _lastRewardedShown;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get initialized => _initialized;
  set adsRemoved(bool value) => _adsRemoved = value;
  bool get adsRemoved => _adsRemoved;

  // Frequency controls
  int _interstitialCount = 0;
  static const int _interstitialEveryN = 3; // every 3rd level

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdMob init error: $e');
      }
    }
  }

  /// Create a banner ad
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    void Function()? onLoaded,
    void Function()? onFailed,
  }) {
    return BannerAd(
      adUnitId: AppConstants.adMobBannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('Banner ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) debugPrint('Banner ad failed: $error');
          ad.dispose();
          onFailed?.call();
        },
      ),
    );
  }

  /// Load an interstitial ad
  Future<InterstitialAd?> loadInterstitial() async {
    if (_adsRemoved) return null;
    try {
      await InterstitialAd.load(
        adUnitId: AppConstants.adMobInterstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            if (kDebugMode) debugPrint('Interstitial loaded');
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) debugPrint('Interstitial failed: $error');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Load interstitial error: $e');
    }
    return _interstitialAd;
  }

  /// Show an interstitial ad
  Future<bool> showInterstitial({bool force = false}) async {
    if (_adsRemoved && !force) return false;
    // Throttle: don't show more than once per 60 seconds
    if (!force && _lastInterstitialShown != null) {
      final diff = DateTime.now().difference(_lastInterstitialShown!);
      if (diff.inSeconds < 60) return false;
    }
    if (_interstitialAd == null) {
      await loadInterstitial();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (_interstitialAd == null) return false;
    try {
      _interstitialAd!.show();
      _lastInterstitialShown = DateTime.now();
      _interstitialAd = null;
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Show interstitial error: $e');
      return false;
    }
  }

  /// Show interstitial after level complete (with frequency control)
  Future<bool> showInterstitialAfterLevel() async {
    if (_adsRemoved) return false;
    _interstitialCount++;
    if (_interstitialCount % _interstitialEveryN != 0) return false;
    return showInterstitial();
  }

  /// Load a rewarded ad
  Future<RewardedAd?> loadRewarded() async {
    try {
      await RewardedAd.load(
        adUnitId: AppConstants.adMobRewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            if (kDebugMode) debugPrint('Rewarded loaded');
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) debugPrint('Rewarded failed: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Load rewarded error: $e');
    }
    return _rewardedAd;
  }

  /// Show a rewarded ad and call callback when reward is earned
  Future<bool> showRewarded({
    required void Function(int amount, String type) onRewarded,
  }) async {
    if (_adsRemoved) {
      // Give a fake reward if ads are removed but user still wants to "watch"
      onRewarded(50, 'coins');
      return true;
    }
    if (_rewardedAd == null) {
      await loadRewarded();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (_rewardedAd == null) {
      return false;
    }
    try {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded(reward.amount.toInt(), reward.type);
        },
      );
      _lastRewardedShown = DateTime.now();
      _rewardedAd = null;
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Show rewarded error: $e');
      return false;
    }
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

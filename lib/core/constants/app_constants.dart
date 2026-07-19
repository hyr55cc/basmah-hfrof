/// App-wide constants and configuration
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'لغز الكلمات';
  static const String appNameEn = 'Arabic Word Puzzle';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Game rules
  static const int minWordLength = 3;
  static const int maxWordLength = 12;
  static const int maxLettersInCircle = 10;
  static const int minLettersInCircle = 4;

  // Coin rewards
  static const int coinsPerLevelComplete = 50;
  static const int coinsPerWord = 5;
  static const int coinsPerBonusWord = 10;
  static const int coinsPer20BonusWords = 100;
  static const int coinsDailyReward = 25;
  static const int coinsWeeklyReward = 200;
  static const int coinsMonthlyReward = 1000;

  // Hint costs
  static const int hintRevealLetterCost = 30;
  static const int hintRevealWordCost = 75;
  static const int hintShuffleCost = 25;
  static const int hintSkipLevelCost = 150;
  static const int hintRemoveWrongLetterCost = 50;

  // Starting values
  static const int startingCoins = 200;
  static const int startingHints = 5;
  static const int freeHintDaily = 2;

  // Daily reward
  static const int dailyRewardStreak = 7;
  static const int weeklyRewardStreak = 30;
  static const int monthlyRewardStreak = 365;

  // Level difficulty ranges
  static const int easyLevelRange = 100;
  static const int mediumLevelRange = 300;
  static const int hardLevelRange = 500;
  static const int expertLevelRange = 1000;

  // Cache
  static const String levelsCacheKey = 'levels_cache';
  static const String userDataCacheKey = 'user_data_cache';
  static const String dictionaryKey = 'arabic_dictionary';

  // Storage boxes (Hive)
  static const String settingsBox = 'settings_box';
  static const String userBox = 'user_box';
  static const String progressBox = 'progress_box';
  static const String levelsBox = 'levels_box';
  static const String achievementsBox = 'achievements_box';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String levelsCollection = 'levels';
  static const String achievementsCollection = 'achievements';
  static const String leaderboardCollection = 'leaderboard';
  static const String dailyRewardsCollection = 'daily_rewards';
  static const String eventsCollection = 'events';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';

  // Analytics events
  static const String eventLevelStart = 'level_start';
  static const String eventLevelComplete = 'level_complete';
  static const String eventLevelFail = 'level_fail';
  static const String eventWordFound = 'word_found';
  static const String eventBonusWord = 'bonus_word';
  static const String eventHintUsed = 'hint_used';
  static const String eventCoinEarned = 'coin_earned';
  static const String eventCoinSpent = 'coin_spent';
  static const String eventShopPurchase = 'shop_purchase';
  static const String eventAdWatched = 'ad_watched';
  static const String eventDailyReward = 'daily_reward';
  static const String eventAchievement = 'achievement';

  // Ad unit IDs (replace with real ones)
  static const String adMobBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String adMobInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String adMobRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String adMobAppOpenId =
      'ca-app-pub-3940256099942544/3419835294';

  // IAP product IDs
  static const String iapRemoveAds = 'remove_ads';
  static const String iapPremiumMonthly = 'premium_monthly';
  static const String iapPremiumYearly = 'premium_yearly';
  static const String iapCoinPack100 = 'coins_100';
  static const String iapCoinPack500 = 'coins_500';
  static const String iapCoinPack1000 = 'coins_1000';
  static const String iapCoinPack5000 = 'coins_5000';
  static const String iapHintPack = 'hints_pack';
  static const String iapStarterPack = 'starter_pack';

  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Rate limits
  static const int maxLevelAttemptsPerHour = 30;
  static const int maxWordSubmissionsPerMinute = 60;

  // Haptic intensities
  static const int lightHaptic = 20;
  static const int mediumHaptic = 50;
  static const int heavyHaptic = 100;
}

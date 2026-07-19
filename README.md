# 🎮 لغز الكلمات - Arabic Word Puzzle Game

A complete, production-ready Arabic word puzzle game built with Flutter, Clean Architecture, Riverpod, and Firebase. Arabic-first design, fully RTL, with comprehensive features for iOS, Android, and Web.

> **لعبة ألغاز الكلمات العربية** - اربط الحروف واكتشف الكلمات في مستويات لا نهائية

---

## ✨ Features

### 🎯 Core Game
- 🎲 **Unlimited levels** stored in Firestore - admin can add levels without app updates
- 🔤 **Drag-to-connect** letter mechanic with smooth line drawing
- 📚 **Comprehensive Arabic dictionary** with normalization (أ، إ، آ → ا) and diacritics removal
- 🌟 **Bonus words** - find hidden words to earn extra rewards
- ⭐ **3-star rating** system based on word count
- 🏆 **Achievement system** with 20+ achievements
- 📊 **Global leaderboards** (highest level, coins, bonus words, speed)
- 💰 **Coin economy** with daily rewards, achievements, and rewarded ads

### 🔐 Authentication
- 👤 **Guest mode** - play without signing in
- 🔵 **Google Sign-In**
- 🍎 **Apple Sign-In**
- 📧 **Email & Password** with full account management
- 🔒 **Secure session management** via Firebase Auth

### 💎 Premium Features
- 🚫 **Remove ads** purchase
- 👑 **Premium membership** (monthly/yearly) with exclusive benefits
- 💵 **Coin packs** (100, 500, 1K, 5K)
- 💡 **Hint packs**
- 🎁 **Starter pack** (limited offer)

### 💡 Hint System
- 🔍 Reveal a letter
- 📖 Reveal a full word
- 🔀 Shuffle letters
- ⏭️ Skip level
- ❌ Remove a wrong letter

### 🎁 Daily Rewards
- 📅 **7-day streak** with increasing rewards
- 📆 **Weekly rewards**
- 🗓️ **Monthly rewards**
- 🎬 **Watch rewarded ads** for bonus coins

### 🛍️ Shop & IAP
- 🛒 Full shop with consumables, subscriptions, and one-time purchases
- 🍎 **StoreKit** integration
- 🤖 **Google Play Billing** integration
- ♻️ **Restore purchases**

### 📢 Ads (AdMob)
- 📱 Banner ads
- 📺 Interstitial ads (with frequency control)
- 🎬 Rewarded video ads
- 🚪 App open ads

### 🔔 Notifications (FCM)
- 📅 Daily reminder
- 🎁 Reward notifications
- 🎉 Special events
- 📢 Admin push broadcasts

### 🛠️ Admin Dashboard (Flutter Web)
- 📊 Analytics dashboard with charts
- 🎮 Level management (CRUD)
- 👥 User management (ban, coins, levels)
- 🔔 Push notifications
- 💰 Revenue tracking
- 📈 Funnel analytics

### 🎨 UI/UX
- ✨ **Glassmorphism** design
- 🌈 Beautiful gradients
- 📱 Responsive (mobile + tablet)
- 🌓 Light & Dark mode
- 🎭 Smooth animations (60 FPS)
- 🔄 Smooth page transitions
- 💥 Particle effects
- 🎊 Confetti celebrations
- 📳 Haptic feedback
- 🔊 Sound effects
- 🌐 **100% Arabic** with full RTL

### ⚡ Performance
- 🚀 60 FPS animations
- 💾 Offline mode with auto-sync
- 🗄️ Hive local storage
- 🌐 Dio HTTP client with retry
- 🖼️ Cached images
- 🔄 Lazy loading
- 📦 Optimized rebuilds

### 🧪 Testing
- ✅ Unit tests
- 🧩 Widget tests
- 🔄 Integration tests

---

## 🏗️ Architecture

Clean Architecture with strict separation of concerns:

```
lib/
├── core/                   # Core utilities, theme, constants
│   ├── constants/          # App-wide constants
│   ├── errors/             # Exceptions & failures
│   ├── network/            # API client
│   ├── theme/              # Theme, colors, text styles
│   ├── widgets/            # Reusable widgets
│   ├── router/             # GoRouter configuration
│   ├── di/                 # Dependency injection
│   ├── extensions/         # Dart extensions
│   ├── helpers/            # Arabic text helper, dictionary
│   └── responsive/         # Responsive sizing
├── domain/                 # Business logic (pure Dart)
│   ├── entities/           # Domain models
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases
├── data/                   # Data layer
│   ├── datasources/        # Remote (Firebase) + Local (Hive)
│   ├── models/             # Data models with serialization
│   └── repositories/       # Repository implementations
├── services/               # Cross-cutting services
│   ├── firebase/
│   ├── ads/
│   ├── iap/
│   ├── notifications/
│   ├── audio/
│   ├── haptics/
│   ├── analytics/
│   └── storage/
├── features/               # Feature-based modules
│   ├── auth/
│   ├── home/
│   ├── game/               # Game engine + UI
│   ├── levels/
│   ├── profile/
│   ├── shop/
│   ├── leaderboard/
│   ├── settings/
│   ├── daily_reward/
│   ├── achievements/
│   └── premium/
├── app.dart                # Root MaterialApp
├── main.dart               # Entry point
└── firebase_options.dart   # Firebase configuration

admin/                      # Admin web dashboard
├── lib/
│   ├── features/
│   │   ├── dashboard/
│   │   ├── levels/
│   │   ├── users/
│   │   ├── analytics/
│   │   ├── notifications/
│   │   ├── revenue/
│   │   └── auth/
│   └── ...

functions/                  # Cloud Functions
└── src/index.ts

assets/
├── dictionary/             # Arabic word list
├── fonts/                  # Arabic fonts
├── images/                 # Image assets
├── sounds/                 # Sound effects
├── animations/             # Lottie animations
└── data/                   # Static data
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.19.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart SDK `>=3.3.0`
- Firebase CLI ([Install](https://firebase.google.com/docs/cli))
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Android Studio / Xcode for builds

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/arabic-word-puzzle.git
cd arabic-word-puzzle
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Firebase

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android, iOS, and Web apps to your project
3. Install FlutterFire CLI and configure:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will generate the `lib/firebase_options.dart` file with your real credentials.

### 4. Download Arabic Fonts

```bash
# See assets/fonts/README.md for download links
# Cairo, Tajawal, and Amiri fonts
```

Or use the bash script:

```bash
cd assets/fonts
curl -L -o Cairo-Regular.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Regular.ttf
curl -L -o Cairo-Bold.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Bold.ttf
curl -L -o Cairo-SemiBold.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-SemiBold.ttf
curl -L -o Cairo-Medium.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Medium.ttf
curl -L -o Cairo-Light.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Light.ttf

curl -L -o Tajawal-Regular.ttf https://github.com/googlefonts/tajawal/raw/main/fonts/ttf/Tajawal-Regular.ttf
curl -L -o Tajawal-Bold.ttf https://github.com/googlefonts/tajawal/raw/main/fonts/ttf/Tajawal-Bold.ttf
curl -L -o Tajawal-Medium.ttf https://github.com/googlefonts/tajawal/raw/main/fonts/ttf/Tajawal-Medium.ttf

curl -L -o Amiri-Regular.ttf https://github.com/aliftype/amiri/raw/main/Amiri-Regular.ttf
curl -L -o Amiri-Bold.ttf https://github.com/aliftype/amiri/raw/main/Amiri-Bold.ttf
```

### 5. Expand Arabic Dictionary (Optional)

The starter dictionary contains ~1,000 common words. For production, expand to 300,000+ words following the guide in `assets/dictionary/README.md`.

### 6. Configure AdMob (Optional)

Update the AdMob unit IDs in `lib/core/constants/app_constants.dart`:

```dart
static const String adMobBannerId = 'ca-app-pub-YOUR_ADMOB_BANNER_ID';
static const String adMobInterstitialId = 'ca-app-pub-YOUR_INTERSTITIAL_ID';
static const String adMobRewardedId = 'ca-app-pub-YOUR_REWARDED_ID';
```

The default values are Google's test IDs (safe for development).

### 7. Configure IAP

Add your product IDs to `lib/core/constants/app_constants.dart`. Then create matching products in App Store Connect and Google Play Console.

### 8. Run the App

```bash
# Development
flutter run

# iOS simulator
flutter run -d ios

# Android emulator
flutter run -d android

# Web
flutter run -d web
```

---

## 🏗️ Building for Production

### Android

```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Edit android/key.properties with your keystore details
# Then build:
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

### iOS

```bash
# Configure in Xcode
open ios/Runner.xcworkspace

# Set up signing & capabilities
# Then build:
flutter build ipa --release
```

### Web

```bash
flutter build web --release
# Output: build/web/
```

### Admin Dashboard

```bash
cd admin
flutter pub get
flutter build web --release
# Output: admin/build/web/
```

### Cloud Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### Deploy Everything

```bash
firebase deploy
```

---

## 📱 Screenshots

| Home | Game | Level Map | Daily Reward |
|------|------|-----------|--------------|
| TBD  | TBD  | TBD       | TBD          |

| Profile | Shop | Leaderboard | Settings |
|---------|------|-------------|----------|
| TBD     | TBD  | TBD         | TBD      |

---

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🔒 Security

- Firestore security rules in `firestore.rules`
- Storage security rules in `storage.rules`
- App Check integration (Play Integrity, App Attest, reCAPTCHA v3)
- Encrypted local storage via `flutter_secure_storage`
- No sensitive data in client code
- Admin-only operations enforced by Cloud Functions

---

## 🌍 Arabic-First Design

- ✅ Full RTL layout
- ✅ Arabic fonts only (Cairo, Tajawal, Amiri)
- ✅ Arabic word dictionary
- ✅ Letter normalization (أ، إ، آ → ا)
- ✅ Diacritics removal (التشكيل)
- ✅ Native Arabic numerals display
- ✅ 100% Arabic UI text (no English)
- ✅ All animations and layouts optimized for RTL

---

## 📝 Adding Levels

Levels are stored in Firestore at the `levels` collection. Each level document has:

```json
{
  "id": 87,
  "level": 87,
  "letters": ["ا", "ل", "ع", "خ", "ت", "ا"],
  "answers": ["العلم", "تعلم", "لعبة", "..."],
  "bonusWords": ["علم", "تخت"],
  "difficulty": "medium",
  "rewardCoins": 50,
  "hintLetterIndices": [],
  "maxAttempts": 0,
  "timeLimitSeconds": 0,
  "requiredWords": 0,
  "createdAt": "2026-07-19T00:00:00Z"
}
```

You can add levels via:
1. Admin dashboard (UI)
2. Firebase Console (Firestore UI)
3. Cloud Function (bulk import)
4. Admin SDK script

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Riverpod for state management
- All open-source font and library contributors

---

## 📞 Contact & Support

- 📧 Email: support@arabicwordpuzzle.com
- 🐛 Issues: [GitHub Issues](https://github.com/YOUR_USERNAME/arabic-word-puzzle/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/YOUR_USERNAME/arabic-word-puzzle/discussions)
- 🌐 Website: https://arabicwordpuzzle.com

---

<p align="center">
صنع بـ ❤️ للغة العربية
<br>
Made with ❤️ for the Arabic language
</p>

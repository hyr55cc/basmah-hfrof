import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import '../../models/level_model.dart';
import '../../models/achievement_model.dart';
import '../../models/leaderboard_model.dart';
import '../../models/shop_model.dart';

/// Centralized Firebase access layer
/// Wraps all Firebase operations in one place
class FirebaseDatasource {
  FirebaseDatasource();

  // ============================================================
  // Firebase instances
  // ============================================================

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // ============================================================
  // Auth operations
  // ============================================================

  Stream<fb_auth.User?> get authStateChanges => auth.authStateChanges();

  fb_auth.User? get currentFirebaseUser => auth.currentUser;

  Future<UserModel?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> getUserStream(String userId) {
    return firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<fb_auth.UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('تم إلغاء تسجيل الدخول');
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await auth.signInWithCredential(credential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    }
  }

  Future<fb_auth.UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = fb_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      return await auth.signInWithCredential(oauthCredential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException(e.message, e.code.name);
    }
  }

  Future<fb_auth.UserCredential> signInAnonymously() async {
    try {
      return await auth.signInAnonymously();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    }
  }

  Future<fb_auth.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    }
  }

  Future<fb_auth.UserCredential> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      auth.signOut(),
      googleSignIn.signOut(),
    ]);
  }

  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) return;
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();
      await user.delete();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    }
  }

  // ============================================================
  // User operations
  // ============================================================

  Future<void> createUserDocument(UserModel user) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUserDocument(UserModel user) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<List<UserModel>> getAllUsers({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل المستخدمين: $e');
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل البحث عن المستخدمين: $e');
    }
  }

  Future<void> banUser(String userId, {String? reason}) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'isBanned': true,
      'banReason': reason,
      'bannedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Level operations
  // ============================================================

  Future<LevelModel?> getLevel(int levelId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.levelsCollection)
          .doc(levelId.toString())
          .get();
      if (!doc.exists) return null;
      return LevelModel.fromMap(doc.data()!);
    } catch (e) {
      throw ServerException('فشل تحميل المستوى: $e');
    }
  }

  Future<List<LevelModel>> getLevelsPaginated({
    int? lastLevelId,
    int limit = 20,
  }) async {
    try {
      var query = firestore
          .collection(AppConstants.levelsCollection)
          .orderBy('id')
          .limit(limit);
      if (lastLevelId != null) {
        query = query.startAfter([lastLevelId]);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => LevelModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل المستويات: $e');
    }
  }

  Future<List<LevelModel>> getLevelRange({
    required int start,
    required int end,
  }) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.levelsCollection)
          .where('id', isGreaterThanOrEqualTo: start)
          .where('id', isLessThanOrEqualTo: end)
          .orderBy('id')
          .get();
      return snapshot.docs
          .map((doc) => LevelModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل نطاق المستويات: $e');
    }
  }

  Future<void> upsertLevel(LevelModel level) async {
    await firestore
        .collection(AppConstants.levelsCollection)
        .doc(level.id.toString())
        .set(level.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteLevel(int levelId) async {
    await firestore
        .collection(AppConstants.levelsCollection)
        .doc(levelId.toString())
        .delete();
  }

  // ============================================================
  // Level progress
  // ============================================================

  Future<Map<int, LevelProgressModel>> getAllLevelProgress(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('level_progress')
          .get();
      final result = <int, LevelProgressModel>{};
      for (final doc in snapshot.docs) {
        final progress = LevelProgressModel.fromMap(doc.data());
        result[progress.levelId] = progress;
      }
      return result;
    } catch (e) {
      throw ServerException('فشل تحميل تقدم المستويات: $e');
    }
  }

  Future<LevelProgressModel?> getLevelProgress(
    String userId,
    int levelId,
  ) async {
    try {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('level_progress')
          .doc(levelId.toString())
          .get();
      if (!doc.exists) return null;
      return LevelProgressModel.fromMap(doc.data()!);
    } catch (e) {
      throw ServerException('فشل تحميل تقدم المستوى: $e');
    }
  }

  Future<void> saveLevelProgress(
    String userId,
    LevelProgressModel progress,
  ) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('level_progress')
        .doc(progress.levelId.toString())
        .set(progress.toMap());
  }

  Stream<Map<int, LevelProgressModel>> progressStream(String userId) {
    return firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('level_progress')
        .snapshots()
        .map((snapshot) {
      final result = <int, LevelProgressModel>{};
      for (final doc in snapshot.docs) {
        final progress = LevelProgressModel.fromMap(doc.data());
        result[progress.levelId] = progress;
      }
      return result;
    });
  }

  // ============================================================
  // Leaderboard operations
  // ============================================================

  Future<List<LeaderboardEntryModel>> getLeaderboard({
    required String collection,
    int limit = 100,
  }) async {
    try {
      final snapshot = await firestore
          .collection(collection)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();
      final entries = <LeaderboardEntryModel>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        entries.add(LeaderboardEntryModel.fromMap({
          ...doc.data(),
          'rank': i + 1,
        }));
      }
      return entries;
    } catch (e) {
      throw ServerException('فشل تحميل لوحة المتصدرين: $e');
    }
  }

  Future<void> submitLeaderboardEntry({
    required String collection,
    required String userId,
    required String displayName,
    required int score,
    String? photoUrl,
    String? country,
  }) async {
    await firestore.collection(collection).doc(userId).set({
      'userId': userId,
      'displayName': displayName,
      'score': score,
      'photoUrl': photoUrl,
      'country': country,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetLeaderboard(String collection) async {
    final snapshot = await firestore.collection(collection).get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ============================================================
  // Achievement operations
  // ============================================================

  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.achievementsCollection)
          .get();
      return snapshot.docs
          .map((doc) => AchievementModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل الإنجازات: $e');
    }
  }

  Future<List<AchievementProgressModel>> getAchievementProgress(
    String userId,
  ) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('achievement_progress')
          .get();
      return snapshot.docs
          .map((doc) => AchievementProgressModel.fromMap(
                doc.data(),
                AchievementModel(
                  id: doc.data()['achievementId'] as String? ?? '',
                  title: '',
                  description: '',
                  type: AchievementType.special,
                  target: 0,
                  rewardCoins: 0,
                ),
              ))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل تقدم الإنجازات: $e');
    }
  }

  Future<void> saveAchievementProgress(
    String userId,
    AchievementProgressModel progress,
  ) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('achievement_progress')
        .doc(progress.achievement.id)
        .set(progress.toMap());
  }

  // ============================================================
  // Shop operations
  // ============================================================

  Future<List<ShopItemModel>> getShopItems() async {
    try {
      final snapshot = await firestore.collection('shop_items').get();
      return snapshot.docs
          .map((doc) => ShopItemModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل المتجر: $e');
    }
  }

  Future<List<DailyRewardModel>> getDailyRewards() async {
    try {
      final snapshot = await firestore
          .collection('daily_rewards')
          .orderBy('day')
          .get();
      return snapshot.docs
          .map((doc) => DailyRewardModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('فشل تحميل المكافآت اليومية: $e');
    }
  }

  Future<void> recordPurchase({
    required String userId,
    required String productId,
    required String transactionId,
    required double amount,
    required String currency,
  }) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('purchases')
        .doc(transactionId)
        .set({
      'productId': productId,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'purchasedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Cloud Functions
  // ============================================================

  Future<Map<String, dynamic>> callFunction(
    String name,
    Map<String, dynamic> params,
  ) async {
    try {
      // Cloud functions can be called via https callable
      // For now, fall back to direct firestore
      // final result = await FirebaseFunctions.instance.httpsCallable(name).call(params);
      // return result.data as Map<String, dynamic>;
      return <String, dynamic>{};
    } catch (e) {
      throw ServerException('فشل استدعاء الوظيفة: $e');
    }
  }

  // ============================================================
  // Analytics
  // ============================================================

  Future<void> logEvent(String name, Map<String, dynamic> params) async {
    // Analytics should be handled by AnalyticsService
    // This is a placeholder if we need server-side logging
  }

  // ============================================================
  // Utility
  // ============================================================

  String _mapAuthError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'بريد إلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'كثرة المحاولات. حاول لاحقًا';
      case 'operation-not-allowed':
        return 'العملية غير مسموح بها';
      case 'requires-recent-login':
        return 'يحتاج لتسجيل دخول حديث';
      default:
        return e.message ?? 'خطأ في المصادقة';
    }
  }
}

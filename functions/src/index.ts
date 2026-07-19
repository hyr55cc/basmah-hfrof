import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * Validate IAP receipt (callable)
 */
export const validateReceipt = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required");
  }
  const {productId, transactionId, receiptData} = data;

  // TODO: Verify receipt with Apple/Google
  // For now, trust the receipt
  await db
    .collection("users")
    .doc(context.auth.uid)
    .collection("purchases")
    .doc(transactionId)
    .set({
      productId,
      transactionId,
      receiptData,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  return {success: true};
});

/**
 * Process level completion - awards coins, updates progress
 */
export const onLevelComplete = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required");
  }
  const {levelId, timeSpent, wordsFound, stars} = data;
  const userId = context.auth.uid;

  const userRef = db.collection("users").doc(userId);
  const levelRef = db.collection("levels").doc(String(levelId));

  const [userSnap, levelSnap] = await Promise.all([
    userRef.get(),
    levelRef.get(),
  ]);

  if (!levelSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Level not found");
  }
  const level = levelSnap.data()!;
  const baseReward = level.rewardCoins || 50;
  const timeBonus = Math.max(0, 30 - Math.floor(timeSpent / 10));
  const starBonus = stars * 25;
  const totalReward = baseReward + timeBonus + starBonus;

  await db.runTransaction(async (tx) => {
    const user = userSnap.data() || {};
    const newCoins = (user.coins || 0) + totalReward;
    const newLevel = Math.max(user.currentLevel || 1, levelId + 1);
    const newMax = Math.max(user.maxUnlockedLevel || 1, levelId + 1);

    tx.update(userRef, {
      coins: newCoins,
      currentLevel: newLevel,
      maxUnlockedLevel: newMax,
      totalScore: (user.totalScore || 0) + totalReward,
      totalWordsFound: (user.totalWordsFound || 0) + (wordsFound || 0),
    });

    tx.set(
      userRef.collection("level_progress").doc(String(levelId)),
      {
        completed: true,
        timeSpentSeconds: timeSpent,
        stars,
        coinsEarned: totalReward,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
  });

  return {coinsEarned: totalReward};
});

/**
 * Process watched rewarded ad
 */
export const onRewardedAd = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required");
  }
  const {adType, rewardAmount = 25} = data;
  const userId = context.auth.uid;

  await db.collection("users").doc(userId).update({
    coins: admin.firestore.FieldValue.increment(rewardAmount),
  });

  return {success: true, rewardAmount};
});

/**
 * Daily cron: reset daily leaderboards
 */
export const dailyLeaderboardReset = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    const collections = [
      "leaderboard_levels_daily",
      "leaderboard_coins_daily",
      "leaderboard_bonus_daily",
      "leaderboard_words_daily",
    ];
    for (const col of collections) {
      const snap = await db.collection(col).get();
      const batch = db.batch();
      snap.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
    return null;
  });

/**
 * On user created: initialize user doc
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  await db.collection("users").doc(user.uid).set(
    {
      id: user.uid,
      email: user.email || "guest@anonymous.app",
      displayName: user.displayName || "لاعب",
      photoUrl: user.photoURL,
      isAnonymous: user.providerData.length === 0,
      coins: 200,
      hints: 5,
      currentLevel: 1,
      maxUnlockedLevel: 1,
      totalScore: 0,
      totalWordsFound: 0,
      totalBonusWords: 0,
      achievements: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true},
  );
});

/**
 * Ban user (admin only)
 */
export const banUser = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Admin only",
    );
  }
  const {userId, reason} = data;
  await db.collection("users").doc(userId).update({
    isBanned: true,
    banReason: reason,
    bannedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return {success: true};
});

/**
 * Send push notification to all users
 */
export const sendBroadcast = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Admin only",
    );
  }
  const {title, body, topic = "all_users"} = data;
  await admin.messaging().send({
    topic,
    notification: {title, body},
  });
  return {success: true};
});

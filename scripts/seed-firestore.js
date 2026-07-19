// Upload levels.json to Firestore using a Firebase service account.
//
// Usage:
//   1. Go to Firebase Console > Project Settings > Service Accounts
//   2. Click "Generate new private key" and download the JSON file
//   3. Save it as scripts/service-account.json
//   4. Run: node scripts/seed-firestore.js [levels-file=scripts/levels.json]
//
// This uses the Admin SDK to bypass the security rules and write directly.
// In production, you'd use a Cloud Function triggered by an admin action.

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const LEVELS_FILE = process.argv[2] || path.join(__dirname, 'levels.json');
const SERVICE_ACCOUNT = path.join(__dirname, 'service-account.json');

if (!fs.existsSync(SERVICE_ACCOUNT)) {
  console.error(`\nERROR: Service account file not found at ${SERVICE_ACCOUNT}\n`);
  console.error('To create one:');
  console.error('  1. Go to https://console.firebase.google.com/project/basmah-hrof/settings/serviceaccounts/adminsdk');
  console.error('  2. Click "Generate new private key"');
  console.error('  3. Save the JSON file as: scripts/service-account.json');
  console.error('  4. Re-run this script\n');
  console.error('Alternatively, use the Firebase Console UI to add levels manually.');
  process.exit(1);
}

if (!fs.existsSync(LEVELS_FILE)) {
  console.error(`Levels file not found: ${LEVELS_FILE}`);
  console.error('Run first: node scripts/generate-levels.js');
  process.exit(1);
}

const serviceAccount = JSON.parse(fs.readFileSync(SERVICE_ACCOUNT, 'utf8'));
const levels = JSON.parse(fs.readFileSync(LEVELS_FILE, 'utf8'));

console.log(`Loaded ${levels.length} levels from ${LEVELS_FILE}`);
console.log(`Using service account: ${serviceAccount.project_id}`);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function upload() {
  console.log('Uploading to Firestore...');

  // Use batched writes (max 500 per batch)
  const BATCH_SIZE = 400;
  let uploaded = 0;
  let errors = 0;

  for (let i = 0; i < levels.length; i += BATCH_SIZE) {
    const batch = db.batch();
    const slice = levels.slice(i, i + BATCH_SIZE);

    for (const lvl of slice) {
      const docId = String(lvl.id);
      const ref = db.collection('levels').doc(docId);
      // Strip the level.id field before upload (Firestore doc id is the id)
      const data = { ...lvl };
      // Convert ISO string to Firestore Timestamp
      if (data.createdAt) {
        data.createdAt = admin.firestore.Timestamp.fromDate(new Date(data.createdAt));
      }
      batch.set(ref, data, { merge: true });
    }

    try {
      await batch.commit();
      uploaded += slice.length;
      console.log(`  Uploaded ${uploaded}/${levels.length}...`);
    } catch (e) {
      errors++;
      console.error(`  Batch failed (${i}-${i + slice.length}):`, e.message);
    }
  }

  console.log(`\nDone! ${uploaded} levels uploaded, ${errors} batch errors.`);
  if (errors === 0) {
    console.log('View them at: https://console.firebase.google.com/project/basmah-hrof/firestore/data/~2Flevels');
  }

  process.exit(errors > 0 ? 1 : 0);
}

upload().catch((e) => {
  console.error('Fatal:', e);
  process.exit(1);
});

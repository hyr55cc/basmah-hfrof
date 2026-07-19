# Firestore Seeding Scripts

Scripts to populate the Firestore database with Arabic word puzzle levels.

## What they do

1. **`generate-levels.js`** — Generates valid level data from the bundled Arabic dictionary
   - Picks real dictionary words as anchors
   - Adds random letters to form a circle of 5-7 letters
   - Finds all dictionary words that can be formed from those letters
   - Tags each level with difficulty (easy/medium/hard/expert)
   - Awards coins based on difficulty

2. **`seed-firestore.js`** — Uploads `levels.json` to Firestore
   - Uses Firebase Admin SDK (bypasses security rules)
   - Batched writes (400 docs per batch)
   - Skips already-existing levels (idempotent)

## Setup (one-time)

### 1. Install the Firebase Admin SDK

```powershell
Set-Location "C:\Users\lamar\.mavis\agents\coder\workspace\arabic_word_puzzle"
npm install firebase-admin
```

### 2. Get a service account key from Firebase

1. Open https://console.firebase.google.com/project/basmah-hrof/settings/serviceaccounts/adminsdk
2. Click **"Generate new private key"**
3. A JSON file downloads
4. Rename it to `service-account.json` and put it in the `scripts/` folder
5. **Do NOT commit this file to git!** (It's already in `.gitignore`)

### 3. Generate the levels JSON

```powershell
node scripts/generate-levels.js 50 scripts/levels.json
```

Output: `scripts/levels.json` with 50 levels.

### 4. Upload to Firestore

```powershell
node scripts/seed-firestore.js scripts/levels.json
```

This pushes all levels to the `levels` collection in Firestore.

## Verify

Open https://console.firebase.google.com/project/basmah-hrof/firestore/data/~2Flevels

You should see 50+ documents with the level data.

## Customize

### Generate more or fewer levels

```powershell
node scripts/generate-levels.js 200 scripts/levels.json  # 200 levels
```

### Add levels later

Just re-run. The script uses `merge: true` so existing levels won't be duplicated.

### Edit the difficulty formula

Open `scripts/generate-levels.js` and look for the `difficultyFor` function:

```js
function difficultyFor(letters, answerCount, maxWordLen) {
  if (letters.length <= 5 && answerCount <= 4 && maxWordLen <= 4) return 'easy';
  // ... tweak thresholds
}
```

## Output format

```json
[
  {
    "id": 1,
    "level": 1,
    "letters": ["ق", "ا", "ك", "ض", "ب", "ت"],
    "answers": ["كاتب", "كتاب", "كتب", "قبض"],
    "bonusWords": [],
    "difficulty": "medium",
    "rewardCoins": 50,
    "timeLimitSeconds": 0,
    "maxAttempts": 0,
    "requiredWords": 0
  }
]
```

The Flutter app reads these fields and renders the puzzle.

## Security note

The `service-account.json` file has admin-level access to your Firebase project. Treat it like a password. It's already in the project's `.gitignore` — never commit it.

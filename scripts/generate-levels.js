// Generate valid Arabic word puzzle levels from the bundled dictionary.
//
// Strategy: start from existing dictionary words as "anchors" and build
// levels around their letters. This guarantees every level is solvable.
//
// Usage:
//   node scripts/generate-levels.js [count=50] [output=scripts/levels.json]
//
// Output: JSON array of levels, each with letters, answers, bonusWords.

const fs = require('fs');
const path = require('path');

const COUNT = parseInt(process.argv[2] || '50', 10);
const OUT = process.argv[3] || path.join(__dirname, 'levels.json');

const NORMALIZE = {
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
  'ة': 'ه', 'ى': 'ي', 'ؤ': 'و', 'ئ': 'ي',
};

function normalize(s) {
  let out = '';
  for (const c of s) {
    out += NORMALIZE[c] || c;
  }
  return out.replace(/[\u064B-\u0652\u0670\u0640]/g, '');
}

function letterCount(s) {
  const m = {};
  for (const c of s) m[c] = (m[c] || 0) + 1;
  return m;
}

function canForm(word, letters) {
  const avail = letterCount(letters);
  const need = letterCount(word);
  for (const k in need) {
    if ((avail[k] || 0) < need[k]) return false;
  }
  return true;
}

function pickRandom(arr, count) {
  const copy = arr.slice();
  const result = [];
  while (copy.length > 0 && result.length < count) {
    const idx = Math.floor(Math.random() * copy.length);
    result.push(copy.splice(idx, 1)[0]);
  }
  return result;
}

function shuffle(arr) {
  const copy = arr.slice();
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function difficultyFor(letters, answerCount, maxWordLen) {
  if (letters.length <= 5 && answerCount <= 4 && maxWordLen <= 4) return 'easy';
  if (letters.length <= 6 && answerCount <= 5 && maxWordLen <= 5) return 'medium';
  if (letters.length <= 7 && answerCount <= 6 && maxWordLen <= 6) return 'hard';
  return 'expert';
}

function rewardFor(difficulty) {
  switch (difficulty) {
    case 'easy': return 30;
    case 'medium': return 50;
    case 'hard': return 80;
    case 'expert': return 120;
    default: return 50;
  }
}

// Load dictionary
const dictPath = path.join(__dirname, '..', 'assets', 'dictionary', 'arabic_words.txt');
const rawDict = fs.readFileSync(dictPath, 'utf8');
const wordSet = new Set();
for (const line of rawDict.split('\n')) {
  const t = line.trim();
  if (!t || t.startsWith('#')) continue;
  const n = normalize(t);
  if (n.length >= 3) wordSet.add(n);
}
const allWords = Array.from(wordSet);
console.log(`Loaded ${allWords.length} unique Arabic words`);

// Group by length for efficient lookup
const byLength = {};
for (const w of allWords) {
  (byLength[w.length] || (byLength[w.length] = [])).push(w);
}

function findFormable(letters, minLen = 3, maxLen = 7) {
  const result = [];
  for (let len = minLen; len <= maxLen; len++) {
    for (const w of (byLength[len] || [])) {
      if (canForm(w, letters)) result.push(w);
    }
  }
  return result;
}

// Group words by their letter signature for faster level building
const bySignature = {};
for (const w of allWords) {
  const sig = w.split('').sort().join('');
  (bySignature[sig] || (bySignature[sig] = [])).push(w);
}

// Pick anchor words to build levels from
// (We want words that share enough letters with other dictionary words)
const anchorCandidates = allWords
  .filter(w => w.length >= 4 && w.length <= 6)
  .sort(() => Math.random() - 0.5);

const usedSignatures = new Set();
const levels = [];
let levelId = 1;

for (const anchor of anchorCandidates) {
  if (levels.length >= COUNT) break;

  // Build letter set from the anchor word
  const letterSet = new Set(anchor);
  // Add 1-2 more random letters to expand the puzzle
  const arabicLetters = 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي';
  const extras = pickRandom(Array.from(arabicLetters).filter(c => !letterSet.has(c)), 1 + Math.floor(Math.random() * 2));
  for (const c of extras) letterSet.add(c);
  const letters = shuffle(Array.from(letterSet));

  // Find all formable words
  const formable = findFormable(letters);
  if (formable.length < 4) continue;

  // Skip if signature (sorted letters) is too similar to existing levels
  const sig = letters.slice().sort().join('');
  if (usedSignatures.has(sig)) continue;

  // Pick answers: prefer longer, more interesting words
  const sorted = formable.slice().sort((a, b) => b.length - a.length);
  const numAnswers = Math.min(sorted.length, 3 + Math.floor(Math.random() * 3));
  const answers = sorted.slice(0, numAnswers);

  // Bonus words: next 2-3 longest
  const bonus = sorted.slice(numAnswers, numAnswers + 2 + Math.floor(Math.random() * 2));

  const maxLen = Math.max(...answers.map(w => w.length));
  const difficulty = difficultyFor(letters, answers.length, maxLen);

  levels.push({
    id: levelId,
    level: levelId,
    letters,
    answers,
    bonusWords: bonus,
    difficulty,
    rewardCoins: rewardFor(difficulty),
    timeLimitSeconds: 0,
    maxAttempts: 0,
    requiredWords: 0,
    createdAt: new Date().toISOString(),
  });

  usedSignatures.add(sig);
  levelId++;
}

fs.writeFileSync(OUT, JSON.stringify(levels, null, 2), 'utf8');

console.log(`\nGenerated ${levels.length} levels -> ${OUT}`);
const byDiff = {};
for (const l of levels) byDiff[l.difficulty] = (byDiff[l.difficulty] || 0) + 1;
console.log('By difficulty:', byDiff);

// Show first 3 levels as preview
console.log('\n--- First 3 levels preview ---');
for (const l of levels.slice(0, 3)) {
  console.log(`Level ${l.id} (${l.difficulty}):`);
  console.log(`  Letters: ${l.letters.join(' ')}`);
  console.log(`  Answers: ${l.answers.join(', ')}`);
  console.log(`  Bonus:   ${l.bonusWords.join(', ')}`);
  console.log(`  Reward:  ${l.rewardCoins} coins\n`);
}

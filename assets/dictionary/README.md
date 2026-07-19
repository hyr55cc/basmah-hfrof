# Arabic Dictionary Assets

This directory contains the Arabic word dictionary used by the game.

## Files

### `arabic_words.txt`
The main word list. Format: one word per line, lines starting with `#` are comments.

### `arabic_words.json`
JSON format alternative (list of words, optionally with scores).

## Expanding to 300,000+ words

The starter dictionary bundled with this project contains ~500-1,000 of the most common Arabic words. To expand to 300,000+ words for production, follow these steps:

### Step 1: Get a comprehensive word list

Recommended sources:

1. **Arabic Wikipedia dump** (https://dumps.wikimedia.org/arwiki/)
   - Extract all unique words from article text
   - Filter to 3+ letter words
   - ~500,000+ unique words

2. **AraComLex** (https://sourceforge.net/projects/aracometry/)
   - ~150,000 lemmatized Arabic words

3. **Almanach Hackathon Arabic Dictionary**
   - 600,000+ Arabic words on GitHub

4. **Buckwalter Arabic Morphological Analyzer**
   - https://www.ldc.upenn.edu/LDC2010T01
   - Commercial but very comprehensive

5. **List of Arabic words on Wikipedia**:
   - https://en.wikipedia.org/wiki/List_of_Arabic_words

### Step 2: Clean and normalize

Use the project's `ArabicTextHelper.normalize()` to clean the data:

```dart
import 'package:arabic_word_puzzle/core/helpers/arabic_text_helper.dart';

String cleanWord(String word) {
  final normalized = ArabicTextHelper.normalize(word);
  if (normalized.length < 2) return '';
  if (!ArabicTextHelper.isArabic(normalized)) return '';
  return normalized;
}
```

### Step 3: Generate the dictionary file

Create a script like this (Dart):

```dart
import 'dart:io';

void main() async {
  final source = File('source_words.txt').readAsLinesSync();
  final words = <String>{};
  for (final line in source) {
    final word = cleanWord(line.trim());
    if (word.isNotEmpty) words.add(word);
  }
  final sorted = words.toList()..sort();
  await File('assets/dictionary/arabic_words.txt')
      .writeAsString(sorted.join('\n'));
  print('Generated ${words.length} unique words');
}
```

Or use the Python equivalent:

```python
import re

with open('source_words.txt', 'r', encoding='utf-8') as f:
    source = f.read()

# Remove diacritics
source = re.sub(r'[\u064B-\u0652\u0670\u0640]', '', source)
# Normalize alef
source = source.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا')
# Normalize taa marbuta
source = source.replace('ة', 'ه')
# Normalize alef maqsura
source = source.replace('ى', 'ي')

# Extract Arabic words (3+ letters)
words = set()
for match in re.finditer(r'[\u0600-\u06FF]{3,}', source):
    words.add(match.group())

with open('assets/dictionary/arabic_words.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sorted(words)))

print(f'Generated {len(words)} unique words')
```

### Step 4: Add to project

Copy the generated `arabic_words.txt` to this directory. The dictionary loader (`lib/core/helpers/arabic_dictionary.dart`) will load it on app start.

## Performance Considerations

- 300,000 words × ~30 chars = ~9MB raw text
- Compressed in memory: ~10-15MB
- Loading takes ~2-3 seconds
- O(1) lookup time via HashSet

For very large dictionaries (1M+), consider:
- Memory-mapped files
- Compressed bloom filters
- Server-side validation via Cloud Functions

## License Notes

Make sure the word list you use is properly licensed for your use case.
Wikipedia-derived lists are CC-BY-SA. Commercial dictionaries may have
licensing requirements.

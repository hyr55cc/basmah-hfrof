/// Utility class for Arabic text processing
/// Handles normalization, diacritics removal, and letter detection
class ArabicTextHelper {
  ArabicTextHelper._();

  // Arabic Unicode range: U+0600 to U+06FF
  static const int _arabicStart = 0x0600;
  static const int _arabicEnd = 0x06FF;

  // Arabic Supplement: U+0750 to U+077F
  static const int _arabicSupplementStart = 0x0750;
  static const int _arabicSupplementEnd = 0x077F;

  // Arabic Extended-A: U+08A0 to U+08FF
  static const int _arabicExtendedAStart = 0x08A0;
  static const int _arabicExtendedAEnd = 0x08FF;

  // Arabic Presentation Forms-A: U+FB50 to U+FDFF
  static const int _arabicPresAStart = 0xFB50;
  static const int _arabicPresAEnd = 0xFDFF;

  // Arabic Presentation Forms-B: U+FE70 to U+FEFF
  static const int _arabicPresBStart = 0xFE70;
  static const int _arabicPresBEnd = 0xFEFF;

  // Arabic diacritics (Tashkeel) to remove
  static const Map<String, String> _diacritics = {
    '\u064B': '', // Fathatan
    '\u064C': '', // Dammatan
    '\u064D': '', // Kasratan
    '\u064E': '', // Fatha
    '\u064F': '', // Damma
    '\u0650': '', // Kasra
    '\u0651': '', // Shadda
    '\u0652': '', // Sukun
    '\u0653': '', // Maddah
    '\u0654': '', // Hamza above
    '\u0655': '', // Hamza below
    '\u0656': '', // Subscript alef
    '\u0657': '', // Inverted damma
    '\u0658': '', // Mark noon ghunna
    '\u0670': '', // Superscript alef
    '\u0640': '', // Tatweel (kashida)
  };

  // Letters that should be normalized to a base letter
  static const Map<String, String> _letterNormalization = {
    'أ': 'ا', // Alef with hamza above
    'إ': 'ا', // Alef with hamza below
    'آ': 'ا', // Alef with madda
    'ٱ': 'ا', // Alef wasla
    'ة': 'ه', // Taa marbuta
    'ى': 'ي', // Alef maqsura
    'ؤ': 'و', // Waw with hamza
    'ئ': 'ي', // Yeh with hamza
    'ٳ': 'ا', // Alef with hamza below (subscript)
    'ٲ': 'ا', // Alef with wavy hamza below
    'ٵ': 'ا', // Alef with wavy hamza above
    'ﺍ': 'ا',
    'ﺎ': 'ا',
    'ﺁ': 'ا',
    'ﺂ': 'ا',
    'ﺃ': 'ا',
    'ﺄ': 'ا',
    'ﺇ': 'ا',
    'ﺈ': 'ا',
  };

  /// Check if a character is an Arabic letter
  static bool isArabicLetter(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= _arabicStart && code <= _arabicEnd) ||
        (code >= _arabicSupplementStart &&
            code <= _arabicSupplementEnd) ||
        (code >= _arabicExtendedAStart && code <= _arabicExtendedAEnd) ||
        (code >= _arabicPresAStart && code <= _arabicPresAEnd) ||
        (code >= _arabicPresBStart && code <= _arabicPresBEnd);
  }

  /// Check if the string contains only Arabic letters
  static bool isArabic(String text) {
    if (text.isEmpty) return false;
    for (int i = 0; i < text.length; i++) {
      if (!isArabicLetter(text[i]) && text[i] != ' ') return false;
    }
    return true;
  }

  /// Remove Arabic diacritics (Tashkeel) from text
  static String removeDiacritics(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(_diacritics[char] ?? char);
    }
    return buffer.toString();
  }

  /// Normalize Arabic text - lowercase equivalent for Arabic
  /// - Removes diacritics
  /// - Normalizes alef variants to bare alef
  /// - Normalizes taa marbuta to haa
  /// - Normalizes alef maqsura to yaa
  static String normalize(String text) {
    if (text.isEmpty) return text;
    final cleaned = removeDiacritics(text);
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      buffer.write(_letterNormalization[char] ?? char);
    }
    return buffer.toString();
  }

  /// Reverse text (for RTL processing in some cases)
  static String reverse(String text) => text.split('').reversed.join();

  /// Get the letter shape (independent, not contextual)
  static String getLetterShape(String letter) {
    return normalize(letter).toLowerCase();
  }

  /// Get all unique letters in a word
  static Set<String> getUniqueLetters(String word) {
    return normalize(word).split('').toSet();
  }

  /// Count occurrences of a letter in a word
  static int countLetter(String word, String letter) {
    final normalizedWord = normalize(word);
    final normalizedLetter = normalize(letter);
    int count = 0;
    for (int i = 0; i < normalizedWord.length; i++) {
      if (normalizedWord[i] == normalizedLetter) count++;
    }
    return count;
  }

  /// Check if word contains the required letter counts
  static bool wordCanBeFormedFrom(String word, List<String> letters) {
    final normalizedWord = normalize(word);
    final letterCounts = <String, int>{};
    for (final l in letters) {
      final n = normalize(l);
      letterCounts[n] = (letterCounts[n] ?? 0) + 1;
    }
    final wordCounts = <String, int>{};
    for (int i = 0; i < normalizedWord.length; i++) {
      final c = normalizedWord[i];
      wordCounts[c] = (wordCounts[c] ?? 0) + 1;
    }
    for (final entry in wordCounts.entries) {
      if ((letterCounts[entry.key] ?? 0) < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Check if a word is a palindrome
  static bool isPalindrome(String word) {
    final normalized = normalize(word);
    return normalized == normalized.split('').reversed.join();
  }

  /// Get Arabic sort key (alif-ba-taa-tha order)
  static List<String> arabicAlphabet = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
    'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
    'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي',
  ];

  /// Compare two Arabic words alphabetically
  static int compareArabic(String a, String b) {
    final na = normalize(a);
    final nb = normalize(b);
    final len = na.length < nb.length ? na.length : nb.length;
    for (int i = 0; i < len; i++) {
      final ia = arabicAlphabet.indexOf(na[i]);
      final ib = arabicAlphabet.indexOf(nb[i]);
      if (ia != ib) {
        return ia - ib;
      }
    }
    return na.length - nb.length;
  }

  /// Convert Arabic numerals to English
  static String toEnglishNumerals(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var result = input;
    for (var i = 0; i < arabicNumerals.length; i++) {
      result = result.replaceAll(arabicNumerals[i], englishNumerals[i]);
    }
    return result;
  }

  /// Convert English numerals to Arabic
  static String toArabicNumerals(String input) {
    const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < englishNumerals.length; i++) {
      result = result.replaceAll(englishNumerals[i], arabicNumerals[i]);
    }
    return result;
  }
}

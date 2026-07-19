import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_word_puzzle/core/helpers/arabic_text_helper.dart';

void main() {
  group('ArabicTextHelper', () {
    group('isArabicLetter', () {
      test('returns true for Arabic letters', () {
        expect(ArabicTextHelper.isArabicLetter('ا'), isTrue);
        expect(ArabicTextHelper.isArabicLetter('ب'), isTrue);
        expect(ArabicTextHelper.isArabicLetter('ي'), isTrue);
      });

      test('returns false for non-Arabic characters', () {
        expect(ArabicTextHelper.isArabicLetter('a'), isFalse);
        expect(ArabicTextHelper.isArabicLetter('1'), isFalse);
        expect(ArabicTextHelper.isArabicLetter(' '), isFalse);
      });
    });

    group('isArabic', () {
      test('returns true for Arabic text', () {
        expect(ArabicTextHelper.isArabic('مرحبا'), isTrue);
        expect(ArabicTextHelper.isArabic('السلام عليكم'), isTrue);
      });

      test('returns false for mixed or non-Arabic text', () {
        expect(ArabicTextHelper.isArabic('hello'), isFalse);
        expect(ArabicTextHelper.isArabic(''), isFalse);
      });
    });

    group('removeDiacritics', () {
      test('removes all diacritics', () {
        expect(ArabicTextHelper.removeDiacritics('مَرْحَبًا'),
            equals('مرحبا'));
        expect(ArabicTextHelper.removeDiacritics('العَرَبِيَّة'),
            equals('العربية'));
      });

      test('handles text without diacritics', () {
        expect(ArabicTextHelper.removeDiacritics('مرحبا'),
            equals('مرحبا'));
      });
    });

    group('normalize', () {
      test('normalizes alef variants', () {
        expect(ArabicTextHelper.normalize('أ'), equals('ا'));
        expect(ArabicTextHelper.normalize('إ'), equals('ا'));
        expect(ArabicTextHelper.normalize('آ'), equals('ا'));
        expect(ArabicTextHelper.normalize('ٱ'), equals('ا'));
      });

      test('normalizes taa marbuta to haa', () {
        expect(ArabicTextHelper.normalize('ة'), equals('ه'));
      });

      test('normalizes alef maqsura to yaa', () {
        expect(ArabicTextHelper.normalize('ى'), equals('ي'));
      });

      test('combines normalization and diacritics removal', () {
        expect(ArabicTextHelper.normalize('مَرْحَبًا'),
            equals('مرحبا'));
        expect(ArabicTextHelper.normalize('إِنْ شَاءَ اللَّه'),
            equals('ان شاء الله'));
      });
    });

    group('getUniqueLetters', () {
      test('returns unique letters', () {
        final letters = ArabicTextHelper.getUniqueLetters('سلام');
        expect(letters, equals({'س', 'ل', 'ا', 'م'}));
      });
    });

    group('countLetter', () {
      test('counts letter occurrences', () {
        expect(ArabicTextHelper.countLetter('سلام', 'ا'), equals(1));
        expect(ArabicTextHelper.countLetter('كتاب', 'ا'), equals(1));
        expect(ArabicTextHelper.countLetter('باب', 'ب'), equals(2));
      });
    });

    group('wordCanBeFormedFrom', () {
      test('returns true if word can be formed', () {
        expect(
          ArabicTextHelper.wordCanBeFormedFrom(
            'سلام',
            ['س', 'ل', 'ا', 'م', 'ك', 'ر'],
          ),
          isTrue,
        );
      });

      test('returns false if word needs more of a letter than available', () {
        expect(
          ArabicTextHelper.wordCanBeFormedFrom(
            'سلام',
            ['س', 'ل', 'م', 'ك', 'ر'],
          ),
          isFalse,
        );
      });
    });

    group('isPalindrome', () {
      test('detects palindromes', () {
        expect(ArabicTextHelper.isPalindrome('aba'), isFalse); // Not Arabic
        // For Arabic palindrome
        // "هم" might not be a true palindrome
      });
    });

    group('compareArabic', () {
      test('compares Arabic words alphabetically', () {
        expect(ArabicTextHelper.compareArabic('أ', 'ب'), lessThan(0));
        expect(ArabicTextHelper.compareArabic('ب', 'أ'), greaterThan(0));
        expect(ArabicTextHelper.compareArabic('أ', 'أ'), equals(0));
      });
    });

    group('toEnglishNumerals', () {
      test('converts Arabic numerals to English', () {
        expect(ArabicTextHelper.toEnglishNumerals('١٢٣'),
            equals('123'));
        expect(ArabicTextHelper.toEnglishNumerals('٠'), equals('0'));
      });
    });

    group('toArabicNumerals', () {
      test('converts English numerals to Arabic', () {
        expect(ArabicTextHelper.toArabicNumerals('123'),
            equals('١٢٣'));
        expect(ArabicTextHelper.toArabicNumerals('0'), equals('٠'));
      });
    });
  });
}

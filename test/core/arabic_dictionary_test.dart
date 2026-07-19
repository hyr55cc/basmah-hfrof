import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_word_puzzle/core/helpers/arabic_dictionary.dart';

void main() {
  group('ArabicDictionary', () {
    setUpAll(() async {
      // Initialize with built-in dictionary
      await ArabicDictionary.instance.initialize();
    });

    test('initializes with built-in words', () {
      expect(ArabicDictionary.instance.isLoaded, isTrue);
      expect(ArabicDictionary.instance.wordCount, greaterThan(0));
    });

    test('contains known Arabic words', () {
      expect(ArabicDictionary.instance.contains('مرحبا'), isTrue);
      expect(ArabicDictionary.instance.contains('كتاب'), isTrue);
      expect(ArabicDictionary.instance.contains('سلام'), isTrue);
    });

    test('normalizes words before checking', () {
      // Even with diacritics, should find the word
      expect(ArabicDictionary.instance.contains('مَرْحَبًا'), isTrue);
    });

    test('does not contain invalid words', () {
      expect(ArabicDictionary.instance.contains('xxx'), isFalse);
      expect(ArabicDictionary.instance.contains('zzz'), isFalse);
    });

    test('isValidArabicWord returns true for Arabic words', () {
      expect(ArabicDictionary.instance.isValidArabicWord('مرحبا'), isTrue);
      expect(ArabicDictionary.instance.isValidArabicWord('كتاب'), isTrue);
    });

    test('isValidArabicWord returns false for non-Arabic', () {
      expect(ArabicDictionary.instance.isValidArabicWord('hello'), isFalse);
      expect(ArabicDictionary.instance.isValidArabicWord('123'), isFalse);
    });

    test('getWordsByLength returns correct words', () {
      final threeLetter = ArabicDictionary.instance.getWordsByLength(3);
      expect(threeLetter.contains('سلام'), isTrue);
    });

    test('getStats returns dictionary info', () {
      final stats = ArabicDictionary.instance.getStats();
      expect(stats['total'], greaterThan(0));
    });
  });
}

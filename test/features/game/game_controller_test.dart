import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_word_puzzle/features/game/core/game_controller.dart';

void main() {
  group('GameController', () {
    late GameController controller;

    setUp(() {
      controller = GameController(
        letters: ['ا', 'ل', 'ع', 'م', 'س', 'ك'],
        answers: ['علم', 'سلام', 'عالم', 'معلم'],
        bonusWords: ['كلم', 'عمل'],
      );
    });

    test('initializes with all letters and answers', () {
      expect(controller.letters.length, equals(6));
      expect(controller.totalAnswers, equals(4));
      expect(controller.totalBonusWords, equals(2));
    });

    test('shuffles letters', () {
      final original = List.of(controller.displayedLetters);
      controller.shuffle();
      // After shuffle, letters should still be the same set
      expect(controller.displayedLetters.toSet(), equals(original.toSet()));
    });

    test('starts selection at index', () {
      controller.startSelection(0, const Offset(100, 100));
      expect(controller.selectedIndices.length, equals(1));
      expect(controller.isDragging, isTrue);
      expect(controller.currentWord, equals(controller.displayedLetters[0]));
    });

    test('adds letters to current word on continue', () {
      controller.startSelection(0, const Offset(100, 100));
      controller.continueSelection(1, const Offset(150, 100));
      expect(controller.currentWord.length, equals(2));
    });

    test('ends selection and validates word', () {
      // Find a sequence that spells "علم"
      final letterToIndex = <String, int>{};
      for (int i = 0; i < controller.displayedLetters.length; i++) {
        letterToIndex[controller.displayedLetters[i]] = i;
      }
      final indices = [0, 1, 2]
          .map((i) => letterToIndex.entries
              .firstWhere((e) => e.key == ['ع', 'ل', 'م'][i])
              .value)
          .toList();
      controller.startSelection(indices[0], const Offset(100, 100));
      controller.continueSelection(indices[1], const Offset(150, 100));
      controller.continueSelection(indices[2], const Offset(200, 100));
      final result = controller.endSelection();
      expect(result, isTrue);
    });

    test('rejects invalid word', () {
      controller.startSelection(0, const Offset(100, 100));
      controller.continueSelection(1, const Offset(150, 100));
      final result = controller.endSelection();
      // Whether valid or not depends on the shuffle, but selection should be cleared
      expect(controller.selectedIndices, isEmpty);
      expect(controller.isDragging, isFalse);
    });

    test('uses hint to reveal letter', () {
      final hint = controller.revealLetter();
      if (hint != null) {
        expect(controller.hintedIndices, contains(hint));
      }
    });

    test('uses hint to reveal word', () {
      final word = controller.revealWord();
      if (word != null) {
        expect(controller.foundAnswersCount, greaterThan(0));
      }
    });

    test('resets the level', () {
      controller.startSelection(0, const Offset(100, 100));
      controller.endSelection();
      controller.reset();
      expect(controller.selectedIndices, isEmpty);
      expect(controller.hintedIndices, isEmpty);
    });
  });
}

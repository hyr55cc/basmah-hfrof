import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../../../core/helpers/arabic_text_helper.dart';
import '../../../core/helpers/arabic_dictionary.dart';
import '../domain/entities/game_state.dart';

/// Manages the core game state and word validation logic
class GameController extends ChangeNotifier {
  GameController({
    required this.letters,
    required this.answers,
    this.bonusWords = const <String>[],
  })  : _remainingAnswers = Set<String>.from(answers.map(ArabicTextHelper.normalize)),
        _remainingBonusWords = Set<String>.from(bonusWords.map(ArabicTextHelper.normalize)),
        _foundWords = <String>{},
        _foundBonusWords = <String>{},
        _hintedIndices = <int>{} {
    _shuffleLetters();
  }

  final List<String> letters;
  final List<String> answers;
  final List<String> bonusWords;
  Set<String> _remainingAnswers;
  Set<String> _remainingBonusWords;
  final Set<String> _foundWords;
  final Set<String> _foundBonusWords;
  final Set<int> _hintedIndices;

  // Current selection
  final List<int> _selectedIndices = [];
  final List<Offset> _connectionPoints = [];
  Offset? _currentPointerPosition;
  bool _isDragging = false;
  String _currentWord = '';
  String? _errorMessage;
  String? _successMessage;
  GameWordType? _lastWordType;
  DateTime? _lastMessageShown;

  // Letters in display order (after potential shuffle)
  late List<String> _displayedLetters;
  List<String> get displayedLetters => List.unmodifiable(_displayedLetters);

  // Getters
  List<int> get selectedIndices => List.unmodifiable(_selectedIndices);
  List<Offset> get connectionPoints => List.unmodifiable(_connectionPoints);
  Offset? get currentPointerPosition => _currentPointerPosition;
  bool get isDragging => _isDragging;
  String get currentWord => _currentWord;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  GameWordType? get lastWordType => _lastWordType;
  Set<int> get hintedIndices => _hintedIndices;

  int get totalAnswers => answers.length;
  int get foundAnswersCount => _foundWords.length;
  int get remainingAnswersCount => _remainingAnswers.length;
  int get totalBonusWords => bonusWords.length;
  int get foundBonusWordsCount => _foundBonusWords.length;
  int get totalFound => _foundWords.length + _foundBonusWords.length;
  int get totalWords => answers.length + bonusWords.length;

  bool get isCompleted => _remainingAnswers.isEmpty;

  int get progressPercent {
    if (totalAnswers == 0) return 0;
    return ((foundAnswersCount / totalAnswers) * 100).round();
  }

  /// Shuffle the letters to randomize their display order
  void _shuffleLetters() {
    _displayedLetters = List<String>.from(letters);
    _displayedLetters.shuffle(Random());
  }

  /// Shuffle externally (for shuffle hint)
  void shuffle() {
    _shuffleLetters();
    _clearSelection();
    notifyListeners();
  }

  /// Start selecting a letter
  void startSelection(int index, Offset point) {
    if (_hintedIndices.contains(index)) return;
    _clearSelection();
    _selectedIndices.add(index);
    _connectionPoints.add(point);
    _currentWord = _displayedLetters[index];
    _isDragging = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Continue selection by hovering over a letter
  void continueSelection(int index, Offset point) {
    if (!_isDragging) return;
    if (_selectedIndices.contains(index)) {
      // Allow backtracking - remove the last selection
      if (_selectedIndices.length > 1 &&
          _selectedIndices.last == index) {
        _selectedIndices.removeLast();
        _connectionPoints.removeLast();
        _currentWord = _currentWord.substring(0, _currentWord.length - 1);
        notifyListeners();
      }
      return;
    }
    if (_hintedIndices.contains(index)) return;
    _selectedIndices.add(index);
    _connectionPoints.add(point);
    _currentWord += _displayedLetters[index];
    notifyListeners();
  }

  /// Update pointer position while dragging
  void updatePointer(Offset position) {
    if (!_isDragging) return;
    _currentPointerPosition = position;
    notifyListeners();
  }

  /// End the current selection and validate
  bool endSelection() {
    if (!_isDragging) return false;
    _isDragging = false;
    _currentPointerPosition = null;

    if (_currentWord.isEmpty) {
      _clearSelection();
      return false;
    }

    final normalized = ArabicTextHelper.normalize(_currentWord);
    if (_isAlreadyFound(normalized)) {
      _errorMessage = 'تم اكتشاف هذه الكلمة';
      _flashError();
      _clearSelection();
      return false;
    }

    if (_remainingAnswers.contains(normalized)) {
      _foundWords.add(normalized);
      _remainingAnswers.remove(normalized);
      _lastWordType = GameWordType.answer;
      _successMessage = _currentWord;
      _flashSuccess();
      _clearSelection();
      return true;
    }

    if (_remainingBonusWords.contains(normalized)) {
      _foundBonusWords.add(normalized);
      _remainingBonusWords.remove(normalized);
      _lastWordType = GameWordType.bonus;
      _successMessage = 'كلمة إضافية!';
      _flashSuccess();
      _clearSelection();
      return true;
    }

    // Check if word is valid but not in this level
    if (ArabicDictionary.instance.isValidArabicWord(_currentWord)) {
      _lastWordType = GameWordType.dictionary;
      _successMessage = 'كلمة جديدة!';
      _flashSuccess();
      _clearSelection();
      return true;
    }

    _errorMessage = 'كلمة غير صحيحة';
    _lastWordType = GameWordType.invalid;
    _flashError();
    _clearSelection();
    return false;
  }

  /// Cancel the current selection
  void cancelSelection() {
    _isDragging = false;
    _currentPointerPosition = null;
    _clearSelection();
  }

  void _clearSelection() {
    _selectedIndices.clear();
    _connectionPoints.clear();
    _currentWord = '';
    notifyListeners();
  }

  bool _isAlreadyFound(String word) {
    return _foundWords.contains(word) || _foundBonusWords.contains(word);
  }

  void _flashSuccess() {
    _lastMessageShown = DateTime.now();
  }

  void _flashError() {
    _lastMessageShown = DateTime.now();
  }

  /// Clear messages after a delay
  void clearMessages() {
    if (_lastMessageShown != null &&
        DateTime.now().difference(_lastMessageShown!).inMilliseconds > 1500) {
      _errorMessage = null;
      _successMessage = null;
      _lastWordType = null;
      notifyListeners();
    }
  }

  /// Use hint to reveal a letter index
  int? revealLetter() {
    final remaining = <int>[];
    for (int i = 0; i < _displayedLetters.length; i++) {
      if (_hintedIndices.contains(i)) continue;
      // Check if letter is part of any remaining answer
      for (final answer in _remainingAnswers) {
        if (answer.contains(_displayedLetters[i])) {
          remaining.add(i);
          break;
        }
      }
    }
    if (remaining.isEmpty) return null;
    final hintIndex = remaining[Random().nextInt(remaining.length)];
    _hintedIndices.add(hintIndex);
    notifyListeners();
    return hintIndex;
  }

  /// Reveal a full word
  String? revealWord() {
    if (_remainingAnswers.isEmpty) return null;
    final word = _remainingAnswers.first;
    // Mark all indices in this word as hinted
    for (int i = 0; i < _displayedLetters.length; i++) {
      if (word.contains(_displayedLetters[i])) {
        _hintedIndices.add(i);
      }
    }
    _foundWords.add(word);
    _remainingAnswers.remove(word);
    notifyListeners();
    return word;
  }

  /// Remove a wrong letter (greys out one letter that's not in any answer)
  void removeWrongLetter() {
    final used = <String>{};
    for (final answer in _remainingAnswers) {
      used.addAll(answer.split(''));
    }
    final candidates = <int>[];
    for (int i = 0; i < _displayedLetters.length; i++) {
      if (!used.contains(_displayedLetters[i]) &&
          !_hintedIndices.contains(i)) {
        candidates.add(i);
      }
    }
    if (candidates.isNotEmpty) {
      _hintedIndices.add(candidates[Random().nextInt(candidates.length)]);
      notifyListeners();
    }
  }

  /// Reset the level
  void reset() {
    _remainingAnswers = Set<String>.from(answers.map(ArabicTextHelper.normalize));
    _remainingBonusWords = Set<String>.from(bonusWords.map(ArabicTextHelper.normalize));
    _foundWords.clear();
    _foundBonusWords.clear();
    _hintedIndices.clear();
    _clearSelection();
    shuffle();
  }

  /// Check if index is hinted
  bool isHinted(int index) => _hintedIndices.contains(index);
}

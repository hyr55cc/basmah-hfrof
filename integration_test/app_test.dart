import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arabic_word_puzzle/core/helpers/arabic_text_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Arabic normalization works end-to-end', (tester) async {
    final inputs = ['مَرْحَبًا', 'إِنْ شَاءَ اللَّه', 'كَتَبَ'];
    final expected = ['مرحبا', 'ان شاء الله', 'كتب'];

    for (int i = 0; i < inputs.length; i++) {
      expect(
        ArabicTextHelper.normalize(inputs[i]),
        equals(expected[i]),
      );
    }
  });
}

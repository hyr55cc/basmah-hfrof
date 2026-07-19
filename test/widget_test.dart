import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_word_puzzle/core/theme/app_theme.dart';

void main() {
  testWidgets('App theme builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: Text('اختبار'),
          ),
        ),
      ),
    );
    expect(find.text('اختبار'), findsOneWidget);
  });

  testWidgets('Dark theme applies correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Center(
            child: Text('الوضع الداكن'),
          ),
        ),
      ),
    );
    expect(find.text('الوضع الداكن'), findsOneWidget);
  });
}

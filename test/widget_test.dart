// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fish_book/main.dart';

void main() {
  testWidgets('FishBook app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FishBookApp(),
      ),
    );

    // Verify that our app loads correctly.
    expect(find.text('鱼书 FishBook'), findsOneWidget);
    expect(find.text('欢迎来到鱼书'), findsOneWidget);

    // Verify bottom navigation is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitmedia_app/main.dart';

void main() {
  testWidgets('App smoke test - renders FirstScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SuitmediaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

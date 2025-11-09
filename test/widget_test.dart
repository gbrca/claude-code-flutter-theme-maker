import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_theme_maker/main.dart';

void main() {
  testWidgets('Theme Maker app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterThemeMakerApp());

    expect(find.text('Flutter Theme Maker'), findsOneWidget);
    expect(find.text('Színek kiválasztása'), findsOneWidget);
    expect(find.text('Előnézet'), findsOneWidget);
    expect(find.text('Generált kód'), findsOneWidget);
  });

  testWidgets('Dark mode toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterThemeMakerApp());

    final darkModeButton = find.byIcon(Icons.dark_mode);
    expect(darkModeButton, findsOneWidget);

    await tester.tap(darkModeButton);
    await tester.pump();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Color picker buttons exist', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterThemeMakerApp());

    expect(find.text('Elsődleges szín'), findsOneWidget);
    expect(find.text('Másodlagos szín'), findsOneWidget);
  });

  testWidgets('Preview components exist', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterThemeMakerApp());

    expect(find.text('Elevated gomb'), findsOneWidget);
    expect(find.text('Filled gomb'), findsOneWidget);
    expect(find.text('Outlined gomb'), findsOneWidget);
    expect(find.text('Text gomb'), findsOneWidget);
  });

  testWidgets('Copy button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterThemeMakerApp());

    expect(find.text('Másolás'), findsOneWidget);
  });
}

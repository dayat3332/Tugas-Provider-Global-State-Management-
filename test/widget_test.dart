import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_latihan_global/main.dart';

void main() {
  testWidgets('Provider updates username across Settings and Home pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Initial state on Home page shows "Default"
    expect(find.text('Default'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify Settings page shows "Username: " and "Default"
    expect(find.text('Username: '), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    // Enter new username "Latihan" and tap Save
    await tester.enterText(find.byType(TextField), 'Latihan');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pump();

    // Verify Settings page updated username to "Latihan"
    expect(find.text('Latihan'), findsOneWidget);

    // Navigate back to Home tab
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // Verify Home page displays updated username "Latihan"
    expect(find.text('Latihan'), findsOneWidget);
  });
}

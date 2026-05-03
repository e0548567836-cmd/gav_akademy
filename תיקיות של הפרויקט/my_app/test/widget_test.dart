import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// וודאי ששם הפקג' מתאים לשם הפרויקט שלך (my_app)
import 'package:my_app/main.dart'; 

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // כאן היה התיקון: שינינו מ-MyApp ל-StudentManagementApp
    await tester.pumpWidget(const StudentManagementApp());

    // הערה: שאר הטסט הזה כנראה ייכשל כשתריצי אותו כי אין לך כפתור "+" באפליקציה,
    // אבל הקווים האדומים (שגיאות הקומפילציה) ייעלמו עכשיו.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'גב אקדמי',
      // ביטול פס ה-Debug בפינה
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // הגדרת תמיכה בעברית (RTL) לכל האפליקציה
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      // דף הבית של האפליקציה - דף ההתחברות
      home: const LoginPage(),
    );
  }
}

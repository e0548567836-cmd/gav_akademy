import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'pages/login_page.dart';
import 'services/api_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  runApp(const StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  void _checkConnection() async {
    debugPrint("--- בדיקת חיבור לקטלוג הקורסים ---");
    var courses = await ApiService.getAllCourses();
    if (courses.isEmpty) {
      debugPrint("שימי לב: לא חזרו קורסים (או שהטבלה ריקה או שיש שגיאת חיבור)");
    } else {
      debugPrint("החיבור הצליח! נמצאו ${courses.length} קורסים בקטלוג.");
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkConnection();
    return MaterialApp(
      title: 'גב אקדמי',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const LoginPage(),
    );
  }
}

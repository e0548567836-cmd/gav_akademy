import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../constants.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'edit_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final id = idController.text.trim();
    final password = passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('נא למלא ת"ז וסיסמה')));
      return;
    }

    try {
      final response = await ApiService.login(id, password);

      if (!mounted) return; // פותר את האזהרה cross async gaps

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 1. שליפת ה-ID מתוך הנתונים שהשרת החזיר
        final String loggedInId = data['studentId'].toString();

        if (!mounted) return;

        // 2. הצגת הודעת ברוך הבא
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ברוך הבא, ${data['name']}')));

        // 3. המעבר לעמוד הבא עם שליחת ה-ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProfilePage(userId: loggedInId),
          ),
        );
      } else {
        // אם הסטטוס הוא לא 200 (למשל סיסמה שגויה)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('שגיאה: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('שגיאת תקשורת עם השרת')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: kPrimaryColor,
                ),
                const Text(
                  'גב אקדמי',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: idController,
                  hint: 'תעודת זהות',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: passwordController,
                  hint: 'סיסמה',
                  isPassword: true,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'כניסה',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    'אין לך חשבון? להרשמה',
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

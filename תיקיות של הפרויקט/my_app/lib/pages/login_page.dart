import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/google_auth_service.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'management_page.dart';
import 'complete_profile_page.dart';

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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('נא למלא ת"ז וסיסמה')));
      return;
    }

    try {
      final response = await ApiService.login(id, password);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String studentName = data['name'] ?? 'סטודנט';
        final String studentId = data['studentId'].toString();
        final bool isManagement = data['management'] ?? false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isManagement
                ? const ManagementPage()
                : DashboardScreen(userName: studentName, userId: studentId),
          ),
        );
      } else {
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

  Future<void> _handleGoogleLogin() async {
    final data = await GoogleAuthService.signIn();
    if (!mounted) return;

    if (data == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('כניסה עם גוגל נכשלה')));
      return;
    }

    final bool isNewUser = data['isNewUser'] ?? false;

    if (isNewUser) {
      // משתמש חדש – מעבר למסך השלמת ת.ז
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CompleteProfilePage(email: data['email'], name: data['name']),
        ),
      );
    } else {
      // משתמש קיים – כניסה רגילה
      final String studentName = data['name'] ?? 'סטודנט';
      final String studentId = data['studentId'].toString();
      final bool isManagement = data['management'] ?? false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isManagement
              ? const ManagementPage()
              : DashboardScreen(userName: studentName, userId: studentId),
        ),
      );
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
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Colors.grey),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'G',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'כניסה עם Google',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ],
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

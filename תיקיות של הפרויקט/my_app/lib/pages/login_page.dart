import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'management_page.dart';

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

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';
import '../widgets/page_padding.dart';
import '../helpers/validation_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final emailCont = TextEditingController();
  final phoneCont = TextEditingController();
  final passCont = TextEditingController();
  final confirmPassCont = TextEditingController();
  final gradeController = TextEditingController();

  Future<void> _handleRegister() async {
    final id = idController.text.trim();
    final name = nameController.text.trim();
    final grade = double.tryParse(gradeController.text.trim()) ?? 80;
    final error = ValidationHelper.validateGrade(grade);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (passCont.text != confirmPassCont.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('הסיסמאות אינן תואמות!')));
      return;
    }

    final studentData = {
      'StudentId': id,
      'studentName': name,
      'studentEmail': emailCont.text.trim(),
      'studentPhone': phoneCont.text.trim(),
      'StudentPassword': passCont.text.trim(),
      'Grade': grade,
    };

    try {
      final response = await ApiService.register(studentData);
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userName: name,
              userId: id,
              grade: grade,
            ),
          ),
          (route) => false,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('נרשמת בהצלחה!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('שגיאה: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('שגיאת תקשורת')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: PagePadding(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1F3C88),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    GreetingHeader(title: 'הרשמה', userName: ''),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: idController,
                  hint: 'תעודת זהות',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(controller: nameController, hint: 'שם מלא'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: emailCont,
                  hint: 'מייל אקדמי',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: phoneCont,
                  hint: 'טלפון',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: gradeController,
                  hint: 'ממוצע אקדמי',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: passCont,
                  hint: 'סיסמה',
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: confirmPassCont,
                  hint: 'אימות סיסמה',
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'סיום הרשמה',
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
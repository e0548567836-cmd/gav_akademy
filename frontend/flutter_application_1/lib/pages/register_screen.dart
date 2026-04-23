import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';
import '../widgets/custom_text_field.dart';

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

  Future<void> _handleRegister() async {
    if (passCont.text != confirmPassCont.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('הסיסמאות אינן תואמות!')));
      return;
    }

    final studentData = {
      'StudentId': idController.text.trim(),
      'studentName': nameController.text.trim(),
      'studentEmail': emailCont.text.trim(),
      'studentPhone': phoneCont.text.trim(),
      'StudentPassword': passCont.text.trim(),
    };

    try {
      final response = await ApiService.register(studentData);
      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context);
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
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          title: const Text('הרשמה'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
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
    );
  }
}

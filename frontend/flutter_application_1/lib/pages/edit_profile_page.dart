import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  void _save() async {
    final response = await ApiService.updateStudent(widget.userId, {
      'studentName': _nameController.text,
      'studentEmail': _emailController.text,
      'studentPhone': _phoneController.text,
    });

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הנתונים נשמרו בהצלחה!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('עריכת פרופיל: ${widget.userId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CustomTextField(controller: _nameController, hint: 'שם מלא'),
            const SizedBox(height: 20),

            CustomTextField(controller: _emailController, hint: 'מייל אקדמי'),
            const SizedBox(height: 20),

            CustomTextField(controller: _phoneController, hint: 'טלפון'),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('שמור שינויים')),
          ],
        ),
      ),
    );
  }
}

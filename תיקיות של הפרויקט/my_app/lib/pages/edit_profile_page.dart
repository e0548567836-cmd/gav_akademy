import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:my_app/widgets/custom_text_field.dart';
import '../widgets/page_padding.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String userName;
  const EditProfilePage({super.key, required this.userId, this.userName = ''});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('נא להזין שם')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.updateStudent(widget.userId, {
        'studentName': newName,
        'studentEmail': _emailController.text.trim(),
        'studentPhone': _phoneController.text.trim(),
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('עודכן בהצלחה!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newName);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בעדכון'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין חיבור לשרת'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: PagePadding(
          child: Column(
            children: [
              GreetingHeader(title: 'עריכת פרופיל', userName: widget.userName),
              const SizedBox(height: 20),
              CustomTextField(controller: _nameController, hint: 'שם מלא'),
              const SizedBox(height: 20),
              CustomTextField(controller: _emailController, hint: 'מייל אקדמי'),
              const SizedBox(height: 20),
              CustomTextField(controller: _phoneController, hint: 'טלפון'),
              const SizedBox(height: 20),
              // ✅ הכפתור משתמש ב-_isLoading: מושבת בזמן טעינה + מציג spinner
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('שמור שינויים'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

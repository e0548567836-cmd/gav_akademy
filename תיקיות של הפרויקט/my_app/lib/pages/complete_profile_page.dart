import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

class CompleteProfilePage extends StatefulWidget {
  final String email;
  final String name;

  const CompleteProfilePage({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final idController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleComplete() async {
    final id = idController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('נא להזין תעודת זהות')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // שליחת הנתונים לשרת - ודאי ששמות השדות תואמים למודל ב-C#
      final response = await ApiService.register({
        'StudentId': id, // שונה ל-PascalCase כדי להתאים ל-ASP.NET
        'StudentName': widget.name,
        'StudentEmail': widget.email,
        'StudentPassword': 'GOOGLE_USER',
        'StudentPhone': '',
        'Management': false,
      });

      if (!mounted) return;
      setState(() => isLoading = false);

      // בדיקה אם הסטטוס הוא 200 (הצלחה)
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(userName: widget.name, userId: id,grade: 80,),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה מהשרת: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('שגיאת תקשורת עם השרת')),
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
                  Icons.person_add_rounded,
                  size: 80,
                  color: kPrimaryColor,
                ),
                const Text(
                  'השלמת פרטים',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'שלום, ${widget.name}!',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                const Text(
                  'נא להזין תעודת זהות להשלמת ההרשמה',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: idController,
                  hint: 'תעודת זהות',
                  keyboardType: TextInputType.text, // שינוי לטקסט כי עברנו ל-String
                ),
                const SizedBox(height: 25),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleComplete,
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
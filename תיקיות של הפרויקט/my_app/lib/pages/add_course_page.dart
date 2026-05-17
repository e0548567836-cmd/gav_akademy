import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';
import '../widgets/custom_text_field.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  // הגדרת הקונטרולרים לניהול הקלט
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // הוספתי קונטרולר לתיאור
  bool isLoading = false;

  @override
  void dispose() {
    // שחרור משאבים מהזיכרון בסיום השימוש בדף
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // תמיכה בעברית מימין לשמאל
      child: Scaffold(
        appBar: AppBar(
          title: const Text('הוספת קורס חדש'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // שדה מספר קורס
              CustomTextField(
                controller: _idController,
                hint: 'לדוגמה: CS101',
                label: 'מספר קורס (ID)',
                keyboardType:
                    TextInputType.text, // שונה לטקסט כי זה String בשרת
              ),

              const SizedBox(height: 20),

              // שדה שם הקורס
              CustomTextField(
                controller: _nameController,
                hint: 'לדוגמה: מבני נתונים',
                label: 'שם הקורס',
              ),

              const SizedBox(height: 20),

              // שדה תיאור הקורס (הוספתי כדי להתאים ל-ApiService)
              CustomTextField(
                controller: _descriptionController,
                hint: 'פירוט קצר על הקורס',
                label: 'תיאור הקורס',
              ),

              const SizedBox(height: 30),

              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    // בדיקת תקינות קלט בסיסית
                    if (_idController.text.isEmpty ||
                        _nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('נא למלא לפחות קוד ושם קורס'),
                        ),
                      );
                      return;
                    }

                    setState(() => isLoading = true);

                    try {
                      // קריאה לשרת להוספת הקורס עם 3 הפרמטרים הנדרשים
                      final response = await ApiService.addCourse(
                        _idController.text,
                        _nameController.text,
                        _descriptionController.text,
                      );

                      if (!mounted) return;

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('הקורס נוסף בהצלחה למערכת'),
                          ),
                        );
                        Navigator.pop(context); // חזרה לדף הקודם
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('שגיאה מהשרת: ${response.body}'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('שגיאת תקשורת: ודאי שהשרת פועל'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => isLoading = false);
                    }
                  },
                  child: const Text(
                    'שמור קורס במערכת',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

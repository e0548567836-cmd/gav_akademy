import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';
import '../widgets/custom_text_field.dart';

/// A page for adding a new course to the system.
class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  // Controllers for managing user input.
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Controller for the course description.
  bool isLoading = false;

  @override
  void dispose() {
    // Releases resources when the page is disposed.
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Supports right-to-left text direction.
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

              // Course ID field.
              CustomTextField(
                controller: _idController,
                hint: 'לדוגמה: CS101',
                label: 'מספר קורס (ID)',
                keyboardType:
                    TextInputType.text, // Uses text input because the server expects a string.
              ),

              const SizedBox(height: 20),

              // Course name field.
              CustomTextField(
                controller: _nameController,
                hint: 'לדוגמה: מבני נתונים',
                label: 'שם הקורס',
              ),

              const SizedBox(height: 20),

              // Course description field.
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
                    // Validates the required input fields.
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
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    try {
                      // Sends a request to add the course.
                      final response = await ApiService.addCourse(
                        _idController.text,
                        _nameController.text,
                        _descriptionController.text,
                      );

                      if (!mounted) return;

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('הקורס נוסף בהצלחה למערכת'),
                          ),
                        );
                        navigator.pop(); // Returns to the previous page.
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('שגיאה מהשרת: ${response.body}'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        messenger.showSnackBar(
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
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';

class DeleteCoursePage extends StatefulWidget {
  const DeleteCoursePage({super.key});

  @override
  State<DeleteCoursePage> createState() => _DeleteCoursePageState();
}

class _DeleteCoursePageState extends State<DeleteCoursePage> {
  Map<String, dynamic>? selectedCourse;
  List<dynamic> courses = [];
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // טעינת רשימת הקורסים מהשרת
  void _loadData() async {
    try {
      var data = await ApiService.getAllCourses();
      setState(() {
        courses = data;
        isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("שגיאה בטעינת הקורסים")),
        );
      }
    }
  }

  // פונקציה להצגת דיאלוג אישור ומחיקה
  void _confirmDelete() {
    if (selectedCourse == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("אישור מחיקה", textAlign: TextAlign.right),
        content: Text(
          "האם ברצונך למחוק את הקורס '${selectedCourse!['name']}' מהמערכת?\nפעולה זו תסיר את הקורס גם מכל הסטודנטים הרשומים אליו.",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ביטול"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // סגירת הדיאלוג
              
              // שימוש ב-CourseId מהאובייקט שנבחר
              final response = await ApiService.removeCourse(selectedCourse!['courseId'].toString());
              
              if (mounted) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("הקורס נמחק בהצלחה")),
                  );
                  Navigator.pop(context); // חזרה לתפריט הניהול
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("שגיאה במחיקת הקורס")),
                  );
                }
              }
            },
            child: const Text("מחק", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('מחיקת קורס מהמאגר'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "חפשי קורס למחיקה:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // חיפוש חכם (Autocomplete) במקום Dropdown פשוט
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) => 
                          "${option['name']} (${option['courseId']})",
                      optionsBuilder: (TextEditingValue textValue) {
                        if (textValue.text.isEmpty) {
                          return courses.cast<Map<String, dynamic>>();
                        }
                        return courses.where((course) => course['name']
                            .toString()
                            .toLowerCase()
                            .contains(textValue.text.toLowerCase()))
                            .cast<Map<String, dynamic>>();
                      },
                      onSelected: (selection) {
                        setState(() {
                          selectedCourse = selection;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kInputFillColor,
                            hintText: "הקלידי שם קורס...",
                            prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    if (selectedCourse != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "נבחר למחיקה: ${selectedCourse!['name']}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: selectedCourse == null ? null : _confirmDelete,
                      child: const Text(
                        'מחק קורס מהטבלה',
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
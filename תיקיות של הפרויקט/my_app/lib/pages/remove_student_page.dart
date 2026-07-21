import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';

class RemoveStudentPage extends StatefulWidget {
  const RemoveStudentPage({super.key});

  @override
  State<RemoveStudentPage> createState() => _RemoveStudentPageState();
}

class _RemoveStudentPageState extends State<RemoveStudentPage> {
  List<dynamic> _students = [];
  Map<String, dynamic>? _selectedStudent; // שינוי לניהול אובייקט הסטודנט שנבחר
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final data = await ApiService.getAllStudents();
      setState(() {
        _students = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בטעינת רשימת הסטודנטים')),
        );
      }
    }
  }

  // פונקציה להצגת דיאלוג אישור לפני מחיקה
  void _confirmDelete() {
    if (_selectedStudent == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("אישור מחיקה", textAlign: TextAlign.right),
        content: Text(
          "האם את בטוחה שברצונך למחוק את ${_selectedStudent!['studentName']} מהמערכת?\nפעולה זו היא סופית ולא ניתן לבטלה.",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ביטול"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleDelete();
            },
            child: const Text("מחק", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    if (_selectedStudent == null) return;

    setState(() => _isDeleting = true);

    try {
      final response = await ApiService.removeStudent(_selectedStudent!['studentId'].toString());

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('הסטודנט הוסר בהצלחה')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בתהליך המחיקה')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('הסרת סטודנט מהמערכת'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "חפשי סטודנט למחיקה:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // חיפוש חכם (Autocomplete) במקום Dropdown
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) =>
                          "${option['studentName']} (${option['studentId']})",
                      optionsBuilder: (TextEditingValue textValue) {
                        if (textValue.text.isEmpty) {
                          return _students.cast<Map<String, dynamic>>();
                        }
                        return _students.where((student) => student['studentName']
                            .toString()
                            .toLowerCase()
                            .contains(textValue.text.toLowerCase()) || 
                            student['studentId'].toString().contains(textValue.text))
                            .cast<Map<String, dynamic>>();
                      },
                      onSelected: (selection) {
                        setState(() {
                          _selectedStudent = selection;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kInputFillColor,
                            hintText: "הקלידי שם או תעודת זהות...",
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

                    if (_selectedStudent != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "נבחר למחיקה: ${_selectedStudent!['studentName']}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    if (_isDeleting)
                      const Center(child: CircularProgressIndicator())
                    else
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
                        onPressed: _selectedStudent == null ? null : _confirmDelete,
                        child: const Text(
                          'מחק סטודנט לצמיתות',
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
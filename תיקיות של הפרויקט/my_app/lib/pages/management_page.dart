import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';
import 'add_course_page.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // משיכת רשימת הסטודנטים מה-API
  Future<void> _fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAllStudents();
      setState(() {
        students = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("שגיאה בטעינת סטודנטים")),
        );
      }
    }
  }

  // פונקציה למחיקת סטודנט
  Future<void> _deleteStudent(String id) async {
    final response = await ApiService.removeStudent(id);
    if (response.statusCode == 200) {
      _fetchStudents(); // רענון הרשימה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("הסטודנט הוסר בהצלחה")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול מערכת - גב אקדמי'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchStudents,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : students.isEmpty
                ? const Center(child: Text("אין סטודנטים רשומים במערכת"))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      // סנכרון שמות השדות מול ה-API
                      final String name = student['studentName'] ?? 'ללא שם';
                      final String id = student['studentId'].toString();
                      final bool isAdmin = student['management'] ?? false;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isAdmin ? Colors.amber : kPrimaryColor,
                            child: Icon(
                              isAdmin ? Icons.star : Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text('ת"ז: $id'),
                          trailing: isAdmin 
                            ? const Text("מנהל", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
                            : IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _showDeleteDialog(id, name),
                              ),
                        ),
                      );
                    },
                  ),
        // כפתור להוספת קורס חדש ל-DB
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCoursePage())),
          label: const Text('הוספת קורס לקטלוג'),
          icon: const Icon(Icons.add_chart),
          backgroundColor: kPrimaryColor,
        ),
      ),
    );
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("אישור מחיקה"),
        content: Text("האם את בטוחה שברצונך למחוק את $name מהמערכת?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ביטול")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteStudent(id);
            },
            child: const Text("מחק", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
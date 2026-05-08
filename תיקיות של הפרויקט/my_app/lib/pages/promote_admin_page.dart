import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';

class PromoteAdminPage extends StatefulWidget {
  const PromoteAdminPage({super.key});

  @override
  State<PromoteAdminPage> createState() => _PromoteAdminPageState();
}

class _PromoteAdminPageState extends State<PromoteAdminPage> {
  List<dynamic> students = [];
  Map<String, dynamic>? selectedStudent; // נשמור את כל האובייקט של הסטודנט שנבחר
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final data = await ApiService.getAllStudents();
    setState(() {
      // מסננים רק את מי שאינו מנהל
      students = data.where((s) => s['management'] == false).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("מינוי מנהל חדש"),
          backgroundColor: const Color(0xFF1F3C88),
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "חפש שם סטודנט לשדרוג:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // ווידג'ט החיפוש החכם
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) => 
                          "${option['studentName']} (${option['studentId']})",
                      optionsBuilder: (TextEditingValue textValue) {
                        if (textValue.text.isEmpty) {
                          return students.cast<Map<String, dynamic>>();
                        }
                        return students.where((s) => s['studentName']
                            .toString()
                            .toLowerCase()
                            .contains(textValue.text.toLowerCase()))
                            .cast<Map<String, dynamic>>();
                      },
                      onSelected: (selection) {
                        setState(() {
                          selectedStudent = selection;
                        });
                      },
                      // עיצוב שדה הטקסט של החיפוש
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "הקלד שם סטודנט...",
                            prefixIcon: Icon(Icons.search),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    if (selectedStudent != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: Text(
                            "נבחר: ${selectedStudent!['studentName']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ),
                      
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: selectedStudent == null
                          ? null
                          : () async {
                              final success = await ApiService.makeStudentAdmin(
                                selectedStudent!['studentId'].toString()
                              );
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("הסטודנט שודרג למנהל בהצלחה!")),
                                );
                                Navigator.pop(context);
                              }
                            },
                      child: const Text(
                        "אשר שדרוג למעמד מנהל",
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
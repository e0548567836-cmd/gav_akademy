import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import '../services/api_service.dart';
import 'package:my_app/widgets/custom_text_field.dart';
import '../widgets/page_padding.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> myCourses = [];
  late String currentUserName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserName = widget.userName;
    _loadMyCourses();
  }

  Future<void> _loadMyCourses() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final results = await ApiService.getMyCourses(widget.userId);

    if (!mounted) return;
    setState(() {
      myCourses = List<Map<String, dynamic>>.from(results);
      isLoading = false;
    });
  }

  void _confirmDelete(String courseId, String courseName) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("מחיקת קורס", textAlign: TextAlign.right),
        content: Text(
          "האם ברצונך להסיר את הקורס $courseName?",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ביטול"),
          ),
          TextButton(
            onPressed: () async {
              // ✅ שומרים את ה-navigator לפני ה-await
              final nav = Navigator.of(ctx);
              final success = await ApiService.unenrollFromCourse(
                widget.userId,
                courseId,
              );
              if (!mounted) return;
              if (success) {
                nav.pop();
                _loadMyCourses();
                messenger.showSnackBar(
                  const SnackBar(content: Text("הקורס הוסר בהצלחה")),
                );
              }
            },
            child: const Text("כן, מחק", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog() async {
    final results = await ApiService.getAllCourses();
    List<Map<String, dynamic>> allCatalog = List<Map<String, dynamic>>.from(
      results,
    );
    Map<String, dynamic>? selectedCourse;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("הוספת קורס", textAlign: TextAlign.right),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "חפש קורס או גלול ברשימה:",
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 10),
              Autocomplete<Map<String, dynamic>>(
                displayStringForOption: (option) => option['name'] ?? '',
                optionsBuilder: (TextEditingValue textValue) {
                  if (textValue.text.isEmpty) return allCatalog;
                  return allCatalog.where(
                    (c) => c['name'].toString().toLowerCase().contains(
                      textValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (selection) => selectedCourse = selection,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ביטול"),
          ),
          ElevatedButton(
            onPressed: () async {
              // בדיקה אם נבחר קורס
              final courseInCatalog = allCatalog.any(
                (c) =>
                    selectedCourse != null &&
                    selectedCourse!['name'] == c['name'],
              );

              if (!courseInCatalog) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text("לא קיים קורס כזה במערכת"),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // בדיקה אם המשתמש כבר רשום לקורס
              bool alreadyEnrolled = myCourses.any(
                (c) =>
                    selectedCourse != null &&
                    selectedCourse!['courseId'] == c['courseId'],
              );

              if (alreadyEnrolled) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text("כבר רשום לקורס הזה"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (selectedCourse != null) {
                // ✅ שומרים את ה-navigator לפני ה-await
                final nav = Navigator.of(ctx);
                final success = await ApiService.enrollToCourse(
                  widget.userId,
                  selectedCourse!['courseId'],
                );
                if (!mounted) return;
                if (success) {
                  nav.pop();
                  _loadMyCourses();
                }
              }
            },
            child: const Text("הוסף"),
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
        backgroundColor: const Color(0xFFF5F1F8),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'הקורסים שלי',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3C88),
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : myCourses.isEmpty
                    ? const Center(child: Text("עדיין לא נרשמת לאף קורס"))
                    : ListView.builder(
                        itemCount: myCourses.length,
                        itemBuilder: (context, index) {
                          final course = myCourses[index];
                          final displayName =
                              course['name'] ?? "קורס: ${course['courseId']}";
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.book_rounded,
                                color: Color(0xFF1F3C88),
                              ),
                              title: Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("קוד: ${course['courseId']}"),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_sweep_outlined,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _confirmDelete(
                                  course['courseId'].toString(),
                                  displayName,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCourseDialog,
          backgroundColor: const Color(0xFF1F3C88),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PagePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingHeader(title: 'שלום', userName: currentUserName),
                const Text(
                  'הניקוד שלך: 150',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFF1F3C88),
              size: 32,
            ),
            onPressed: () async {
              final newName = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    userId: widget.userId,
                    userName: currentUserName,
                  ),
                ),
              );
              if (!mounted) return;
              if (newName != null) {
                setState(() => currentUserName = newName);
              }
            },
          ),
        ],
      ),
    );
  }
}

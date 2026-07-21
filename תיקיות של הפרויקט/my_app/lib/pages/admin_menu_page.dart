import 'package:flutter/material.dart';
import 'remove_student_page.dart';
import 'add_course_page.dart';
import 'delete_course_page.dart';
import 'promote_admin_page.dart'; // Imports the page for promoting a new administrator.

// A page that displays the administrator management menu.
class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color academicBlue = Color(0xFF1F3C88);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול קורסים וסטודנטים'),
          centerTitle: true,
          backgroundColor: academicBlue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          width: double.infinity,
          color: const Color(0xFFF0F4F8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(context, 'הסרת סטודנט', academicBlue, const RemoveStudentPage()),
              _buildMenuButton(context, 'הוספת קורס', academicBlue, const AddCoursePage()),
              _buildMenuButton(context, 'מחיקת קורס', academicBlue, const DeleteCoursePage()),
              
              // Adds the button for promoting a new administrator.
              _buildMenuButton(
                context, 
                'מינוי מנהל חדש', 
                academicBlue, 
                const PromoteAdminPage()
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a navigation button for the administrator menu.
  Widget _buildMenuButton(BuildContext context, String title, Color color, Widget destinationPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => destinationPage)
          ),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
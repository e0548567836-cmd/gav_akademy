import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // כתובת השרת המעודכנת (Port 5262 לפי הטרמינל שלך)
  static String get serverUrl {
    if (kIsWeb) {
      return 'http://localhost:5262/api';
    } else {
      // כתובת עבור אמולטור אנדרואיד למחשב המקומי
      return 'http://10.0.2.2:5262/api';
    }
  }

  // קיצורי דרך לנתיבים העיקריים
  static String get studentUrl => '$serverUrl/Student';
  static String get courseUrl => '$serverUrl/Course';
  static String get adminUrl => '$serverUrl/Admin';

  // -------------------------
  // פונקציות סטודנט (Student)
  // -------------------------

  static Future<http.Response> login(String id, String password) async {
    final url = Uri.parse('$studentUrl/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'StudentId': id, 'StudentPassword': password}),
    );
  }

  static Future<http.Response> register(Map<String, dynamic> studentData) async {
    final url = Uri.parse('$studentUrl/AddStudent');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studentData),
    );
  }

  static Future<Map<String, dynamic>?> getStudent(String id) async {
    try {
      final url = Uri.parse('$studentUrl/$id');
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error fetching student: $e");
    }
    return null;
  }

  static Future<http.Response> updateStudent(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$studentUrl/$id');
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<List<dynamic>> getAllCourses() async {
    try {
      final response = await http.get(Uri.parse('$courseUrl/GetAllCourses'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
    return [];
  }

  static Future<bool> enrollToCourse(String studentId, String courseId) async {
    final url = Uri.parse('$courseUrl/Enroll');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'StudentId': studentId,
        'CourseId': courseId,
        'IsAvailable': false,
        'IsInPerson': false,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getMyCourses(String studentId) async {
    try {
      final url = Uri.parse('$courseUrl/MyCourses/$studentId');
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error fetching my courses: $e");
    }
    return [];
  }

  static Future<bool> unenrollFromCourse(String userId, String courseId) async {
    try {
      final response = await http.delete(
        Uri.parse('$courseUrl/Unenroll/$userId/$courseId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error unenrolling: $e");
      return false;
    }
  }

  // -------------------------
  // פונקציות מנהל (Admin)
  // -------------------------

  static Future<List<dynamic>> getAllStudents() async {
    try {
      final url = Uri.parse('$adminUrl/GetStudents');
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
    return [];
  }

  static Future<http.Response> removeStudent(String id) async {
    final url = Uri.parse('$adminUrl/RemoveStudent/$id');
    return await http.delete(url);
  }

  // תיקון פונקציית הוספת קורס - התאמה לשמות השדות ב-Backend
  static Future<http.Response> addCourse(String id, String name, String description) async {
    final url = Uri.parse('$adminUrl/AddCourse');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "CourseId": id,
        "Name": name,         // שונה מ-CourseName ל-Name
        "Description": description, // ודאי שזה תואם ל-Description בשרת
      }),
    );
  }

  static Future<http.Response> removeCourse(String courseId) async {
    final url = Uri.parse('$adminUrl/RemoveCourse/$courseId');
    return await http.delete(url);
  }

  // שדרוג סטודנט למעמד מנהל
  static Future<bool> makeStudentAdmin(String id) async {
    try {
      final url = Uri.parse('$adminUrl/MakeAdmin/$id');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error promoting student to admin: $e");
      return false;
    }
  }
}
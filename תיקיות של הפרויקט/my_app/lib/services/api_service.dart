import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String serverUrl = 'http://localhost:5022/api';
  static const String studentUrl = '$serverUrl/Student';
  static const String courseUrl = '$serverUrl/Course';

  static Future<http.Response> login(String id, String password) async {
    final url = Uri.parse('$studentUrl/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'StudentId': id, 'StudentPassword': password}),
    );
  }

  static Future<http.Response> register(
    Map<String, dynamic> studentData,
  ) async {
    final url = Uri.parse('$studentUrl/AddStudent');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studentData),
    );
  }

  static Future<http.Response> updateStudent(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$studentUrl/$id');
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentName': data['studentName'],
        'studentEmail': data['studentEmail'],
        'studentPhone': data['studentPhone'],
      }),
    );
  }

  static Future<List<dynamic>> getAllCourses() async {
    try {
      final response = await http.get(Uri.parse('$courseUrl/GetAllCourses'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
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
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
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
}

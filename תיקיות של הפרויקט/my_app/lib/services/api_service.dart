import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get serverUrl {
    if (kIsWeb) {
      return 'http://localhost:5022/api';
    } else {
      return 'http://10.0.2.2:5022/api';
    }
  }

  static String get studentUrl => '$serverUrl/Student';
  static String get courseUrl => '$serverUrl/Course';
  static String get adminUrl => '$serverUrl/Admin';

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

  static Future<http.Response> updateStudent(
    String id,
    Map<String, dynamic> data,
  ) async {
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
        'CourseId': int.parse(courseId),
        'IsAvailable': false,
        'IsInPerson': false,
        'WantsHelp': true,
        'WantsToTeach': false,
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

  static Future<http.Response> addCourse(
    String id,
    String name,
    String description,
  ) async {
    final url = Uri.parse('$adminUrl/AddCourse');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'CourseId': int.parse(id),
        'Name': name,
        'Description': description,
      }),
    );
  }

  static Future<http.Response> removeCourse(String courseId) async {
    final url = Uri.parse('$adminUrl/RemoveCourse/$courseId');
    return await http.delete(url);
  }

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

  static Future<List<dynamic>> getMaterials(String courseId) async {
    try {
      final url = Uri.parse(
        '$serverUrl/Materials/GetMaterialsByCourse/$courseId',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error fetching materials: $e");
    }
    return [];
  }

  static Future<bool> deleteMaterial(String id) async {
    try {
      final url = Uri.parse('$serverUrl/Materials/DeleteMaterial/$id');
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error deleting material: $e");
      return false;
    }
  }

  static Future<bool> updateAvailability({
    required String studentId,
    required String courseId,
    required bool isAvailable,
    required bool isInPerson,
    required bool wantsToTeach,
    String? address,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final url = Uri.parse('$serverUrl/Availability/UpdateAvailability');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'courseId': courseId,
          'isAvailable': isAvailable,
          'isInPerson': isInPerson,
          'wantsToTeach': wantsToTeach,
          'wantsHelp': !wantsToTeach,
          'address': address,
          'maxDistanceKm': maxDistanceKm,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      debugPrint('UpdateAvailability status: ${response.statusCode}');
      debugPrint('UpdateAvailability body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating availability: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getAvailableStudents({
    required String studentId,
    required String courseId,
    required bool isInPerson,
    required bool wantsToTeach,
    double? latitude,
    double? longitude,
    double? distanceKm,
  }) async {
    try {
      final uri = Uri.parse('$serverUrl/Availability/AvailableStudents')
          .replace(
        queryParameters: {
          'studentId': studentId,
          'courseId': courseId,
          'isInPerson': isInPerson.toString(),
          'wantsToTeach': wantsToTeach.toString(),
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
          if (distanceKm != null) 'distanceKm': distanceKm.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      debugPrint('GetAvailableStudents status: ${response.statusCode}');
      debugPrint('GetAvailableStudents body: ${response.body}');
    } catch (e) {
      debugPrint('Error fetching available students: $e');
    }

    return [];
  }
}
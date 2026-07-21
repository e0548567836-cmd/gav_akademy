import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Provides methods for communicating with the application's REST API.
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

  /// Authenticates a user.
  static Future<http.Response> login(String id, String password) async {
    final url = Uri.parse('$studentUrl/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'StudentId': id, 'StudentPassword': password}),
    );
  }

  /// Registers a new student.
  static Future<http.Response> register(Map<String, dynamic> studentData) async {
    final url = Uri.parse('$studentUrl/AddStudent');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studentData),
    );
  }

  /// Retrieves a student's information.
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

  /// Updates a student's information.
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

  /// Retrieves all available courses.
  static Future<List<dynamic>> getAllCourses() async {
    try {
      final response = await http.get(Uri.parse('$courseUrl/GetAllCourses'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
    return [];
  }

  /// Enrolls a student in a course.
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
        'WantsHelp': true,
        'WantsToTeach': false,
        'WantsPartner': false,
      }),
    );

    return response.statusCode == 200;
  }

  /// Retrieves the courses of a specific student.
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

  /// Removes a student from a course.
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

  /// Retrieves all registered students.
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

  /// Removes a student from the system.
  static Future<http.Response> removeStudent(String id) async {
    final url = Uri.parse('$adminUrl/RemoveStudent/$id');
    return await http.delete(url);
  }

  /// Adds a new course.
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
        'CourseId': id,
        'Name': name,
        'Description': description,
      }),
    );
  }

  /// Removes a course from the system.
  static Future<http.Response> removeCourse(String courseId) async {
    final url = Uri.parse('$adminUrl/RemoveCourse/$courseId');
    return await http.delete(url);
  }

  /// Promotes a student to an administrator.
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

  /// Retrieves the materials of a course.
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

  /// Deletes a course material.
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

  /// Updates a student's availability preferences.
  static Future<bool> updateAvailability({
    required String studentId,
    required String courseId,
    required bool isAvailable,
    required bool isInPerson,
    required bool wantsToTeach,
    required bool wantsPartner,
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
          'wantsPartner': wantsPartner,
          'wantsHelp': !wantsToTeach && !wantsPartner,
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

  /// Retrieves the list of users the given user has exchanged messages with.
  static Future<List<dynamic>> getConversations(String userId) async {
    try {
      final uri = Uri.parse(
        '$serverUrl/Chat/Conversations',
      ).replace(queryParameters: {'userId': userId});
      final response = await http.get(uri);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
    }
    return [];
  }

  /// Retrieves the chat history between two users.
  static Future<List<dynamic>> getChatHistory(
    String userId1,
    String userId2,
  ) async {
    try {
      final uri = Uri.parse('$serverUrl/Chat/History').replace(
        queryParameters: {'userId1': userId1, 'userId2': userId2},
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
    }
    return [];
  }

  /// Retrieves the list of available students for a course.
  static Future<List<dynamic>> getAvailableStudents({
    required String studentId,
    required String courseId,
    required bool isInPerson,
    required bool wantsToTeach,
    required bool wantsPartner,
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
          'wantsPartner': wantsPartner.toString(),
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
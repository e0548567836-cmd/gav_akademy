import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ב-Web (Chrome) אנחנו משתמשים ב-localhost ובפורט המדויק מה-Swagger
  static const String baseUrl = 'https://localhost:7066/api/Student';

  // התחברות
  static Future<http.Response> login(String id, String password) async {
    final url = Uri.parse('$baseUrl/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'StudentId': id, 'StudentPassword': password}),
    );
  }

  // הרשמה
  static Future<http.Response> register(
    Map<String, dynamic> studentData,
  ) async {
    final url = Uri.parse('$baseUrl/AddStudent');
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
    final url = Uri.parse('$baseUrl/$id');
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': id, // השרת חייב לקבל את ה-ID גם כאן בתוך ה-JSON!
        'studentName': data['studentName'],
        'studentEmail': data['studentEmail'],
        'studentPhone': data['studentPhone'],
      }),
    );
  }
}

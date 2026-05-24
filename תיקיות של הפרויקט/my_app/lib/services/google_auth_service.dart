import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_service.dart'; // ייבוא של ה-ApiService

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<Map<String, dynamic>?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      // שימוש ב-serverUrl שהגדרנו ב-ApiService במקום לכתוב ידנית 5022
      final response = await http.post(
        Uri.parse('${ApiService.serverUrl}/Student/google-signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'name': account.displayName ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

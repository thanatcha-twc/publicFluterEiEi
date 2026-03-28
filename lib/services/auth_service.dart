import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quick_jobs/models/auth_response.dart';
import 'package:quick_jobs/models/login_result.dart';
import 'package:quick_jobs/models/user.dart' as app_user;

class AuthService {
  static const String _baseUrl = 'https://api.rmutsv.ac.th/elogin';

  Future<LoginResult> login(
    String username,
    String password, {
    required String role,
  }) async {
    final normalizedRole = role.toLowerCase();

    if (normalizedRole == 'professor') {
      // Strict professor login validation
      if (username.trim().toLowerCase() == 'professor' &&
          password == '123456') {
        final user = app_user.User.fakeProfessor();
        return LoginResult(user: user, message: 'success');
      } else {
        return LoginResult(
          user: null,
          message:
              'Invalid professor credentials. Username must be "professor" and password must be "123456"',
        );
      }
    }

    if (normalizedRole == 'student') {
      // Student login via RMUTSV API
      try {
        final body = {
          'username': username,
          'password': password,
          'role': 'student',
        };
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return LoginResult(
            user: null,
            message: 'Network error ${response.statusCode}',
          );
        }

        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonResponse);

        if (authResponse.status != 'ok') {
          return LoginResult(
            user: null,
            message: 'Login failed: ${authResponse.status}',
          );
        }

        final user = app_user.User.fromAuthResponse(authResponse);
        return LoginResult(user: user, message: 'success');
      } catch (e) {
        return LoginResult(user: null, message: 'Exception: $e');
      }
    }

    // Invalid role
    return LoginResult(user: null, message: 'Invalid role specified');
  }

  // Token Verification API
  Future<app_user.User?> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/token/token?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonResponse);
        if (authResponse.status == 'ok') {
          return app_user.User.fromAuthResponse(authResponse);
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
}

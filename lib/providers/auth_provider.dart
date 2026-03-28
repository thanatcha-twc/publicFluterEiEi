import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:quick_jobs/models/user.dart' as app_user;
import 'package:quick_jobs/services/auth_service.dart';
import 'package:quick_jobs/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  app_user.User? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isStudent => _user?.role == 'student';
  bool get isProfessor => _user?.role == 'professor';
  String get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.login(username, password);
      if (result.success && result.user != null) {
        _user = result.user;
        // เพิ่ม: บันทึก user ลง Supabase ทุกครั้งหลัง login สำเร็จ
        try {
          await SupabaseService().ensureUserExists(_user!);
        } catch (e) {
          debugPrint('[AuthProvider] Failed to ensure user exists: $e');
        }
        await _saveUserToPrefs(_user!);
      } else {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _clearUserFromPrefs();
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = app_user.User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(app_user.User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}

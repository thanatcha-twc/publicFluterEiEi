import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AppUser?> login(String username, String password) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (data == null) return null;

      return AppUser.fromJson(data);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
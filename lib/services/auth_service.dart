import 'package:quick_jobs/models/login_result.dart';
import 'package:quick_jobs/services/supabase_service.dart';

class AuthService {
  Future<LoginResult> login(String username, String password) async {
    try {
      final user = await SupabaseService().getUserByUsernameAndPassword(
        username,
        password,
      );
      if (user != null) {
        String role = user.role; // ดึง role จาก user
        // ใช้ role ต่อได้เลย เช่น
        if (role == 'student') {
          // ทำอะไรสำหรับนักศึกษา
        } else if (role == 'professor') {
          // ทำอะไรสำหรับอาจารย์
        }
        return LoginResult(user: user, message: 'success');
      } else {
        return LoginResult(user: null, message: 'Invalid username or password');
      }
    } catch (e) {
      return LoginResult(user: null, message: 'ติดต่อดาต้าเบสไม่ได้');
    }
  }
}

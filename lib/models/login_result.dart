import 'package:quick_jobs/models/user.dart';

class LoginResult {
  final User? user;
  final String message;

  LoginResult({required this.user, required this.message});

  bool get success => user != null;
}

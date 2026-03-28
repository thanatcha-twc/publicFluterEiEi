import 'auth_response.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'student' or 'professor'
  final String? token;
  final String? faculty;
  final String? department;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
    this.faculty,
    this.department,
  });

  factory User.fromAuthResponse(AuthResponse response) {
    return User(
      id: response.cid ?? '',
      email: response.email ?? '',
      name: response.name ?? '',
      role: response.type?.toLowerCase().contains('professor') == true
          ? 'professor'
          : 'student',
      token: response.token,
      faculty: response.facname,
      department: response.depname,
    );
  }

  // For fake professor login
  factory User.fakeProfessor() {
    return User(
      id: 'professor_001',
      email: 'professor@example.com',
      name: 'Professor Example',
      role: 'professor',
      token: 'fake_token',
      faculty: 'Engineering',
      department: 'Computer Science',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'token': token,
      'faculty': faculty,
      'department': department,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      token: json['token'],
      faculty: json['faculty'],
      department: json['department'],
    );
  }
}

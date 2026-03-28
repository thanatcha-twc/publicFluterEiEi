import 'auth_response.dart';

class User {
  final String id;
  final String username;
  final String name;
  final String role; // 'student' or 'professor'
  final String? token;
  final String? faculty;
  final String? department;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.token,
    this.faculty,
    this.department,
  });

  // factory User.fromAuthResponse(AuthResponse response) {
  //   return User(
  //     id: response.cid ?? '',
  //     username: response.username ?? '',
  //     name: response.name ?? '',
  //     role: response.type?.toLowerCase().contains('professor') == true
  //         ? 'professor'
  //         : 'student',
  //     token: response.token,
  //     faculty: response.facname,
  //     department: response.depname,
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
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
      username: json['username'],
      name: json['name'],
      role: json['role'],
      token: json['token'],
      faculty: json['faculty'],
      department: json['department'],
    );
  }
}

class AppUser {
  final String id;
  final String username;
  final String role;
  final String fullName;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.fullName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      fullName: json['full_name'] ?? '',
    );
  }
}
class AuthResponse {
  final String status;
  final String? cid;
  final String? username;
  final String? name;
  final String? type;
  final String? faccode;
  final String? facname;
  final String? depcode;
  final String? depname;
  final String? seccode;
  final String? secname;
  final String? email;
  final String? token;

  AuthResponse({
    required this.status,
    this.cid,
    this.username,
    this.name,
    this.type,
    this.faccode,
    this.facname,
    this.depcode,
    this.depname,
    this.seccode,
    this.secname,
    this.email,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? '',
      cid: json['cid'],
      username: json['username'],
      name: json['name'],
      type: json['type'],
      faccode: json['faccode'],
      facname: json['facname'],
      depcode: json['depcode'],
      depname: json['depname'],
      seccode: json['seccode'],
      secname: json['secname'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'cid': cid,
      'username': username,
      'name': name,
      'type': type,
      'faccode': faccode,
      'facname': facname,
      'depcode': depcode,
      'depname': depname,
      'seccode': seccode,
      'secname': secname,
      'email': email,
      'token': token,
    };
  }
}
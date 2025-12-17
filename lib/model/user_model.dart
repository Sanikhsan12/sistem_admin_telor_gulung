class UserModel {
  final String email;
  final String name;
  final String role;
  final String status;

  UserModel({
    required this.email,
    required this.name,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'name': name, 'role': role, 'status': status};
  }
}

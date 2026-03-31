enum UserRole { operator, supervisor, admin }

class User {
  final String username;
  final UserRole role;

  User({required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role.toString().split('.').last,
    };
  }
}
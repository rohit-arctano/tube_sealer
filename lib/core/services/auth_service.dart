import '../models/user.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User?> login(String username, String password) async {
    // Secure credentials should be stored and checked from a local secured storage/DB in production.
    final credentials = {
      'Admin': '0000',
      'Supervisor': '1111',
      'Operator': '2222',
    };

    if (credentials.containsKey(username) && credentials[username] == password) {
      final role = username == 'Admin'
          ? UserRole.admin
          : username == 'Supervisor'
              ? UserRole.supervisor
              : UserRole.operator;
      _currentUser = User(username: username, role: role);
      return _currentUser;
    }

    return null;
  }

  Future<User?> loginRole(UserRole role) async {
    _currentUser = User(username: role.toString().split('.').last, role: role);
    return _currentUser;
  }

  void logout() {
    _currentUser = null;
  }
}
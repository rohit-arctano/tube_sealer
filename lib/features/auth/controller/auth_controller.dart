import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<User?> loginRole(UserRole role) async {
    return await _authService.loginRole(role);
  }

  void logout() {
    _authService.logout();
  }

  User? get currentUser => _authService.currentUser;
}
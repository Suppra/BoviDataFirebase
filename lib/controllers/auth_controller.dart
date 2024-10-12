import '../services/firebase_auth_service.dart';

class AuthController {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<void> login(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> register(String email, String password, String userType) async {
    await _authService.register(email, password, userType);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}

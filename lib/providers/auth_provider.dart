import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.currentUser != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await _authService.login(email, password);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await _authService.register(email, password);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}

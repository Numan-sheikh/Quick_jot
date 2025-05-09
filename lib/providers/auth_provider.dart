import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:logger/logger.dart'; // Import the logger library

// Create a logger instance for the AuthProvider
final logger = Logger();

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.currentUser != null;

  // Constructor (optional, but good place for initial logging if needed)
  AuthProvider() {
    logger.i('AuthProvider instance created');
  }

  Future<void> login(String email, String password) async {
    logger.d('Attempting login for email: $email');
    _isLoading = true;
    notifyListeners();
    logger.d('_isLoading set to true, notifying listeners');

    try {
      await _authService.login(email, password);
      logger.i('Login successful for email: $email');
    } catch (e) {
      logger.e('Error during login for email: $email', error: e);
      // Re-throw the error so the calling widget can handle it (e.g., show a SnackBar)
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      logger.d('_isLoading set to false, notifying listeners');
      logger.d('Login attempt finished');
    }
  }

  Future<void> register(String email, String password) async {
    logger.d('Attempting registration for email: $email');
    _isLoading = true;
    notifyListeners();
    logger.d('_isLoading set to true, notifying listeners');

    try {
      await _authService.register(email, password);
      logger.i('Registration successful for email: $email');
    } catch (e) {
      logger.e('Error during registration for email: $email', error: e);
      // Re-throw the error so the calling widget can handle it
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      logger.d('_isLoading set to false, notifying listeners');
      logger.d('Registration attempt finished');
    }
  }

  Future<void> logout() async {
    logger.d('Attempting logout');
    try {
      await _authService.logout();
      logger.i('Logout successful');
      notifyListeners();
      logger.d('Notifying listeners after logout');
    } catch (e) {
      logger.e('Error during logout', error: e);
      // Re-throw the error if necessary for UI handling
      rethrow;
    }
  }
}

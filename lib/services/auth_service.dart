import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart'; // Import the logger library

// Create a logger instance for the AuthService
final logger = Logger();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor (The logger instance is created when AuthService is instantiated)
  AuthService() {
    logger.i('AuthService instance created');
    // You could optionally add a listener here for auth state changes if needed,
    // but for basic method logging, the individual method logs are sufficient.
  }

  User? get currentUser {
    final user = _auth.currentUser;
    // logger.v('Getting current user: ${user?.uid}'); // Use verbose if this is too chatty
    return user;
  }

  Future<User?> register(String email, String password) async {
    logger.d('Attempting user registration for email: $email');
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.i('User registered successfully. UID: ${userCred.user?.uid}');
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      logger.w(
        'Firebase Auth Exception during registration: code=${e.code}, message=${e.message}',
      );
      // Rethrow the specific Firebase Auth exception for handling in AuthProvider/UI
      rethrow;
    } catch (e) {
      logger.e(
        'An unexpected error occurred during registration for email: $email',
        error: e,
      );
      // Rethrow any other unexpected errors
      rethrow;
    } finally {
      logger.d('Registration attempt finished for email: $email');
    }
  }

  Future<User?> login(String email, String password) async {
    logger.d('Attempting user login for email: $email');
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.i('User logged in successfully. UID: ${userCred.user?.uid}');
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      logger.w(
        'Firebase Auth Exception during login: code=${e.code}, message=${e.message}',
      );
      // Rethrow the specific Firebase Auth exception
      rethrow;
    } catch (e) {
      logger.e(
        'An unexpected error occurred during login for email: $email',
        error: e,
      );
      // Rethrow any other unexpected errors
      rethrow;
    } finally {
      logger.d('Login attempt finished for email: $email');
    }
  }

  Future<void> logout() async {
    logger.d('Attempting user logout');
    try {
      await _auth.signOut();
      logger.i('User logged out successfully');
    } on FirebaseAuthException catch (e) {
      logger.w(
        'Firebase Auth Exception during logout: code=${e.code}, message=${e.message}',
      );
      // Rethrow the specific Firebase Auth exception
      rethrow;
    } catch (e) {
      logger.e('An unexpected error occurred during logout', error: e);
      // Rethrow any other unexpected errors
      rethrow;
    } finally {
      logger.d('Logout attempt finished');
    }
  }
}

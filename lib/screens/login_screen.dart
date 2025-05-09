import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; // Import the logger library
import '../providers/auth_provider.dart'; // Make sure this path is correct
import 'home_screen.dart'; // Make sure this path is correct

// Create a logger instance
final logger = Logger();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = true; // Start true to show loader while pre-filling

  @override
  void initState() {
    super.initState();
    logger.i('LoginScreen initState called');
    // didChangeDependencies is suitable for this one-time setup.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger.i('LoginScreen didChangeDependencies called');
    // Load saved details only if we haven't done it yet (indicated by _isLoading being true)
    if (_isLoading) {
      logger.d('Loading and pre-filling saved details...');
      _loadAndPreFillSavedDetails();
    }
  }

  @override
  void dispose() {
    logger.i('LoginScreen dispose called');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAndPreFillSavedDetails() async {
    logger.d('_loadAndPreFillSavedDetails started');
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) {
        logger.w('_loadAndPreFillSavedDetails called on unmounted widget');
        return;
      }

      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');

      if (savedEmail != null && savedPassword != null) {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        logger.i('Pre-filled credentials from SharedPreferences');
        // Update _rememberMe state and UI
        setState(() {
          _rememberMe = true;
          logger.d('_rememberMe set to true');
        });
      } else {
        logger.d('No saved credentials found in SharedPreferences');
      }
    } catch (e) {
      logger.e('Error loading saved details: $e');
    } finally {
      // Finished loading/pre-filling, now show the form
      if (mounted) {
        setState(() {
          _isLoading = false;
          logger.d('_isLoading set to false, showing form');
        });
      }
      logger.d('_loadAndPreFillSavedDetails finished');
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    logger.d('_saveCredentials started');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        logger.i('Credentials saved to SharedPreferences');
      } else {
        await prefs.remove('email');
        await prefs.remove('password');
        logger.i('Credentials removed from SharedPreferences');
      }
    } catch (e) {
      logger.e('Error saving credentials: $e');
    } finally {
      logger.d('_saveCredentials finished');
    }
  }

  Future<void> _submitForm() async {
    logger.d('_submitForm started');
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      logger.w('Email or password is empty');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password cannot be empty.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true); // Show loader for submission
      logger.d('_isLoading set to true for submission');
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isLogin) {
        logger.i('Attempting login for email: $email');
        await authProvider.login(email, password);
        logger.i('Login attempt finished');
      } else {
        logger.i('Attempting registration for email: $email');
        await authProvider.register(email, password);
        logger.i('Registration attempt finished');
      }

      if (!mounted) {
        logger.w('_submitForm processing on unmounted widget after auth call');
        return;
      }

      if (authProvider.isAuthenticated) {
        logger.i('Authentication successful');
        await _saveCredentials(email, password);
        if (!mounted) {
          logger.w(
            '_submitForm processing on unmounted widget after saving credentials',
          );
          return;
        }
        logger.i('Navigating to HomeScreen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        logger.w('Authentication failed: Invalid credentials');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials, please try again.'),
          ),
        );
      }
    } catch (e) {
      logger.e('An error occurred during authentication: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Hide loader
        logger.d('_isLoading set to false, hiding loader');
      }
      logger.d('_submitForm finished');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.t('LoginScreen build method called');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
              _isLoading // Handles both initial pre-fill loading and submission loading
                  ? const CircularProgressIndicator()
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLogin
                              ? Icons.lock_outline
                              : Icons.person_add_alt_1,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create an Account',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Enter your details to login' // Updated text
                              : 'Fill in the details to register', // Updated text
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(
                              177,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[850] : Colors.grey[100],
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                                logger.d('Password visibility toggled');
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[850] : Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() => _rememberMe = val ?? false);
                                logger.d(
                                  'Remember me checkbox toggled: $_rememberMe',
                                );
                              },
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              _isLogin ? Icons.login : Icons.person_add,
                            ),
                            label: Text(_isLogin ? 'Login' : 'Register'),
                            onPressed:
                                _isLoading
                                    ? null
                                    : _submitForm, // Disable button while loading
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() => _isLogin = !_isLogin);
                            logger.i('Toggled between Login and Register');
                          },
                          child: Text(
                            _isLogin
                                ? 'Don’t have an account? Register'
                                : 'Already have an account? Login',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}

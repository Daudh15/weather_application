import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_application/firebase_auth_implementation/firebase_auth_services.dart';

import 'glassmorphic_container.dart';
import 'theme_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    try {
      User? user = await _auth.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        await user.updateDisplayName(_usernameController.text);
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Failed to create account';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'This email is already registered';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email format';
            break;
          case 'weak-password':
            _errorMessage = 'Password should be at least 6 characters';
            break;
          case 'operation-not-allowed':
            _errorMessage = 'Email/Password sign-in is disabled';
            break;
          case 'network-request-failed':
            _errorMessage = 'Network error. Please check your connection';
            break;
          default:
            _errorMessage = 'Authentication error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkTheme
                ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withOpacity(0.3),
                        Colors.orange.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(Icons.cloud, size: 80, color: Colors.amber),
                ),
                const SizedBox(height: 16),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Weather Pro',
                      textStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkTheme
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkTheme
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkTheme
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkTheme
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkTheme
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkTheme
                        ? Colors.cyan.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.1),
                    foregroundColor: themeProvider.isDarkTheme
                        ? Colors.cyan
                        : Colors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: themeProvider.isDarkTheme
                            ? Colors.cyan
                            : Colors.blue,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: themeProvider.isDarkTheme
                              ? Colors.cyan
                              : Colors.blue,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Already have an account? Log In',
                    style: TextStyle(
                      color: themeProvider.isDarkTheme
                          ? Colors.cyan
                          : Colors.blue,
                      fontSize: 14,
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

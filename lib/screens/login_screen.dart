import 'package:flutter/material.dart';
import 'package:shopngo/services/auth_service.dart';

// Color Palette
class AppColors {
  static const Color backgroundColor = Color(0xFFFFF2F2);
  static const Color lightBlue = Color(0xFFA9B5DF);
  static const Color mediumBlue = Color(0xFF7886C7);
  static const Color darkBlue = Color(0xFF2D336B);
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center( // Center the entire content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically within the column
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center, // Center text
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue shopping',
                    textAlign: TextAlign.center, // Center text
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.mediumBlue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Email Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.mediumBlue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.darkBlue),
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) => setState(() => email = val),
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: AppColors.mediumBlue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.darkBlue),
                      ),
                    ),
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                    onChanged: (val) => setState(() => password = val),
                  ),
                  const SizedBox(height: 30),
                  // Login Button
                  isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              dynamic result = await _auth.login(
                                email: email,
                                password: password,
                              );
                              if (result == null) {
                                setState(() {
                                  error = 'Could not sign in with those credentials';
                                  isLoading = false;
                                });
                              } else {
                                if (result.role == 'seller') {
                                  Navigator.pushReplacementNamed(context, '/sellerhome');
                                } else {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 16)),
                        ),
                  const SizedBox(height: 12),
                  // Error Message
                  if (error.isNotEmpty)
                    Text(
                      error,
                      textAlign: TextAlign.center, // Center text
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 20),
                  // Sign Up Link
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: Text(
                      'Need an account? Sign up',
                      textAlign: TextAlign.center, // Center text
                      style: TextStyle(color: AppColors.mediumBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
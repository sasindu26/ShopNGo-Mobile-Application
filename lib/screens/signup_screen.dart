import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// Color Palette
class AppColors {
  static const Color backgroundColor = Color(0xFFFFF2F2);
  static const Color lightBlue = Color(0xFFA9B5DF);
  static const Color mediumBlue = Color(0xFF7886C7);
  static const Color darkBlue = Color(0xFF2D336B);
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';
  String address = ''; // New address field
  String role = 'buyer';
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join us as a buyer or seller',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.mediumBlue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
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
                    validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                    onChanged: (val) => setState(() => name = val),
                  ),
                  const SizedBox(height: 20),
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
                    validator: (val) {
                      if (val!.isEmpty) return 'Enter an email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
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
                  const SizedBox(height: 20),
                  // Address Field (New)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
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
                    validator: (val) => val!.isEmpty ? 'Enter your address' : null,
                    onChanged: (val) => setState(() => address = val),
                  ),
                  const SizedBox(height: 20),
                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: role,
                    items: ['buyer', 'seller'].map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role.capitalize()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => role = val!),
                    decoration: InputDecoration(
                      labelText: 'Role',
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
                  ),
                  const SizedBox(height: 30),
                  // Sign Up Button
                  isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              try {
                                dynamic result = await _auth.signUp(
                                  email: email.trim(),
                                  password: password,
                                  name: name,
                                  role: role,
                                  address: address, // Pass address to signUp
                                );
                                if (result != null) {
                                  if (result.role == 'seller') {
                                    Navigator.pushReplacementNamed(context, '/sellerhome');
                                  } else {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  }
                                }
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  switch (e.code) {
                                    case 'email-already-in-use':
                                      error = 'This email is already registered';
                                      break;
                                    case 'invalid-email':
                                      error = 'Please enter a valid email address';
                                      break;
                                    case 'weak-password':
                                      error = 'Password is too weak';
                                      break;
                                    default:
                                      error = 'An error occurred: ${e.message}';
                                  }
                                });
                              } catch (e) {
                                setState(() {
                                  error = 'An unexpected error occurred';
                                });
                              } finally {
                                setState(() => isLoading = false);
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
                          child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                        ),
                  const SizedBox(height: 12),
                  // Error Message
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
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

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/forgot_password_pages/forgot_password_page.dart';
import 'package:pill_buddy/pages/login_pages/google_signin_page.dart';
import 'package:pill_buddy/pages/main_pages/main_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/register_pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Track the loading state
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var logger = Logger();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Sign in user with Firebase
  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        showFrontToastSuccess(
            context, "Login successful!"); // Show success message
        // Navigate to the main page after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";

      // Check the error codes properly
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided for that user.";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid email format.";
      } else if (e.code == 'too-many-requests') {
        message = "Too many requests, please try again later.";
      } else if (e.code == 'operation-not-allowed') {
        message = "Email/password sign-in is not enabled.";
      } else if (e.code == 'network-request-failed') {
        message = "Network error, please check your connection.";
      } else if (e.code == 'user-disabled') {
        message = "User account has been disabled.";
      } else if (e.code == 'email-already-in-use') {
        message = "Email already in use, please use a different email.";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak.";
      } else if (e.code == 'operation-not-supported') {
        message = "Operation not supported, please contact support.";
      } else if (e.code == 'invalid-verification-code') {
        message = "Invalid verification code.";
      } else if (e.code == 'invalid-verification-id') {
        message = "Invalid verification ID.";
      } else if (e.code == 'missing-verification-code') {
        message = "Missing verification code.";
      } else if (e.code == 'missing-verification-id') {
        message = "Missing verification ID.";
      } else if (e.code == 'user-token-expired') {
        message = "User token expired, please log in again.";
      } else {
        message =
            e.message ?? message; // Use the error message provided by Firebase
      }
      logger.e("Firebase error code: ${e.code}");
      logger.e("Error message: ${e.message}");

      // Show error message
      showFrontToastError(context, message);
    } catch (e) {
      // Catch any other errors
      showFrontToastError(context, "Unexpected error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void showFrontToastSuccess(BuildContext context, String text) {
    _showFrontToast(
      context,
      text,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }

  void showFrontToastError(BuildContext context, String text) {
    _showFrontToast(
      context,
      text,
      backgroundColor: Colors.red.shade500,
      icon: Icons.error,
    );
  }

  void _showFrontToast(
    BuildContext context,
    String text, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: (ctx) {
      final topInset = MediaQuery.of(ctx).viewInsets.top;
      return Positioned(
        top: topInset + 60,
        left: 16,
        right: 16,
        child: Material(
          color: backgroundColor,
          elevation: 3,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MedicationProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        // Make the entire body scrollable
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
            .onDrag, // Dismiss keyboard on drag
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                // Welcome Message
                Text(
                  "Welcome back!\nGlad to see you, Again!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 30),

                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  onChanged: (email) {
                    auth.inputEmail(email);
                  },
                ),
                const SizedBox(height: 15),

                // Password TextField with Eye Icon
                TextField(
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  onChanged: (password) {
                    auth.inputPassword(password);
                  },
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Add Forgot Password action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _signInWithEmailPassword(); // Call the sign-in method

                      logger.e(
                          'password and email: ${auth.inputtedEmail}\npassword: ${auth.inputtedPassword}');
                      // Add Login action
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const MainPage()),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary, // Your theme color
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // Show loading indicator if loading
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                // "OR" Separator
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 15),

                // Continue with Google Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Add Google login action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GoogleSIgninPage()),
                      );
                    },
                    icon: Image.asset("assets/images/google_logo.png",
                        height: 20), // Add Google logo in assets
                    label: Text(
                      "Continue with Google",
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    TextButton(
                      onPressed: () {
                        // Navigate to Register Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text(
                    'Back',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

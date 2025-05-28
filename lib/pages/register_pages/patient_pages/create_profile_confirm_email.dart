// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/login_pages/login_page.dart';
import 'package:pill_buddy/pages/main_pages/main_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/user_input_confirmation_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/user_input_confirmation_page.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_hope_to_achieve_page.dart';

class CreateProfileConfirmEmailPage extends StatefulWidget {
  const CreateProfileConfirmEmailPage({super.key});

  @override
  State<CreateProfileConfirmEmailPage> createState() =>
      _CreateProfileConfirmEmailPageState();
}

class _CreateProfileConfirmEmailPageState
    extends State<CreateProfileConfirmEmailPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isButtonEnabled = false;
  var logger = Logger();

  final _auth = FirebaseAuth.instance;

  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_checkInputs);
    _passwordController.addListener(_checkInputs);

    _confirmPasswordController.addListener(_checkInputs);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  void _checkInputs() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  // @override
  // void dispose() {
  //   _controller.dispose();

  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   _confirmPasswordController.dispose();
  //   super.dispose();
  // }

//TODO : uncomment the email and password validation functions
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  void _validateAndProceed() {
    if (!_formKey.currentState!.validate()) return;
    _firebaseSentEmailPass();
  }

  Future<void> _firebaseSentEmailPass() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.i("User created successfully.");

      final newUser = userCredential.user;
      if (newUser == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User object is null after registration.',
        );
      }

      // Send email verification
      await newUser.sendEmailVerification();
      logger.i("Verification email sent successfully.");

      // Optionally: store email/password in your own provider
      Provider.of<MedicationProvider>(context, listen: false)
          .inputEmail(email); // or use a dedicated AuthProvider

      Provider.of<MedicationProvider>(context, listen: false)
          .inputPassword(_passwordController.text);
      logger.i("Provider called");

      Navigator.of(context).pop(); // remove the loading dialog
      _showVerifyEmailDialog();

      logger.i("_showVerifyEmailDialog() called");
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // remove loading
      String message = "An error occurred";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.e("No user is currently signed in.");
      return false;
    }

    await user.reload(); // Fetch the latest state
    return user.emailVerified;
  }

  Future<void> _showVerifyEmailDialog() async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 80, color: primaryColor),
              const SizedBox(height: 24),
              const Text(
                'Verify your email address',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'We have just sent an email verification link to your email. '
                'Please check your email and click that link to verify your email address.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'If not auto-redirected after verification, click the Continue button.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    // Start a Timer that checks every second
                    Timer.periodic(const Duration(seconds: 1), (timer) async {
                      final verified = await checkEmailVerified();
                      if (verified) {
                        // Stop the timer once the email is verified
                        timer.cancel();
                        logger.i("Email verified.");
                        showFrontToastSuccess(context, 'Email verified! 🎉');
                        Navigator.of(context).pop(); // close dialog

                        // Navigator.of(context).pushReplacement(
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         const UserInputConfirmationPage(),
                        //   ),
                        // );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const UserInputConfirmationPage()),
                          (Route<dynamic> route) =>
                              false, // This will remove all previous routes
                        );
                      } else {
                        logger.i("Email not verified yet.");
                        showFrontToastError(context, 'Email not verified yet.');
                      }
                    });
                  },
                  child: const Text('Continue',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  // 1) Make sure there’s a signed-in user
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    logger.e("No user is currently signed in.");
                    showFrontToastError(
                        context, 'No user is currently signed in.');
                    return;
                  }

                  // 2) Refresh from server, then check
                  await user.reload();
                  if (user.emailVerified) {
                    logger.i("Email already verified.");
                    showFrontToastSuccess(
                        context, 'Email already verified! 🎉');
                    return; // ← stop here, no resend
                  }

                  // 3) Not verified → try to resend
                  try {
                    await user.sendEmailVerification();
                    showFrontToastSuccess(
                        context, 'Verification email resent.');
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'too-many-requests') {
                      showFrontToastError(
                          context, 'Please wait a bit before trying again.');
                    } else {
                      showFrontToastError(context,
                          'Error resending verification email: ${e.message}');
                    }
                  }
                },
                child: const Text('Resend E-mail Link'),
              ),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // close dialog
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFrontToastSuccess(BuildContext context, String text) {
    _showFrontToast(
      context,
      text,
      backgroundColor: Theme.of(context).colorScheme.primary,
      icon: Icons.check_circle,
    );
  }

  void showFrontToastError(BuildContext context, String text) {
    _showFrontToast(
      context,
      text,
      backgroundColor: Colors.red.shade600,
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
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
      return Positioned(
        bottom: bottomInset + 16,
        left: 16,
        right: 16,
        child: Material(
          color: backgroundColor,
          elevation: 6,
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents graying effect when scrolling
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Animated Email Icon
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Icon(Icons.email, size: 80, color: primaryColor),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Let's create your account\nto ensure your info is backed up",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  const Text(
                    "A confirmation message will be sent to your email",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      } else if (!_isValidEmail(value.trim())) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword1,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword1
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword1 = !_obscurePassword1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      } else if (!_isValidPassword(value)) {
                        return "Invalid password format";
                      }
                      return null;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password must be at least: 6 characters long, an uppercase and lowercase letter, and a digit",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword2,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword2
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword2 = !_obscurePassword2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      } else if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 130),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentMaterialBanner();
                              _validateAndProceed();
                              logger.e("Email: ${_emailController.text}");
                              logger.e("Password: ${_passwordController.text}");
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

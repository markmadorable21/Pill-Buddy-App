// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var logger = Logger();
  bool _isButtonEnabled = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkEmailInput);
  }

  void _checkEmailInput() {
    setState(() {
      _isButtonEnabled = _isValidEmail(_emailController.text.trim());
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  Future<void> _sendVerificationEmail() async {
    final email = _emailController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: "TempPass123!", // Temporary strong password
      );

      final newUser = userCredential.user;
      if (newUser == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User object is null after creation.',
        );
      }

      await newUser.sendEmailVerification();

      Navigator.of(context).pop(); // Remove loading

      await _showVerifyEmailDialog();

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Remove loading
      String message = "An error occurred";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered as a patient.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<bool> _checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return user.emailVerified;
  }

  Future<void> _showVerifyEmailDialog() async {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.email, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Verify patient email'),
          ],
        ),
        content: const Text(
          'A verification email has been sent to the patient\'s email address.\n\n'
          'Please ask the patient to check their email and click the verification link to confirm their email.\n\n'
          'After verification, press "Continue" below.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final verified = await _checkEmailVerified();
              if (verified) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Email verified! Patient added.')),
                );
                // TODO: Add logic after successful verification, e.g., save patient info, navigate away
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email not verified yet.')),
                );
              }
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user != null && !user.emailVerified) {
                try {
                  await user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email resent.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error resending email: $e')),
                  );
                }
              }
            },
            child: const Text('Resend Email'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: const Text(
          'Add Patient',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  "Let's add the patient to monitor their medications",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  "A confirmation message will be sent to the patient's email",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter patient\'s email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !_isValidEmail(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              _sendVerificationEmail();

                              logger.i("Email: ${_emailController.text}");
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Send Verification',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final Logger logger = Logger();
  bool _isButtonEnabled = false;

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

  Future<void> linkCaregiverByEmail(String caregiverEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final callable =
          FirebaseFunctions.instance.httpsCallable('linkCaregiver');
      final result = await callable.call(<String, dynamic>{
        'email': caregiverEmail,
      });

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        print('Caregiver linked with UID: ${data['caregiverUid']}');
        // Optionally update UI or local state here
      }
    } catch (e) {
      print('Error linking caregiver: $e');
      // Show error message in UI
    }
  }

  Future<void> sendEmail(String email) async {
    final url = Uri.parse(
        'https://vercel.com/mark-madorables-projects/pill-buddy/Dk78oAdSHVvFV1dU9o7niHUWLvm8');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "to": email,
        "subject": "Hello!",
        "text": "This email is sent from Flutter via Vercel + SendGrid"
      }),
    );

    if (response.statusCode == 200) {
      logger.e("Email sent!");
    } else {
      logger.e("Failed to send email: ${response.body}");
    }
  }

  Future<void> sendVerificationEmail(String email, String code) async {
    final url = Uri.parse('https://your-backend.com/sendEmail');
    final response = await http.post(url, body: {
      'email': email,
      'code': code,
    });

    if (response.statusCode == 200) {
      print('Verification email sent');
    } else {
      print('Failed to send email');
    }
  }

  Future<void> sendMailFromGmail(String sender, String sub, String text) async {
    final email = dotenv.env["GMAIL_MAIL"];
    final password = dotenv.env["GMAIL_PASSWORD"];

    if (email == null || password == null) {
      logger.e('Missing GMAIL_MAIL or GMAIL_PASSWORD in .env');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email credentials not found.')),
      );
      return;
    }

    final smtpServer = gmail(email, password);

    final message = Message()
      ..from = Address(email, 'Custom Support Staff')
      ..recipients.add(sender)
      ..subject = sub
      ..text = text;

    try {
      final sendReport = await send(message, smtpServer);
      logger.i('Message sent: $sendReport');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent successfully.')),
      );
    } on MailerException catch (e) {
      logger.e('Message not sent: $e');
      for (var p in e.problems) {
        logger.e('Problem: ${p.code}: ${p.msg}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send verification email.')),
      );
    }
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        title: const Text('Add Patient', style: TextStyle(color: Colors.white)),
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
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(Icons.email, size: 80, color: primaryColor),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Let's add the patient to monitor their medications",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
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
                    hintText: "Enter patient's email",
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
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              final email = _emailController.text.trim();
                              try {
                                //  sendEmail(email);
                                linkCaregiverByEmail(email);
                              } on Exception catch (e) {
                                logger.e("Error sending email: $e");
                              }
                              // await sendMailFromGmail(
                              //   email,
                              //   'Email Verification',
                              //   'Please verify your email.',
                              // );
                              logger
                                  .i("Verification email triggered for $email");
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
                    child: const Text(
                      'Send Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

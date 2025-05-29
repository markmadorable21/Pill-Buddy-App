import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/main_pages/input_device_id_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class CheckPatientEmailPage extends StatefulWidget {
  @override
  _CheckPatientEmailPageState createState() => _CheckPatientEmailPageState();
}

class _CheckPatientEmailPageState extends State<CheckPatientEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  var logger = Logger();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> checkEmailExists(String email) async {
    try {
      // Adjust 'email' below to match the exact field name in patient documents
      final querySnapshot = await firestore
          .collection('patients')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error querying patients collection: $e');
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  void _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an email.';
        _isLoading = false;
      });
      return;
    }

    final exists = await checkEmailExists(email);

    setState(() {
      _isLoading = false;
    });

    if (exists) {
      Provider.of<MedicationProvider>(context, listen: false).addPatient(true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InputDeviceIdPage(),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'No patient found with that email.';
      });
    }
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
        padding: const EdgeInsets.all(16),
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
                decoration: InputDecoration(
                  hintText: "Enter patient's email",
                  border: OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
                validator: (value) {
                  if (value == null || !_isValidEmail(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _onSubmit();
                          logger.e('Email: ${_emailController.text.trim()}');
                        },
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
    );
  }
}

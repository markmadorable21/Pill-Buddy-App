// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/name_input_formatter.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/surname_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_gender_identity.dart';

class CreateProfileNamePageCaregiver extends StatefulWidget {
  const CreateProfileNamePageCaregiver({super.key});

  @override
  State<CreateProfileNamePageCaregiver> createState() =>
      _CreateProfileNamePageStateCaregiver();
}

class _CreateProfileNamePageStateCaregiver
    extends State<CreateProfileNamePageCaregiver> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isButtonEnabled = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkInputs);
    _lastNameController.addListener(_checkInputs);
  }

  void _checkInputs() {
    setState(() {
      _isButtonEnabled = _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty;
    });
  }

  // Method to combine first and last name and save to provider
  void _saveCompleteName() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final completeName = '$firstName $lastName';

    // Save complete name to provider
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    provider.setCompleteName(completeName);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            // Icon with fade-in animation
            FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Icon(LucideIcons.user, size: 80, color: primaryColor),
            ),

            const SizedBox(height: 20),

            // Title text - changed to caregiver wording
            FadeIn(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 500),
              child: const Text(
                "Let's get to know you better!\nWhat's your name, caregiver?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // First Name TextField
            FadeIn(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 500),
              child: TextField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [NameInputFormatter()],
                onChanged: (value) {
                  provider.inputFirstName(value);
                },
                decoration: InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Last Name TextField
            FadeIn(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 500),
              child: TextField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [SurnameInputFormatter()],
                decoration: InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) => provider.inputLastName(val),
              ),
            ),

            const Spacer(),

            // Next Button with SlideInUp animation
            SlideInUp(
              duration: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor:
                        _isButtonEnabled ? primaryColor : Colors.grey,
                  ),
                  onPressed: _isButtonEnabled
                      ? () {
                          _saveCompleteName();
                          logger.i(
                              "Caregiver First Name: ${_firstNameController.text}");
                          logger.i(
                              "Caregiver Last Name: ${_lastNameController.text}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateProfileIdentityPage()),
                          );
                        }
                      : null,
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

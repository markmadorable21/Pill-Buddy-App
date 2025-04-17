import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pill_buddy/pages/register_pages/create_profile_confirm_email.dart';

class CreateProfileHopeToAchievePage extends StatefulWidget {
  const CreateProfileHopeToAchievePage({super.key});

  @override
  State<CreateProfileHopeToAchievePage> createState() =>
      _HopeToAchievePageState();
}

class _HopeToAchievePageState extends State<CreateProfileHopeToAchievePage> {
  final List<String> options = [
    "Get medication reminders",
    "Track whether I took my meds",
    "Keep a list of my meds",
    "Remember when it's time to refill",
    "Check for drug interaction",
    "Track side effects/symptoms",
    "Track measurements (e.g. Blood Pressure)"
  ];

  final Set<String> selectedOptions = {};

  void _toggleOption(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
      } else {
        selectedOptions.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag, size: 50, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "What do you hope to achieve with PillBuddy?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You can choose more than one.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return FadeInLeft(
                    delay: Duration(milliseconds: 100 * index),
                    child: CheckboxListTile(
                      title: Text(option),
                      value: selectedOptions.contains(option),
                      onChanged: (bool? value) {
                        _toggleOption(option);
                      },
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedOptions.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateProfileConfirmEmailPage()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: selectedOptions.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Done",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

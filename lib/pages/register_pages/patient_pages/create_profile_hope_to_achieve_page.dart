import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_confirm_email.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';

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
    "Track measurements (e.g. Blood Pressure, Heart Rate)",
    "Get medication adherence analytics",
    "Track my medication history",
    "Get refill reminders",
    "Get expiration reminders",
  ];
  var logger = Logger();
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
            const Icon(Icons.flag, size: 50, color: Colors.green),
            const SizedBox(height: 16),
            // Title and description with FadeInDown animation
            FadeInDown(
              child: const Text(
                "What do you hope to achieve with PillBuddy?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              child: const Text(
                "You can choose more than one.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // List of options with Checkboxes and animations
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];

                  return FadeInLeft(
                    delay:
                        Duration(milliseconds: 100 * index), // Animation delay
                    child: CheckboxListTile(
                      title: Text(option),
                      value: context
                          .watch<MedicationProvider>()
                          .selectedOptions
                          .contains(option),
                      onChanged: (bool? value) {
                        // Toggle the option
                        context.read<MedicationProvider>().toggleOption(option);
                      },
                    ),
                  );
                },
              ),
            ),

            // Next Button
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: context
                          .watch<MedicationProvider>()
                          .selectedOptions
                          .isNotEmpty
                      ? () {
                          logger.e(
                              "Selected options: ${context.read<MedicationProvider>().selectedOptions}");
                          // Navigate to the next page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateProfileConfirmEmailPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: context
                            .watch<MedicationProvider>()
                            .selectedOptions
                            .isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

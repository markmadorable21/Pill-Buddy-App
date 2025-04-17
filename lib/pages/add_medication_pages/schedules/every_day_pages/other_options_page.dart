import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/add_instructions_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/change_the_med_icon_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/set_treatment_duration_page.dart.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/add_refill_reminder_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class OtherOptionsPage extends StatefulWidget {
  const OtherOptionsPage({super.key});

  @override
  State<OtherOptionsPage> createState() => _HomePageState();
}

class _HomePageState extends State<OtherOptionsPage> {
  bool changeIcon = false;
  bool isPage1Done = false;
  bool isPage2Done = false;
  bool isPage3Done = false;
  bool isPage4Done = false;

  void saveMedicationData() {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    print("Saving the following data:");
    print("Name: ${provider.selectedMed}");
    print("Form: ${provider.selectedForm}");
    print("Purpose: ${provider.selectedPurpose}");
    print("Frequency: ${provider.selectedFrequency}");
    print("Time: ${provider.selectedTime}");
    print("Amount: ${provider.selectedAmount}");
    print("Expiration: ${provider.selectedExpiration}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medication saved successfully!")),
    );
  }

  void _navigateAndMarkDone(BuildContext context, int pageNumber) async {
    // Navigate to respective page
    if (pageNumber == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetTreatmentDurationPage()),
      );
      setState(() => isPage1Done = true);
    } else if (pageNumber == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddRefillReminderPage()),
      );
      setState(() => isPage2Done = true);
    } else if (pageNumber == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddInstructionsPage()),
      );
      setState(() => isPage3Done = true);
    } else if (pageNumber == 4) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChangeTheMedIconPage()),
      );
      setState(() => isPage4Done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Other Options", style: TextStyle(color: Colors.white)),
        toolbarHeight: 70,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child:
                    Icon(Icons.medical_services, size: 80, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: FadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  "Almost done. Would you like to:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionTile(
              context: context,
              label: 'Set treatment duration?',
              isDone: isPage1Done,
              onTap: () => _navigateAndMarkDone(context, 1),
            ),
            const SizedBox(height: 13),
            _buildActionTile(
              context: context,
              label: 'Add refill reminder',
              isDone: isPage2Done,
              onTap: () => _navigateAndMarkDone(context, 2),
            ),
            const SizedBox(height: 13),
            _buildActionTile(
              context: context,
              label: 'Add instructions?',
              isDone: isPage3Done,
              onTap: () => _navigateAndMarkDone(context, 3),
            ),
            const SizedBox(height: 13),
            _buildActionTile(
              context: context,
              label: 'Change the med icon?',
              isDone: isPage4Done,
              onTap: () => _navigateAndMarkDone(context, 4),
            ),
            const Spacer(),
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
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () {
                    saveMedicationData();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const ExpirationPage(),
                    //   ),
                    // );
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String label,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDone ? Colors.grey[300] : primaryColor.withOpacity(0.1),
          border: Border.all(color: isDone ? Colors.grey : primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDone ? Colors.grey : Colors.black,
              ),
            ),
            if (isDone) const Icon(Icons.check_circle, color: Colors.green)
          ],
        ),
      ),
    );
  }
}

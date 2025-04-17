import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pill_buddy/pages/add_medication_pages/purpose_page_select_disease.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class MedFormPage extends StatefulWidget {
  const MedFormPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MedFormPageState createState() => _MedFormPageState();
}

class _MedFormPageState extends State<MedFormPage> {
  String? selectedMedForm;

  @override
  Widget build(BuildContext context) {
    final selectedMed = Provider.of<MedicationProvider>(context).selectedMed;

    final List<String> medFormOptions = [
      "Pill",
      "Injection",
      "Solution (Liquid)",
      "Drops",
      "Inhaler",
      "Powder",
    ];

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Form", style: TextStyle(color: Colors.white)),
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents graying effect when scrolling
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Top spacing

            // Icon (Static)
            Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child:
                    Icon(Icons.medical_services, size: 80, color: primaryColor),
              ),
            ),

            const SizedBox(height: 20),

            // Title (Static)
            Center(
              child: FadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Text(
                  "What form is the med\n$selectedMed?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Scrollable Med Form Options
            Expanded(
              child: ListView.builder(
                itemCount: medFormOptions.length,
                itemBuilder: (context, index) {
                  final medForm = medFormOptions[index];
                  final isSelected = selectedMedForm == medForm;

                  return SlideInUp(
                    delay: Duration(milliseconds: 100 + (index * 50)),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMedForm = medForm;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey),
                          color: isSelected
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              medForm,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? primaryColor : Colors.black,
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color:
                                      primaryColor), // Checkmark for selected option
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20), // Space before button

            // Next Button
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
                        selectedMedForm != null ? primaryColor : Colors.grey,
                  ),
                  onPressed: selectedMedForm != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PurposePageSelectDisease()),
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

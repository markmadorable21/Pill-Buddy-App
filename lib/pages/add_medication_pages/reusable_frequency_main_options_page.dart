import "package:animate_do/animate_do.dart";
import "package:flutter/material.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/every_day_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/reusable_date_inputter_page.dart";
import "package:pill_buddy/pages/providers/medication_provider.dart";
import "package:provider/provider.dart";

class ReusableFrequencyMainOptionsPage extends StatefulWidget {
  const ReusableFrequencyMainOptionsPage({super.key});

  @override
  State<ReusableFrequencyMainOptionsPage> createState() =>
      _ReusableFrequencyMainOptionsPage();
}

class _ReusableFrequencyMainOptionsPage
    extends State<ReusableFrequencyMainOptionsPage> {
  String? selectedSched;

  @override
  Widget build(BuildContext context) {
    final selectedMed = Provider.of<MedicationProvider>(context).selectedMed;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final provider = Provider.of<MedicationProvider>(context);
    final List<String> medFormOptions = [
      "Every day",
      "Every other day",
      "Specific day",
      "Specific days of the week",
      "On a recurring cycle",
      "Every X days",
      "Every X weeks",
      "Every X months",
      "Only as needed",
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(selectedMed, style: const TextStyle(color: Colors.white)),
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
                child: const Text(
                  "How often do you take it?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  final isSelected = selectedSched == medForm;

                  return SlideInUp(
                    delay: Duration(milliseconds: 100 + (index * 50)),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSched = medForm;
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
                        selectedSched != null ? primaryColor : Colors.grey,
                  ),
                  onPressed: selectedSched != null
                      ? () {
                          if (selectedSched == "Every day") {
                            provider.selectSchedule(selectedSched!);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EveryDayPage()));
                          } else if (selectedSched == "Every other day") {
                          } else if (selectedSched ==
                              "Specific days of the week") {
                            provider.selectSchedule(selectedSched!);
                          } else if (selectedSched == "Specific day") {
                            provider.selectSchedule(selectedSched!);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ReusableDateInputterPage()));
                          } else if (selectedSched == "On a recurring cycle") {
                          } else if (selectedSched == "Every X days") {
                          } else if (selectedSched == "Every X weeks") {
                          } else if (selectedSched == "Every X months") {
                          } else {}
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

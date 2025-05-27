import "package:animate_do/animate_do.dart";
import "package:flutter/material.dart";
import "package:pill_buddy/pages/add_medication_pages/multi_time_input_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/every_day_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/expiration_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/every_x_days_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/recurring_cycle_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/reusable_date_inputter_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/specific_days_of_week_page.dart";
import "package:pill_buddy/pages/add_medication_pages/times_per_day_page.dart";
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

    final List<String> medFormOptions = [
      "Every day",
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
                      ? () async {
                          final provider = context.read<MedicationProvider>();
                          provider.selectSchedule(selectedSched!);

                          if (selectedSched == "Specific day") {
                            // Skip time selection, navigate directly to date input
                            provider.setSelectedTimesPerDay('');

                            provider.setSelectedTimes([]);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ReusableDateInputterPage()),
                            );
                            return;
                          }

                          // For other frequencies, ask for times per day first
                          final timesPerDay = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TimesPerDayPage(
                                  frequencyType: selectedSched!),
                            ),
                          );

                          if (timesPerDay != null) {
                            provider.setSelectedTimesPerDay(timesPerDay);

                            final timesCount = {
                              "Once a day": 1,
                              "Twice a day": 2,
                              "3 times a day": 3,
                              "More than 3 times a day": 4,
                            }[timesPerDay]!;

                            final selectedTimes =
                                await Navigator.push<List<TimeOfDay?>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiTimeInputPage(
                                    numberOfTimes: timesCount),
                              ),
                            );

                            if (selectedTimes != null) {
                              final nonNullableTimes =
                                  selectedTimes.whereType<TimeOfDay>().toList();
                              provider.setSelectedTimes(nonNullableTimes);

                              // Navigate to next page based on frequency
                              if (selectedSched == "Every day") {
                                provider.selectFrequency(selectedSched!);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ExpirationPage()));
                              } else if (selectedSched ==
                                  "Specific days of the week") {
                                provider.selectFrequency(selectedSched!);

                                provider.selectDate(DateTime.now());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SpecificDaysPage()));
                              } else if (selectedSched ==
                                  "On a recurring cycle") {
                                provider.selectFrequency(selectedSched!);

                                provider.selectDate(DateTime.now());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const RecurringCyclePage()));
                              } else if (selectedSched == "Every other day") {
                                provider.selectFrequency(selectedSched!);

                                provider.selectDate(DateTime.now());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ExpirationPage()));
                              } else {
                                provider.selectFrequency(selectedSched!);

                                provider.selectDate(DateTime.now());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const EveryXDaysPage()));
                              }
                            }
                          }
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  DateTime _currentDate = DateTime.now();
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _addMockData();
  }

// Mock data insertion
  void _addMockData() {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    if (provider.medList.isEmpty) {
      provider.addMedicationEntry(
        MedicationEntry(
          med: 'Paracetamol',
          time: '08:00 AM',
          amount: '1 tablet',
          form: 'Tablet',
          purpose: 'Fever reducer',
          date: DateTime.now(),
          expiration: '2025-12-01',
          frequency: '',
          quantity: '2',
        ),
      );
      provider.addMedicationEntry(
        MedicationEntry(
          med: 'Vitamin C',
          time: '12:00 PM',
          amount: '2 tablets',
          form: 'Tablet',
          purpose: 'Immunity Boost',
          date: DateTime.now(),
          expiration: '2025-11-15',
          frequency: '',
          quantity: '',
        ),
      );
      provider.addMedicationEntry(
        MedicationEntry(
          med: 'Cough Syrup',
          time: '06:00 PM',
          amount: '10ml',
          form: 'Liquid',
          purpose: 'Cough relief',
          date: DateTime.now().subtract(const Duration(days: 1)), // For testing
          expiration: '2025-09-10', frequency: '', quantity: '',
        ),
      );

      // DAILY mock
      provider.addMedicationEntry(
        MedicationEntry(
          quantity: '',
          med: 'Multivitamin',
          time: '07:00 AM',
          amount: '1 tablet',
          form: 'Tablet',
          purpose: 'Daily supplement',
          date: DateTime.now(), // starting “date” – ignored in filter
          expiration: '2026-01-01',
          frequency: 'Everyday', // NEW
        ),
      );
    }
  }

  // Method to go to today's date in the calendar
  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });

    int indexOfToday = DateTime.now().difference(DateTime.now()).inDays + 577;

    _scrollController.animateTo(
      (indexOfToday * 50.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 5),
            // Calendar Row (Horizontal List of Days with Day Numbers)
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: 1000, // Indefinite number of days
                itemBuilder: (context, index) {
                  final day = DateTime.now().add(Duration(
                      days:
                          index - 500)); // Adjust offset for infinite scrolling
                  final isSelected = _currentDate.day == day.day;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentDate = day;
                      });
                    },
                    child: Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? primaryColor
                            : primaryColor.withOpacity(0.1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(day), // Day name (e.g., Mon)
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            '${day.day}', // Day number (e.g., 1, 2, 3)
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            // Today's Date
            Row(
              children: [
                // Button to go back to the current date
                TextButton(
                  onPressed: _goToToday,
                  child: const Text("Today >>", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 60),
                Text(DateFormat('MMM d, yyyy').format(_currentDate),
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            // List of Medications
            Expanded(
              child: ListView.builder(
                itemCount: provider.medList.length,
                itemBuilder: (context, index) {
                  // Compare the date using DateTime objects

                  if (DateFormat('MMM-dd-yyyy').format(_currentDate) ==
                      DateFormat('MMM-dd-yyyy')
                          .format(provider.medList[index].date)) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: ListTile(
                        title: Text(
                          provider.medList[index].time,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const SizedBox(width: 5),
                                Icon(LucideIcons.pill,
                                    size: 30, color: primaryColor),
                                const SizedBox(width: 15),
                                Container(
                                    width: 1, height: 35, color: Colors.black),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${provider.medList[index].med}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'Take ${provider.medList[index].amount} ${provider.medList[index].form}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                        onTap: () {
                          // Show a dialog when the medication is clicked
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                // Remove the title
                                titlePadding: EdgeInsets.zero,
                                contentPadding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(20),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.info,
                                            color: primaryColor),
                                        onPressed: () {
                                          // Info icon pressed
                                          print("Info Icon Clicked");
                                        },
                                      ),
                                      const SizedBox(width: 170),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          // Edit icon pressed
                                          print("Edit Icon Clicked");
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          // Delete the medication when the delete icon is pressed
                                          provider.removeMedicationEntry(
                                              provider.medList[index]);
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                content: Container(
                                  height: 250,
                                  width: 400,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Icon(LucideIcons.pill,
                                            color: primaryColor, size: 30),
                                      ),
                                      const SizedBox(height: 5),
                                      Align(
                                        child: Text(
                                          provider.medList[index].med,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      // Date schedule
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Set for ${provider.medList[index].time}, ${provider.medList[index].date}',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Amount and form
                                      Row(
                                        children: [
                                          const Icon(Icons.format_size),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Amount: ${provider.medList[index].amount} | Form: ${provider.medList[index].form}',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.fileQuestion),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Purpose: ${provider.medList[index].purpose}',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Expiration date
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Expire on ${provider.medList[index].expiration}',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return const Text("Error bitch!");
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            // Button to add medication
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReusableAddMedNamePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text(
                    "Add Medication",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

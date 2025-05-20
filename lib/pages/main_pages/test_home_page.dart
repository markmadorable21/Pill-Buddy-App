import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pill_buddy/pages/add_medication_pages/door_selection_page.dart';
import 'package:pill_buddy/pages/providers/door_status_provider.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';

/// Helper class to pair medication with specific time
class _MedTimeEntry {
  final MedicationEntry medication;
  final TimeOfDay? time;

  _MedTimeEntry({required this.medication, this.time});
}

/// Main schedule view for displaying medications based on frequency and date.
class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  DateTime _currentDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Uncomment if you want to add mock data on start
    // WidgetsBinding.instance.addPostFrameCallback((_) => _addMockData());
  }

  Future<void> deleteMedicationFromDoor(int doorIndex) async {
    final doorKey = doorIndex == 0 ? 'door1' : 'door2';
    final dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref('medications/$doorKey');

    // Use either remove() or update({'added': false})
    await dbRef.remove();

    //await dbRef.remove();
    logger.e('Medication variable added set to false for door $doorKey');
  }

  void _goToToday() {
    setState(() => _currentDate = DateTime.now());
    final indexOfToday = DateTime.now().difference(DateTime.now()).inDays + 577;
    _scrollController.animateTo(
      indexOfToday * 50.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Build expanded medication list: one card per time
    final expandedMedList = <_MedTimeEntry>[];
    for (final med in provider.medList) {
      if (med.selectedTimes != null && med.selectedTimes!.isNotEmpty) {
        for (final time in med.selectedTimes!) {
          if (med.isScheduledOn(_currentDate)) {
            expandedMedList.add(_MedTimeEntry(medication: med, time: time));
          }
        }
      } else {
        if (med.isScheduledOn(_currentDate)) {
          expandedMedList.add(_MedTimeEntry(medication: med, time: null));
        }
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Calendar strip (horizontal scroll)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: 1000,
                itemBuilder: (ctx, idx) {
                  final day = DateTime.now().add(Duration(days: idx - 500));
                  final isSelected = day.year == _currentDate.year &&
                      day.month == _currentDate.month &&
                      day.day == _currentDate.day;
                  return GestureDetector(
                    onTap: () => setState(() => _currentDate = day),
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(DateFormat('E').format(day),
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black)),
                          Text('${day.day}',
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _goToToday,
                  child: const Text("Today >>", style: TextStyle(fontSize: 16)),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, yyyy').format(_currentDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            // Medication list
            Expanded(
              child: expandedMedList.isEmpty
                  ? Center(
                      child: Text(
                        "No meds for ${DateFormat('MMM d, yyyy').format(_currentDate)}.",
                      ),
                    )
                  : ListView.builder(
                      itemCount: expandedMedList.length,
                      itemBuilder: (ctx, i) {
                        final entry = expandedMedList[i];
                        final med = entry.medication;
                        final time = entry.time;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          child: ListTile(
                            title: Text(
                              time != null ? time.format(context) : med.time,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.pill,
                                      size: 30, color: primaryColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          med.med,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text('Take ${med.amount} ${med.form}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              // Show detailed dialog, pass 'time' to display correct scheduled time
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    titlePadding: EdgeInsets.zero,
                                    contentPadding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withAlpha(20),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.info,
                                                color: primaryColor),
                                            onPressed: () =>
                                                print("Info Icon Clicked"),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                print("Edit Icon Clicked"),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.redAccent),
                                            onPressed: () async {
                                              final provider = context
                                                  .read<MedicationProvider>();

                                              int doorIndex = med.doorIndex;

                                              // Optionally show a loading indicator here if needed

                                              try {
                                                // Remove locally first

                                                provider
                                                    .removeMedicationEntry(med);

                                                // Delete in Firebase
                                                await deleteMedicationFromDoor(
                                                    doorIndex);

                                                logger.e(
                                                    'Medication ${med.med} removed from Firebase door $doorIndex');
                                                Navigator.of(context)
                                                    .pop(); // Close dialog or page

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Medication deleted successfully')),
                                                );
                                              } catch (e) {
                                                logger.e(
                                                    'Failed to delete medication: $e');
                                              }
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
                                          Center(
                                            child: Text(
                                              med.med,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Scheduled: ${time != null ? time.format(context) : med.time}, ${med.date != null ? DateFormat('MMM d, yyyy').format(med.date!) : 'N/A'}',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.format_size),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Amount: ${med.amount} | Form: ${med.form}',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(
                                                  LucideIcons.fileQuestion),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Purpose: ${med.purpose}',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.date_range),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Expires on ${med.expiration}',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),

            // Add Medication button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DoorSelectionPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

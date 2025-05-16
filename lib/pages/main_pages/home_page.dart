import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime selectedDate;
  late PageController _pageController;
  final int totalWeeks = 104; // 2 years span
  late int todayPageIndex;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDate = today;
    todayPageIndex = totalWeeks ~/ 2;
    _pageController = PageController(initialPage: todayPageIndex);

    // // ADD THIS — preload mock data
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final provider = Provider.of<MedicationProvider>(context, listen: false);

    //   // Only add if empty (to avoid duplicates during hot reloads)
    //   if (provider.medList.isEmpty) {
    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'Paracetamol',
    //         form: 'Pill',
    //         purpose: 'Headache',
    //         frequency: 'Once a day',
    //         time: '8:00 AM',
    //         amount: '1',
    //         expiration: '2025-12-31',
    //       ),
    //     );

    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'Cough Syrup',
    //         form: 'Injection',
    //         purpose: 'Cough',
    //         frequency: 'Twice a day',
    //         time: '8:00 AM',
    //         amount: '10',
    //         expiration: '2025-11-15',
    //       ),
    //     );

    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'Antibiotic',
    //         form: 'Solution (Liquid)',
    //         purpose: 'Virginitis',
    //         frequency: '3 times a day',
    //         time: '9:00 PM',
    //         amount: '1',
    //         expiration: '2025-10-20',
    //       ),
    //     );

    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'Shabu Liquid',
    //         form: 'Drops',
    //         purpose: 'Borks',
    //         frequency: '3 times a day',
    //         time: '5:00 PM',
    //         amount: '1',
    //         expiration: '2025-10-20',
    //       ),
    //     );
    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'Marijuana',
    //         form: 'Inhaler',
    //         purpose: 'Sabog',
    //         frequency: '3 times a day',
    //         time: '5:00 PM',
    //         amount: '1',
    //         expiration: '2025-10-20',
    //       ),
    //     );
    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'Exstacy',
    //         form: 'Powder',
    //         purpose: 'Adik',
    //         frequency: '3 times a day',
    //         time: '5:00 PM',
    //         amount: '1',
    //         expiration: '2025-10-20',
    //       ),
    //     );
    //     provider.addMedicationEntry(
    //       MedicationEntry(
    //         med: 'BBC',
    //         form: 'Powders',
    //         purpose: 'Pacuntot',
    //         frequency: '3 times a day',
    //         time: '5:00 PM',
    //         amount: '1',
    //         expiration: '2025-10-20',
    //       ),
    //     );
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final addedMed = Provider.of<MedicationProvider>(context).addedMed;

    return Scaffold(
        body: Column(
          children: [
            // Fixed header widgets
            Container(
              color: Colors.grey[200],
              child: _buildDaysOfWeekRow(),
            ),
            Container(
              color: Colors.grey[200],
              child: _buildDateSelector(primaryColor),
            ),
            Container(
              color: Colors.grey[200],
              child: _buildDateNavigationButtons(primaryColor),
            ),

            // 2) Scrollable medication list
            Expanded(
              child: addedMed
                  ? _buildMedicationList() // your ListView.builder wrapped in Expanded
                  : _buildAddMedicationButton(), // if no meds yet
            ),
          ],
        ), // this widget sits _below_ the body, fixed in place
        bottomNavigationBar: SafeArea(
          child: Padding(
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
        ));
  }

  Widget _buildDaysOfWeekRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            .map((day) => Expanded(
                  child: Center(
                    child: Text(day,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDateSelector(Color primaryColor) {
    return SizedBox(
      height: 50,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          setState(() {
            selectedDate = _getExactDateForCurrentWeek(index - todayPageIndex);
          });
        },
        itemBuilder: (context, index) {
          DateTime startDate = _getWeekStart(index - todayPageIndex);
          List<DateTime> weekDates =
              List.generate(7, (i) => startDate.add(Duration(days: i)));

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: weekDates.map((date) {
              bool isSelected = _isSameDay(selectedDate, date);
              // bool isToday = _isSameDay(today, date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
                child: Container(
                  width: 50,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${date.day}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDateNavigationButtons(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedDate = today;
              });
              _pageController.animateToPage(
                todayPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text("Today"),
          ),
          Text(
            _getFormattedDateText(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 80), // Keeps layout balanced
        ],
      ),
    );
  }

  Widget _buildAddMedicationButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/home_gif.gif",
          height: 200,
        ),
        const Text(
          "Monitor your med schedule",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "View your daily schedule and mark your \nmeds when taken.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

// Parse a "h:mm a" string into a TimeOfDay
  /// Extracts only the “08:10 AM” part from “08:10 AM at 6”
  String _timePrefix(String full) {
    // Split the string by " at " and return the first part
    final parts = full.split(' at ');
    return parts.isNotEmpty ? parts.first.trim() : full.trim();
  }

  /// Parses “08:10 AM” into a TimeOfDay
  TimeOfDay _parseTimeOfDay(String full) {
    try {
      final prefix = _timePrefix(full); // Extract the time portion
      final dt = DateFormat.jm().parse(prefix); // Parse the time
      return TimeOfDay.fromDateTime(dt);
    } catch (e) {
      // Log the error and return a default time (e.g., 12:00 AM)
      print('Error parsing time: $full. Returning default time. Error: $e');
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  /// Converts a TimeOfDay into minutes since midnight
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  // Pick an icon based on the medication form
  IconData _iconForForm(String form) {
    switch (form) {
      case 'Pill':
        return LucideIcons.pill;
      case 'Injection':
        return LucideIcons.syringe;
      case 'Solution (Liquid)':
        return Icons.liquor;
      case 'Drops':
        return Icons.opacity;
      case 'Inhaler':
        return LucideIcons.wind;
      case 'Powder':
        return Icons.grain;
      default:
        return Icons.medical_services;
    }
  }

  // Pick a unit string based on the medication form
  String _unitForForm(String form) {
    switch (form) {
      case 'Pill':
        return 'pill(s)';
      case 'Injection':
      case 'Solution (Liquid)':
        return 'mL';
      case 'Drops':
        return 'drop(s)';
      case 'Inhaler':
        return 'puff(s)';
      case 'Powder':
        return 'g';
      default:
        return '';
    }
  }

  /// Returns a scrollable, time‑grouped list of meds.
  Widget _buildMedicationList() {
    final medList = Provider.of<MedicationProvider>(context).medList;

    // 1) Sort by clock time
    medList.sort((a, b) {
      final ta = _toMinutes(_parseTimeOfDay(a.time));
      final tb = _toMinutes(_parseTimeOfDay(b.time));
      return ta.compareTo(tb);
    });

    // 2) Group into a Map<String time, List<MedicationEntry>>
    final Map<String, List<MedicationEntry>> grouped = {};
    for (final med in medList) {
      final timeKey = _timePrefix(med.time); // e.g. "08:10 AM"
      grouped.putIfAbsent(timeKey, () => []).add(med);
    }

    // 3) Build a single ListView with sections
    return ListView(
      padding: const EdgeInsets.only(bottom: 100), // room for bottom button
      children: grouped.entries.map((entry) {
        final timeHeader = entry.key;
        final meds = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                timeHeader,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // One card per med in this time slot
            ...meds.map((med) {
              final icon = _iconForForm(med.form);
              final unit = _unitForForm(med.form);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      // icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue, // or pick color per form
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      // divider
                      Container(width: 1, height: 40, color: Colors.black),
                      const SizedBox(width: 12),
                      // text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.med,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 4),
                            Text(
                              '${med.amount} $unit, Take 1 pill(s)',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.75)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  /// Returns the **start of the week (Sunday)** based on week offset
  DateTime _getWeekStart(int weekOffset) {
    DateTime baseSunday = today.subtract(Duration(days: today.weekday % 7));
    return baseSunday.add(Duration(days: weekOffset * 7));
  }

  /// Ensures that **selectedDate** moves back to **today**, even within its correct week
  DateTime _getExactDateForCurrentWeek(int weekOffset) {
    DateTime startOfWeek = _getWeekStart(weekOffset);
    List<DateTime> weekDates =
        List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    // If today is in this week, return today; otherwise, return the closest valid date
    return weekDates.contains(today) ? today : weekDates[0];
  }

  /// Compares if two dates are the same day (ignoring time)
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Formats date display with "Today, Mar 8" style
  String _getFormattedDateText(DateTime selected) {
    if (_isSameDay(selected, today)) {
      return "Today, ${DateFormat('MMM d').format(selected)}";
    }
    return DateFormat('EEEE, MMM d').format(selected);
  }
}

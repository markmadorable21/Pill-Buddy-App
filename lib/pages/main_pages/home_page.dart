import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pill_buddy/pages/add_medication_pages/add_med_name_page.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final addedMed = Provider.of<MedicationProvider>(context).addedMed;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[200], // Background color
              child: _buildDaysOfWeekRow(),
            ),
          ), // Days of the week

          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[200], // Background color
              child: _buildDateSelector(primaryColor),
            ),
          ), // Date selector

          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[200], // Background color
              child: _buildDateNavigationButtons(primaryColor),
            ),
          ), // Navigation buttons

          SliverFillRemaining(
            hasScrollBody: false,
            child:
                addedMed ? _buildMedicationList() : _buildAddMedicationButton(),
            // Medication section
          ),
        ],
      ),
    );
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
        const Spacer(),
        SizedBox(
          width: 350,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedNamePage(),
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
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMedicationList() {
    return Text("Yua");
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

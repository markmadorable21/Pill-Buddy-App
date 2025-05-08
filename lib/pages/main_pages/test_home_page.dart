import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_medication_page.dart'; // Import the page for adding medication

void main() {
  runApp(MaterialApp(home: TestHomePage()));
}

class TestHomePage extends StatefulWidget {
  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  DateTime _currentDate = DateTime.now();
  List<DateTime> _weekDates = [];
  List<Map<String, String>> _medications = [];

  // To track the offset for the infinite scroll
  ScrollController _scrollController = ScrollController();

  // Generate the list of dates dynamically based on the current date
  List<DateTime> _generateDates(int count) {
    final today = DateTime.now();
    return List.generate(count, (index) => today.add(Duration(days: index)));
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });

    // Calculate the index of the current day
    int indexOfToday = DateTime.now().difference(DateTime.now()).inDays + 500;

    // Scroll to the position of today's date
    _scrollController.animateTo(
      (indexOfToday *
          60.0), // Multiply by 60 for the width of each day container
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _addMedication(String medName, TimeOfDay time, DateTime date) {
    setState(() {
      _medications.add({
        'name': medName,
        'time': time.format(context),
        'date': DateFormat('yyyy-MM-dd').format(date),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medication Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: isSelected ? Colors.blue : Colors.white,
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
            SizedBox(height: 10),
            // Today's Date
            Text(
                "Today's Date: ${DateFormat('yyyy-MM-dd').format(_currentDate)}"),
            SizedBox(height: 10),
            // List of Medications
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  if (_medications[index]['date'] ==
                      DateFormat('yyyy-MM-dd').format(_currentDate)) {
                    return ListTile(
                      title: Text(_medications[index]['name']!),
                      subtitle: Text('Time: ${_medications[index]['time']}'),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            // Button to go back to the current date
            ElevatedButton(
              onPressed: _goToToday,
              child: Text("Go to Today"),
            ),
            // Button to add medication
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddMedicationPage(onAddMedication: _addMedication)),
                );
              },
              child: Text("Add Medication"),
            ),
          ],
        ),
      ),
    );
  }
}

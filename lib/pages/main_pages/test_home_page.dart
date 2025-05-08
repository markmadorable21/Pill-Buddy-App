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
  List<Map<String, dynamic>> _medications = [];

  // To track the offset for the infinite scroll
  ScrollController _scrollController = ScrollController();

  // Method to add medication to the list
  void _addMedication(String medName, TimeOfDay time, DateTime date,
      String medForm, String purpose, String amount, DateTime expirationDate) {
    setState(() {
      _medications.add({
        'name': medName,
        'time': time.format(context),
        'date': DateFormat('yyyy-MM-dd').format(date),
        'medForm': medForm,
        'purpose': purpose,
        'amount': amount,
        'expirationDate': DateFormat('yyyy-MM-dd').format(expirationDate),
      });
    });

    // Sort the medications by time, and handle same times gracefully
    _medications.sort((a, b) {
      final timeA =
          TimeOfDay.fromDateTime(DateTime.parse(a['date'] + ' ' + a['time']));
      final timeB =
          TimeOfDay.fromDateTime(DateTime.parse(b['date'] + ' ' + b['time']));

      // Compare times and handle if they are the same
      if (timeA.hour == timeB.hour && timeA.minute == timeB.minute) {
        return 0; // No change if times are identical
      } else {
        return timeA.hour.compareTo(timeB.hour) == 0
            ? timeA.minute.compareTo(timeB.minute)
            : timeA.hour.compareTo(timeB.hour);
      }
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });

    // Calculate the index of the current day
    int indexOfToday = DateTime.now().difference(DateTime.now()).inDays + 577;

    // Scroll to the position of today's date
    _scrollController.animateTo(
      (indexOfToday *
          50.0), // Multiply by 60 for the width of each day container
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
                      width: 50,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
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
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(_medications[index]['name']),
                        subtitle: Text(
                          'Time: ${_medications[index]['time']} \nForm: ${_medications[index]['medForm']} \nPurpose: ${_medications[index]['purpose']} \nAmount: ${_medications[index]['amount']} \nExpiration: ${_medications[index]['expirationDate']}',
                        ),
                      ),
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

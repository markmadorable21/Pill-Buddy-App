import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'add_medication_page.dart'; // Import the page for adding medication

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

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
      // Ensure that we are formatting the DateTime correctly
      DateTime medicationDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // For expiration date, we can use the same approach to store it correctly
      DateTime medicationExpirationDate = DateTime(
        expirationDate.year,
        expirationDate.month,
        expirationDate.day,
      );

      // Add medication with DateTime objects
      _medications.add({
        'name': medName,
        'time': time.format(context), // Time formatted for display
        'date': DateFormat('yyyy-MM-dd')
            .format(medicationDate), // Format date for display
        'medForm': medForm,
        'purpose': purpose,
        'amount': amount,
        'expirationDate': DateFormat('yyyy-MM-dd')
            .format(medicationExpirationDate), // Expiration formatted
        'medicationDate':
            medicationDate, // Store the full DateTime for comparison
        'medicationExpirationDate':
            medicationExpirationDate, // Store expiration DateTime
      });
    });

    // Sorting the medications by the medicationDate (including both date and time)
    _medications.sort((a, b) {
      DateTime dateTimeA = a['medicationDate'];
      DateTime dateTimeB = b['medicationDate'];

      // Compare the full DateTime values
      return dateTimeA.compareTo(dateTimeB);
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text("Medication Schedule")),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // border: Border.all(color: Colors.black),
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
                    style: const TextStyle(fontSize: 16)
                    //Theme.of(context).textTheme.bodySmall?.fontSize),
                    ),
              ],
            ),
            // List of Medications
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  if (_medications[index]['date'] ==
                      DateFormat('yyyy-MM-dd').format(_currentDate)) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: ListTile(
                        title: Text(
                          _medications[index]['time'],
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
                                        '${_medications[index]['name']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'take ${_medications[index]['amount']} ${_medications[index]['medForm']}',
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
                                          setState(() {
                                            _medications.removeAt(
                                                index); // Remove the medication from the list
                                          });
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
                                          _medications[index]['name'],
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
                                            'Set for ${_medications[index]['time']}, ${DateFormat('MMM d, yyyy').format(DateTime.parse(_medications[index]['date']))}',
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
                                            'Amount: ${_medications[index]['amount']} | Form: ${_medications[index]['medForm']}',
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
                                            'Purpose: ${_medications[index]['purpose']}',
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
                                            'Expire on ${DateFormat('MMM d, yyyy').format(DateTime.parse(_medications[index]['expirationDate']))}',
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
                    return Container();
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

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
              child: const Text("Add Medication"),
            ),
          ],
        ),
      ),
    );
  }
}

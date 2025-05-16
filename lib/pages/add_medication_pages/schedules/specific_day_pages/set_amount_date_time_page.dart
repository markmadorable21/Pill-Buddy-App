import "package:flutter/material.dart";
import "package:animate_do/animate_do.dart";
import "package:intl/intl.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/expiration_page.dart";
import "package:provider/provider.dart";
import "package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart";
import "package:pill_buddy/pages/providers/medication_provider.dart";

class SetAmountDateTimePage extends StatefulWidget {
  const SetAmountDateTimePage({super.key});

  @override
  State<SetAmountDateTimePage> createState() => _SetAmountDateTimePage();
}

class _SetAmountDateTimePage extends State<SetAmountDateTimePage> {
  final TextEditingController _doseController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  DateTime _selectedDate = DateTime.now(); // Initialize with today's date
  TimeOfDay _time = TimeOfDay.now(); // Default time set to current time

  // Variables to check if all fields are filled
  bool _isDoseFilled = false;
  bool _isTimeFilled = false;
  bool _isDateFilled = false;

  void _showInvalidInputDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invalid Input"),
        content: const Text("Please enter a valid number."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Set the initial date
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update the selected date
        _isDateFilled = true; // Set the date as filled
      });
    }
  }

  // Function to show Time Picker
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _time, // Set the initial time
    );
    if (pickedTime != null && pickedTime != _time) {
      setState(() {
        _time = pickedTime; // Update the selected time
        _isTimeFilled = true; // Set the time as filled
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final selectedMed = Provider.of<MedicationProvider>(context).selectedMed;
    final medForm = Provider.of<MedicationProvider>(context).selectedForm;
    final primaryColor = Theme.of(context).colorScheme.primary;
    // final unit = Provider.of<MedicationProvider>(context).unitForForm;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: primaryColor,
        title: Text(selectedMed, style: const TextStyle(color: Colors.white)),
        elevation: 0,
        scrolledUnderElevation: 0,
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
            const SizedBox(height: 20),
            Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Icon(Icons.alarm, size: 80, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: FadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  "When do you need to take the dose?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Text(
                    "Take",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _doseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter amount",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isDoseFilled = value
                              .isNotEmpty; // Update state when dose input changes
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  //   Text(
                  //  //   unit,
                  //     style: const TextStyle(fontSize: 18),
                  //   ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Time: ${_time.format(context)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectTime(context), // Trigger time picker
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Selected Time: ${_time.format(context)}", // Display selected time
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              delay: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  const Text(
                    "Select Date",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context), // Trigger date picker
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy')
                            .format(_selectedDate), // Display selected date
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
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
                    backgroundColor: (_isDoseFilled &&
                            _isTimeFilled &&
                            _isDateFilled)
                        ? primaryColor
                        : Colors
                            .grey, // Button enabled only if all fields are filled
                  ),
                  onPressed: (_isDoseFilled && _isTimeFilled && _isDateFilled)
                      ? () {
                          provider.selectFrequency("Once a day");
                          provider.selectTime(
                              DateFormat('hh:mm a').format(_selectedDateTime));
                          provider.selectAmount(_doseController.text);
                          final input = double.tryParse(_doseController.text);
                          if (input == null || input <= 0) {
                            _showInvalidInputDialog(); //invalid input
                          } else {
                            print('Form: $medForm');
                            print(
                                'Time selected: ${_selectedDateTime.toIso8601String()}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExpirationPage(),
                              ),
                            );
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart'; // Import for date formatting

class AddMedicationPage extends StatefulWidget {
  final Function(String, TimeOfDay, DateTime, String, String, String, DateTime)
      onAddMedication;

  AddMedicationPage({required this.onAddMedication});

  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  var logger = Logger();
  TextEditingController _medNameController = TextEditingController();
  TextEditingController _medFormController = TextEditingController();
  TextEditingController _purposeController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  DateTime _date = DateTime.now();
  DateTime _expirationDate = DateTime.now();

  // Formatter for date
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Medication - Specific Day"),
        toolbarHeight: 70,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Medication Name Field
            TextField(
              controller: _medNameController,
              decoration: InputDecoration(labelText: "Medication Name"),
            ),
            SizedBox(height: 10),

            // Medication Form (e.g., pill, injection, etc.)
            TextField(
              controller: _medFormController,
              decoration: InputDecoration(
                  labelText: "Medication Form (e.g., pill, injection)"),
            ),
            SizedBox(height: 10),

            // Purpose Field
            TextField(
              controller: _purposeController,
              decoration:
                  InputDecoration(labelText: "Purpose (e.g., cough, HIV)"),
            ),
            SizedBox(height: 10),

            // Amount Field
            TextField(
              controller: _amountController,
              decoration:
                  InputDecoration(labelText: "Amount (e.g., 1 pill, 2ml)"),
            ),
            SizedBox(height: 10),

            // Time Picker
            ListTile(
              title: Text("Time: ${_time.format(context)}"),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (pickedTime != null && pickedTime != _time) {
                  setState(() {
                    _time = pickedTime;
                  });
                }
              },
            ),
            SizedBox(height: 10),

            // Date Picker for Medication Date
            ListTile(
              title: Text("Date: ${_date.toLocal()}".split(' ')[0]),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _date) {
                  setState(() {
                    _date = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 10),

            // Expiration Date Picker
            ListTile(
              title: Text("Expiration Date: ${_expirationDate.toLocal()}"
                  .split(' ')[0]),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _expirationDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _expirationDate) {
                  setState(() {
                    _expirationDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 10),

            // Save Medication Button
            ElevatedButton(
              onPressed: () {
                // Format date before passing it
                final formattedDate = _dateFormatter.format(_date);
                final formattedExpirationDate =
                    _dateFormatter.format(_expirationDate);
                logger.e(
                    'Medication Date: $_date, Expiration Date: $_expirationDate');

                try {
                  widget.onAddMedication(
                    _medNameController.text,
                    _time,
                    _date,
                    _medFormController.text,
                    _purposeController.text,
                    _amountController.text,
                    _expirationDate,
                  );
                } catch (e) {
                  logger.e('Error:$e');
                }
                Navigator.pop(context);
              },
              child: Text("Save Medication"),
            ),
          ],
        ),
      ),
    );
  }
}

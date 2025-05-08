import 'package:flutter/material.dart';

class AddMedicationPage extends StatefulWidget {
  final Function(String, TimeOfDay, DateTime) onAddMedication;

  AddMedicationPage({required this.onAddMedication});

  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  TextEditingController _medNameController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Medication")),
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

            // Date Picker
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

            // Save Medication Button
            ElevatedButton(
              onPressed: () {
                widget.onAddMedication(_medNameController.text, _time, _date);
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

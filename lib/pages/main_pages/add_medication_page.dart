import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import '../../database/medications_data.dart';
import 'package:provider/provider.dart';

class AddMedicationPage extends StatefulWidget {
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
  String? _selectedMedication;
  final GlobalKey _medNameKey = GlobalKey(); // Key to access TextField position

  // Formatter for date
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  OverlayEntry? _overlayEntry;

  FocusNode _focusNode = FocusNode(); // FocusNode to handle keyboard actions

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Function to show suggestions in the overlay
  void _showOverlay(BuildContext context) {
    final renderBox =
        _medNameKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return; // If render box is null, return

    final position = renderBox
        .localToGlobal(Offset.zero); // Get the position of the TextField

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy +
            renderBox.size.height +
            5, // Adjust the position below the TextField
        left: position.dx,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _removeOverlay(); // Remove overlay if user taps anywhere on it
            },
            child: Container(
              width: renderBox.size.width,
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                children: medicationSuggestions
                    .where((med) => med
                        .toLowerCase()
                        .contains(_medNameController.text.toLowerCase()))
                    .map((med) => ListTile(
                          title: Text(med),
                          onTap: () {
                            setState(() {
                              _selectedMedication = med;
                              _medNameController.text = med;
                            });
                            _removeOverlay(); // Remove overlay after selection
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Function to remove the overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Medication - Specific Day"),
        toolbarHeight: 70,
        backgroundColor: primaryColor,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard and the overlay if user taps outside
          FocusScope.of(context).requestFocus(FocusNode());
          _removeOverlay();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Medication Name Field
              TextField(
                key: _medNameKey, // Assign GlobalKey to TextField
                controller: _medNameController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: "Search for medication",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (medName) {
                  setState(() {
                    _selectedMedication = medName.isNotEmpty ? medName : null;
                  });
                  if (medName.isNotEmpty) {
                    _showOverlay(context); // Show overlay when typing
                  } else {
                    _removeOverlay(); // Remove overlay if the text field is empty
                  }
                },
                onEditingComplete: () {
                  // Close the overlay when user presses "done" or "check" on the keyboard
                  _removeOverlay();
                  FocusScope.of(context)
                      .requestFocus(FocusNode()); // Close the keyboard
                },
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

                  _dateFormatter.format(_expirationDate);
                  logger.e(
                      'Medication Date: $_date, Expiration Date: $_expirationDate');

                  Navigator.pop(context);
                },
                child: Text("Save Medication"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

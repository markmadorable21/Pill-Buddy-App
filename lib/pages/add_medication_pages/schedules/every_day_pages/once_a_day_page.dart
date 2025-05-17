import "package:flutter/material.dart";
import "package:animate_do/animate_do.dart";
import "package:intl/intl.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/expiration_page.dart";
import "package:pill_buddy/pages/add_medication_pages/schedules/reusable_time_inputter_page.dart";
import "package:provider/provider.dart";
import "package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart";
import "package:pill_buddy/pages/providers/medication_provider.dart";

class OnceADayPage extends StatefulWidget {
  const OnceADayPage({super.key});

  @override
  State<OnceADayPage> createState() => _OnceADayPageState();
}

class _OnceADayPageState extends State<OnceADayPage> {
  final TextEditingController _doseController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final selectedMed = Provider.of<MedicationProvider>(context).selectedMed;
    final medForm = Provider.of<MedicationProvider>(context).selectedForm;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Time: ${TimeOfDay.fromDateTime(_selectedDateTime).format(context)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  TimePickerSpinner(
                    is24HourMode: false,
                    normalTextStyle:
                        const TextStyle(fontSize: 18, color: Colors.black54),
                    highlightedTextStyle: TextStyle(
                      fontSize: 22,
                      color: primaryColor,
                    ),
                    spacing: 40,
                    itemHeight: 40,
                    isForce2Digits: true,
                    time: _selectedDateTime,
                    onTimeChange: (time) {
                      setState(() {
                        _selectedDateTime = time;
                      });
                    },
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
                      backgroundColor: //_doseController.text.isNotEmpty
                          primaryColor
                      //  : Colors.grey,
                      ),
                  onPressed: () {
                    context
                        .read<MedicationProvider>()
                        .selectDate(DateTime.now());
                    provider.selectFrequency("Once a day");
                    provider.selectTime(
                        DateFormat('hh:mm a').format(_selectedDateTime));
                    provider.selectAmount(_doseController.text);
                    final input = double.tryParse(_doseController.text);
                    // if (input == null || input <= 0) {
                    //   _showInvalidInputDialog(); //invalid input
                    // } else {
                    print('Form: $medForm');
                    print(
                        'Time selected: ${_selectedDateTime.toIso8601String()}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReusableTimeInputterPage(),
                      ),
                    );
                  }
                  //   }
                  ,
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

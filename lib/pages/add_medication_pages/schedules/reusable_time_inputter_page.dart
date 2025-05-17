import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/expiration_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/other_options_page.dart';

class ReusableTimeInputterPage extends StatefulWidget {
  const ReusableTimeInputterPage({super.key});

  @override
  _ReusableTimeInputterPageState createState() =>
      _ReusableTimeInputterPageState();
}

class _ReusableTimeInputterPageState extends State<ReusableTimeInputterPage> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: primaryColor,
        title: const Text("Select Time", style: TextStyle(color: Colors.white)),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Center(
              child: FadeInDown(
                child: Icon(Icons.access_time, size: 80, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                "Select the time for the medication",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            FadeIn(
              delay: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Text(
                    _selectedTime == null
                        ? "No time selected"
                        : "Selected Time: ${_selectedTime!.format(context)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.selectTime(
                        _selectedTime != null
                            ? DateFormat('h:mm a').format(DateTime(0, 0, 0,
                                _selectedTime!.hour, _selectedTime!.minute))
                            : DateFormat('h:mm a').format(DateTime.now()),
                      );

                      _pickTime(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Pick Time",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
                  onPressed: _selectedTime != null
                      ? () {
                          print(
                              "Time selected: ${_selectedTime!.format(context)}");
                          // Navigate to next step or save time to provider
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExpirationPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedTime != null ? primaryColor : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
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

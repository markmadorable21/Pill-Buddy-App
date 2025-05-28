import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/other_options_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExpirationPage extends StatefulWidget {
  const ExpirationPage({super.key});

  @override
  State<ExpirationPage> createState() => _MedicationExpirationPageState();
}

class _MedicationExpirationPageState extends State<ExpirationPage> {
  DateTime? _selectedDate;
  var logger = Logger();
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
        title: const Text("Expiration", style: TextStyle(color: Colors.white)),
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
                child:
                    Icon(Icons.calendar_today, size: 80, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                "Select the expiration date of the medication",
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
                    _selectedDate == null
                        ? "No date selected"
                        : "Expiration Date: ${DateFormat('MMM d, yyyy').format(_selectedDate!)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.selectExpiration(
                        _selectedDate != null
                            ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                            : DateFormat('MMM d, yyyy').format(DateTime.now()),
                      );

                      _pickDate(context);
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
                      "Pick Expiration Date",
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
                  onPressed: _selectedDate != null
                      ? () {
                          logger.e(
                              "Expiration Date: ${_selectedDate!.toIso8601String()}");
                          // Navigate to next step or save date to provider
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OtherOptionsPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedDate != null ? primaryColor : Colors.grey,
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

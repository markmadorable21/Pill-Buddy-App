import "package:flutter/material.dart";
import "package:animate_do/animate_do.dart";
import "package:provider/provider.dart";
import "package:pill_buddy/pages/providers/medication_provider.dart";

class OnceADayPage extends StatefulWidget {
  const OnceADayPage({super.key});

  @override
  State<OnceADayPage> createState() => _OnceADayPageState();
}

class _OnceADayPageState extends State<OnceADayPage> {
  final TextEditingController _doseController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final selectedMed = Provider.of<MedicationProvider>(context).selectedMed;
    final medForm = Provider.of<MedicationProvider>(context).selectedForm;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final unit = Provider.of<MedicationProvider>(context).unitForForm;

    Future<void> selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked;
        });
      }
    }

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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Text(
                    "Time: ${_selectedTime.format(context)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => selectTime(context),
                    child: const Text("Pick Time",
                        style: TextStyle(color: Colors.white)),
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
                    backgroundColor: _doseController.text.isNotEmpty
                        ? primaryColor
                        : Colors.grey,
                  ),
                  onPressed: _doseController.text.isNotEmpty
                      ? () {
                          print('unit is $medForm');
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

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/set_address_page.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_hope_to_achieve_page.dart';

class CreateProfileBirthdatePage extends StatefulWidget {
  const CreateProfileBirthdatePage({super.key});

  @override
  State<CreateProfileBirthdatePage> createState() =>
      _CreateProfileBirthdayPageState();
}

class _CreateProfileBirthdayPageState extends State<CreateProfileBirthdatePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  var logger = Logger();
  DateTime? selectedBirthDate; // Store the selected birthdate

  final DateTime _minAgeDate = DateTime.now()
      .subtract(const Duration(days: 18 * 365 + 5)); // im so smart HAHAAH

  @override
  void initState() {
    super.initState();
    // set up the fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // Method to calculate age from birthdate
  int _calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    final age = currentDate.year - birthDate.year;

    // Check if birthday has already occurred this year, if not subtract 1
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      return age - 1;
    }
    return age;
  }

  Future<void> _pickDate() async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _minAgeDate,
      firstDate: DateTime(1900),
      lastDate: _minAgeDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        selectedBirthDate = pickedDate;
      });
      provider.setBirthDate(pickedDate);
      // replay the fade if you want to highlight the change
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final hasDate = provider.birthDate != null;
    final displayText = hasDate
        ? "${provider.birthDateFormatted} (Age: ${_calculateAge(provider.birthDate!)})"
        : "Select your birthdate";
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.cake,
                  size: 80,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "What is your date of birth?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Subtitle
              const Text(
                "You must be at least 18 years old to use PillBuddy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Date picker field
              GestureDetector(
                onTap: _pickDate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: hasDate ? Colors.transparent : Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: hasDate
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 16,
                          color: hasDate ? Colors.black : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: primaryColor),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Next button
              AnimatedOpacity(
                opacity: hasDate ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasDate ? primaryColor : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: hasDate
                        ? () {
                            logger
                                .e('Birthdate: ${provider.birthDateFormatted}');
                            logger.e(
                                "Age: ${_calculateAge(provider.birthDate!)}");
                            provider.setAge(_calculateAge(provider.birthDate!));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SetAddressPage(),
                              ),
                            );
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
      ),
    );
  }
}

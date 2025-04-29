import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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

  final DateTime _minAgeDate =
      DateTime.now().subtract(const Duration(days: 18 * 365));

  @override
  void initState() {
    super.initState();
    // set up the fade‐in animation
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      provider.setBirthDate(pickedDate);
      // replay the fade if you want to highlight the change
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final hasDate = provider.birthDate != null;
    final displayText =
        hasDate ? provider.birthDateFormatted : "Select your birthdate";
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
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
                            final bday = provider.birthDateFormatted;
                            logger.e('Date: $bday');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateProfileHopeToAchievePage(),
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

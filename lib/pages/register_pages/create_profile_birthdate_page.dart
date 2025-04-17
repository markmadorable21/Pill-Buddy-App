import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pill_buddy/pages/register_pages/create_profile_hope_to_achieve_page.dart';

class CreateProfileBirthdatePage extends StatefulWidget {
  const CreateProfileBirthdatePage({super.key});

  @override
  State<CreateProfileBirthdatePage> createState() =>
      _CreateProfileBirthdayPageState();
}

class _CreateProfileBirthdayPageState extends State<CreateProfileBirthdatePage>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  final DateTime _minAgeDate =
      DateTime.now().subtract(const Duration(days: 18 * 365));
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for fade-in effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward(); // Start animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _minAgeDate,
      firstDate: DateTime(1900),
      lastDate: _minAgeDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation, // Page fade-in effect
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon with fade-in animation
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Icon(Icons.cake, size: 80, color: primaryColor),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "What is your date of birth?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Small Body Text
              const Text(
                "You must be at least 18 years old to use PillBuddy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Date Picker Button with animation
              GestureDetector(
                onTap: _pickDate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: _selectedDate != null
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat.yMMMMd().format(_selectedDate!)
                            : "Select your birthdate",
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: primaryColor),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Next Button with fade-in effect when a date is selected
              AnimatedOpacity(
                opacity: _selectedDate != null ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                          _selectedDate != null ? primaryColor : Colors.grey,
                    ),
                    onPressed: _selectedDate != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateProfileHopeToAchievePage()),
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

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_birthdate_page.dart';

class CreateProfileIdentityPage extends StatefulWidget {
  const CreateProfileIdentityPage({super.key});

  @override
  State<CreateProfileIdentityPage> createState() =>
      _CreateProfileIdentityPageState();
}

class _CreateProfileIdentityPageState extends State<CreateProfileIdentityPage> {
  final List<String> genderOptions = [
    "Male",
    "Female",
    "Non-binary",
    "Agender",
    "Bigender",
    "Cis Man",
    "Cis Woman",
    "Genderless",
    "Genderqueer",
    "Third Gender",
    "Transgender",
    "Trans Man",
    "Trans Woman",
    "Two-Spirit",
    "Prefer not to say"
  ];

  String? selectedGender; // Track selected gender

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents graying effect when scrolling
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black87), // Darker contrast
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
            const SizedBox(height: 20), // Top spacing

            // Icon (Static)
            Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Icon(LucideIcons.user, size: 80, color: primaryColor),
              ),
            ),

            const SizedBox(height: 20),

            // Title (Static)
            Center(
              child: FadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  "How do you identify?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Scrollable Gender Options
            Expanded(
              child: ListView.builder(
                itemCount: genderOptions.length,
                itemBuilder: (context, index) {
                  final gender = genderOptions[index];
                  final isSelected = selectedGender == gender;

                  return SlideInUp(
                    delay: Duration(
                        milliseconds:
                            100 + (index * 50)), // Staggered animations
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = gender;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey),
                          color: isSelected
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              gender,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? primaryColor : Colors.black,
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color:
                                      primaryColor), // Checkmark for selected option
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20), // Space before button

            // Next Button
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
                    backgroundColor:
                        selectedGender != null ? primaryColor : Colors.grey,
                  ),
                  onPressed: selectedGender != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateProfileBirthdatePage()),
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
    );
  }
}

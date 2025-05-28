import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/register_pages/caregiver_pages/create_my_profile_name_page_caregiver.dart';

class CreateMyProfilePageCaregiver extends StatefulWidget {
  const CreateMyProfilePageCaregiver({super.key});

  @override
  State<CreateMyProfilePageCaregiver> createState() =>
      _CreateMyProfilePageStateCaregiver();
}

class _CreateMyProfilePageStateCaregiver
    extends State<CreateMyProfilePageCaregiver>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Start below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(),

            // 🔵 Animated Icon
            FadeTransition(
              opacity: _fadeAnimation,
              child: Icon(Icons.volunteer_activism,
                  size: 100, color: primaryColor),
            ),

            const SizedBox(height: 40),

            // 🔵 Animated Text (Slide + Fade)
            SlideTransition(
              position: _slideAnimation,
              child: const Column(
                children: [
                  Text(
                    "Welcome, Caregiver",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Manage and support your loved ones’ health with ease. "
                    "Create your caregiver profile to get started.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Spacer(),

            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child, // Keeps button from rebuilding unnecessarily
                );
              },
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CreateProfileNamePageCaregiver()),
                    );
                  },
                  child: const Text(
                    "Create Caregiver Profile",
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

import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/login_pages/login_page.dart';
import 'package:pill_buddy/pages/register_pages/register_page.dart';

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      // Background Image
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/get_started_wallpaper2.jpeg'), // Add your image in assets folder
            fit: BoxFit.cover,
          ),
        ),
      ),

      const Center(
        child: Column(
          children: [],
        ),
      ),
      // Gradient Overlay
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8), // Dark at bottom
              Colors.black.withOpacity(0.7), // Fading effect
              Colors.transparent, // Full
            ],
            stops: const [0, 0.3, 1.0], // Control the fade effect
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Image.asset(
                'assets/images/pill_buddy_icon_final.png',
                height: 100,
              ),
              // App Name
              Text("Pill Buddy",
                  style: TextStyle(
                    fontSize: 70,
                    fontFamily: 'Rochester',
                    color: Theme.of(context).colorScheme.primaryFixed,
                  )),
              const SizedBox(height: 20),
              // App tagline
              Text(
                "Your health is our priority!\n\nJoin millions of people already taking control of their meds",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 40),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms and Privacy Policy
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    children: const [
                      TextSpan(text: "By proceeding, you agree to our "),
                      TextSpan(
                        text: "Terms",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                        // recognizer: TapGestureRecognizer()
                        //   ..onTap = () {
                        //     // Navigate to Terms page
                        //     print("Terms Clicked");
                        //   },
                      ),
                      TextSpan(text: " and that you have read our "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                        // recognizer: TapGestureRecognizer()
                        //   ..onTap = () {
                        //     // Navigate to Privacy Policy page
                        //     print("Privacy Policy Clicked");
                        //   },
                      ),
                      TextSpan(text: "."),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ] //children of stack
            ));
  }
}

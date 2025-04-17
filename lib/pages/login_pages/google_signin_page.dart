import 'package:flutter/material.dart';

class GoogleSIgninPage extends StatelessWidget {
  const GoogleSIgninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back Arrow
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered "Continue with Google!" text
            Center(
              child: Text(
                "Continue with Google!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Google Sign-In Box
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Sign in with Google" text
                  const Center(
                    child: Text(
                      "Sign in with Google",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // "Choose an account" text
                  const Text(
                    "Choose an account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  // "To continue to - Pill Buddy"
                  const Text(
                    "to continue to - Pill Buddy",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // List of Google Accounts (Dummy Data)
                  _buildAccountTile(
                      "Mark Madorable", "mark.madorable@gmail.com"),
                  _buildAccountTile("John Doe", "john.doe@example.com"),

                  // "Use another account"
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text(
                      "Use another account",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      // Handle adding a new Google account
                    },
                  ),
                  const SizedBox(height: 15),

                  // Google Disclaimer Text
                  const Text(
                    "To continue, Google will share your name, email address, language preference, and profile picture with Pill Buddy. Before using this app, you can review Pill Buddy’s privacy policy and terms of service.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Language Selector (Same size as "Help, Privacy, Terms")
            Center(
              child: DropdownButton<String>(
                value: "English",
                underline: Container(), // Removes default underline
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? value) {},
                items: ["English", "Español", "Français", "Deutsch", "中文"]
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child:
                              Text(lang, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 15),

            // Help, Privacy, Terms
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextButton("Help"),
                const Text(" • "),
                _buildTextButton("Privacy"),
                const Text(" • "),
                _buildTextButton("Terms"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a Google account list tile
  Widget _buildAccountTile(String name, String email) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name, style: const TextStyle(fontSize: 16)),
      subtitle: Text(email,
          style: const TextStyle(fontSize: 14, color: Colors.black)),
      onTap: () {
        // Handle account selection
      },
    );
  }

  // Function to create text buttons (Help, Privacy, Terms)
  Widget _buildTextButton(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

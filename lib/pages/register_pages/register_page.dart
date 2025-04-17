import "package:flutter/material.dart";
import "package:pill_buddy/pages/register_pages/create_my_profile_page.dart";

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please select what type of user you are.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Patient Selection Box
            _buildUserTypeBox(
              context,
              icon: Icons.person,
              label: "Patient",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateMyProfilePage()),
                );
              },
            ),
            const SizedBox(height: 16), // Space between the boxes

            // Caregiver Selection Box
            _buildUserTypeBox(
              context,
              icon: Icons.family_restroom,
              label: "Caregiver/Family",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create a user type selection box with a Flash Effect
  Widget _buildUserTypeBox(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent, // Keeps background clean
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16), // Rounded corners for the tap effect
        splashColor: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.3), // Flash color effect
        highlightColor: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.2), // Highlight effect
        child: Container(
          width: double.infinity, // Takes full width
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary), // Big Icon
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

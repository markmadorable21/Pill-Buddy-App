import "package:flutter/material.dart";
import "package:pill_buddy/pages/login_pages/login_page.dart";
import "package:pill_buddy/pages/providers/medication_provider.dart";
import "package:pill_buddy/pages/register_pages/caregiver_pages/create_my_profile_page_caregiver.dart";
import "package:pill_buddy/pages/register_pages/patient_pages/create_my_profile_page.dart";
import "package:provider/provider.dart";

class LoginPageUserType extends StatelessWidget {
  const LoginPageUserType({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your user type to continue.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Patient Selection Box
            _buildUserTypeBox(
              context,
              icon: Icons.person,
              label: "Patient",
              onTap: () {
                // Set user type to patient (not caregiver)
                Provider.of<MedicationProvider>(context, listen: false)
                    .setCaregiver(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                // Log for debugging
                logger.e(
                    'isCaregiver: ${Provider.of<MedicationProvider>(context, listen: false).isCaregiver}');
              },
            ),
            const SizedBox(height: 16),

            // Caregiver Selection Box
            _buildUserTypeBox(
              context,
              icon: Icons.family_restroom,
              label: "Caregiver/Family",
              onTap: () {
                // Set user type to caregiver
                Provider.of<MedicationProvider>(context, listen: false)
                    .setCaregiver(true);
                logger.e(
                    'isCaregiver: ${Provider.of<MedicationProvider>(context, listen: false).isCaregiver}');

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeBox(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        child: Container(
          width: double.infinity,
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
                  size: 50, color: Theme.of(context).colorScheme.primary),
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

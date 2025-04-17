import 'package:flutter/material.dart';

class TrackersPage extends StatelessWidget {
  const TrackersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Health Trackers", context),
          const SizedBox(height: 8),
          _buildTrackerCard(
              Icons.monitor_heart, "Heart Rate (BPM)", context, Colors.red, () {
            // Heart Rate card tapped
            print("Heart Rate tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.device_thermostat_sharp, "Body Temperature",
              context, Colors.blue, () {
            // Body Temperature card tapped
            print("Body Temperature tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(
              Icons.bloodtype, "Blood Pressure", context, Colors.green, () {
            // Blood Pressure card tapped
            print("Blood Pressure tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(
              Icons.monitor_weight, "Weight", context, Colors.orange, () {
            // Weight card tapped
            print("Weight tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.height, "Height", context, Colors.purple, () {
            // Height card tapped
            print("Height tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(
              Icons.calculate, "BMI Calculator", context, Colors.amber, () {
            // BMI Calculator card tapped
            print("BMI Calculator tapped");
          }),
          const SizedBox(height: 10),
          _buildWelcomeCard(context),
          const SizedBox(height: 10),
          _buildMedicationHelpCard(context),
          const SizedBox(height: 10),
          _buildSignupCard(context),
          const SizedBox(height: 10),
          _buildSectionHeader("Appointments", context),
          const SizedBox(height: 10),
          _buildAppointmentCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, context) {
    return Row(
      children: [
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }

  // Custom Tracker Card with icon color and onTap function
  Widget _buildTrackerCard(IconData icon, String title, context,
      Color iconColor, VoidCallback onTap) {
    return SizedBox(
      height: 95,
      child: Card(
        elevation: 3,
        child: GestureDetector(
          onTap: onTap, // Adding onTap functionality
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            leading: Icon(icon, color: iconColor), // Custom icon color
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ),
    );
  }

  // Welcome Card
  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/welcome_photo.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to Pill Buddy!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Pill Buddy helps you remember when to take your meds, notify your family or caregiver, and keep track of your health.",
                ),
                const SizedBox(height: 12),
                const Text("Need help? Just ask our support team!"),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {},
                        style: _eButtonStyle(context),
                        child: const Text("Learn more",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white))),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Medication Help Card
  Widget _buildMedicationHelpCard(context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Having trouble adding your meds?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Any problems adding meds or setting reminders in Medisafe? Visit our Help Center for answers!",
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _eButtonStyle(context),
                  onPressed: () {},
                  child: const Text("Add a medication",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: _eButtonStyle(context).copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.white)),
                    onPressed: () {},
                    child: const Text(
                      "Check out Help Center",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
              ),
            ),
            const SizedBox(height: 8)
          ],
        ),
      ),
    );
  }

  // Signup Card
  Widget _buildSignupCard(context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Complete your Sign-Up to keep track of your progress",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            const Text(
              "You've started your sign-up, but it looks like your verification code has expired.",
            ),
            const SizedBox(height: 10),
            const Text(
              "Complete the process to ensure we can recover your info if your device is lost or damaged.",
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: _eButtonStyle(context),
                    onPressed: () {},
                    child: const Text("Complete Sign-up now",
                        style: TextStyle(fontSize: 18, color: Colors.white))),
              ),
            ),
            const SizedBox(height: 8)
          ],
        ),
      ),
    );
  }

  // Appointment Card
  Widget _buildAppointmentCard(context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.calendar_month,
                size: 60, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            const Text("Track appointments and doctor visits",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
                "Keep all your health visits in one place. Get assistance preparing for and summarizing visits.",
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: _eButtonStyle(context),
                    onPressed: () {},
                    child: const Text("Add an appointment",
                        style: TextStyle(fontSize: 18, color: Colors.white)))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Button Style
  ButtonStyle _eButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}

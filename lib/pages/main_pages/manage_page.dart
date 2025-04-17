import 'package:flutter/material.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Essentials", context),
          const SizedBox(height: 8),
          _buildTrackerCard(
              Icons.medication, "Medications", context, Colors.blue, () {
            // Action for Medications card
            print("Medications tapped");
          }), // Custom icon color with onTap
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.report, "Report", context, Colors.green, () {
            // Action for Report card
            print("Report tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(
              Icons.calendar_month, "Appointments", context, Colors.orange, () {
            // Action for Appointments card
            print("Appointments tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.book, "Diary Notes", context, Colors.purple,
              () {
            // Action for Diary Notes card
            print("Diary Notes tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.person_2, "Doctors", context, Colors.red, () {
            // Action for Doctors card
            print("Doctors tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.add_box, "Refills", context, Colors.amber,
              () {
            // Action for Refills card
            print("Refills tapped");
          }),
          const SizedBox(height: 20),
          _buildSectionHeader("Settings", context),
          const SizedBox(height: 10),
          _buildTrackerCard(
              Icons.settings, "App Settings", context, Colors.brown, () {
            // Action for App Settings card
            print("App Settings tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(Icons.alarm, "Reminders", context, Colors.teal, () {
            // Action for Reminders card
            print("Reminders tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(
              Icons.help_center, "Help Center", context, Colors.indigo, () {
            // Action for Help Center card
            print("Help Center tapped");
          }),
          const SizedBox(height: 5),
          _buildTrackerCard(
              Icons.share, "Share Pill Buddy", context, Colors.pink, () {
            // Action for Share Pill Buddy card
            print("Share Pill Buddy tapped");
          }),
          const SizedBox(height: 5),
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

  // Modified Tracker Card with icon color and onTap function
  Widget _buildTrackerCard(IconData icon, String title, context,
      Color iconColor, VoidCallback onTap) {
    return SizedBox(
      height: 95,
      child: Card(
        elevation: 3,
        child: ListTile(
          onTap: onTap, // Adding onTap functionality
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          leading: Icon(icon, color: iconColor), // Custom icon color
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}

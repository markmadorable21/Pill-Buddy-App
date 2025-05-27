import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';
import 'package:pill_buddy/pages/providers/door_status_provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class DoorSelectionPage extends StatelessWidget {
  const DoorSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doorStatus = context.watch<DoorStatusProvider>();
    final provider = context.read<MedicationProvider>();
    final deviceId = provider.deviceId;
    final primaryColor = Theme.of(context).colorScheme.primary.withAlpha(120);
    var logger = Logger();

    // Helper: get door status for current device and door index
    bool doorAdded(int doorIndex) {
      if (deviceId == 'PillBuddy1') {
        return doorIndex == 0
            ? doorStatus.pb1Door1Added
            : doorStatus.pb1Door2Added;
      } else if (deviceId == 'PillBuddy2') {
        return doorIndex == 0
            ? doorStatus.pb2Door1Added
            : doorStatus.pb2Door2Added;
      } else {
        return false;
      }
    }

    Widget buildDoorBox({
      required String label,
      required bool disabled,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: disabled ? Colors.grey[300] : primaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: disabled ? Colors.grey : primaryColor, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: disabled ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Select Door for $deviceId',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDoorBox(
              label: 'Door 1',
              disabled: doorAdded(0),
              onTap: () {
                provider.setSelectedDoorIndex(0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReusableAddMedNamePage()),
                );
                logger.i('$deviceId Door 1 selected');
              },
            ),
            const SizedBox(height: 20),
            buildDoorBox(
              label: 'Door 2',
              disabled: doorAdded(1),
              onTap: () {
                provider.setSelectedDoorIndex(1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReusableAddMedNamePage()),
                );
                logger.i('$deviceId Door 2 selected');
              },
            ),
          ],
        ),
      ),
    );
  }
}

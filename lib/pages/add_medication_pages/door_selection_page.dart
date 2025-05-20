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
    final primaryColor = Theme.of(context).colorScheme.primary;
    var logger = Logger();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Door')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: primaryColor,
              ),
              onPressed: doorStatus.door1Added
                  ? null
                  : () {
                      final provider = context.read<MedicationProvider>();
                      provider.setSelectedDoorIndex(0); // for Door 1
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReusableAddMedNamePage()),
                      );

                      logger.e('Door 1 selected');
                    },
              child: const Text(
                'Door 1',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: primaryColor,
              ),
              onPressed: doorStatus.door2Added
                  ? null
                  : () {
                      final provider = context.read<MedicationProvider>();
                      provider.setSelectedDoorIndex(1); // for Door 2
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReusableAddMedNamePage()),
                      );
                      logger.e('Door 2 selected');
                    },
              child: const Text(
                'Door 2',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

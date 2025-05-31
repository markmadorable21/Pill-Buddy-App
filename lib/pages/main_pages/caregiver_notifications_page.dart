import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart'; // adjust this import if needed

class NotificationsPageCaregiver extends StatefulWidget {
  const NotificationsPageCaregiver({super.key});

  @override
  State<NotificationsPageCaregiver> createState() =>
      _NotificationsPageCaregiverState();
}

class _NotificationsPageCaregiverState
    extends State<NotificationsPageCaregiver> {
  DatabaseReference? _deviceRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deviceId =
        Provider.of<MedicationProvider>(context, listen: false).deviceId;

    if (deviceId.isNotEmpty) {
      _deviceRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref().child(deviceId);
    }
  }

  String _formatTo12Hour(String timeString) {
    try {
      // Handle both 'HH.mm' and 'HH:MM'
      final parts = timeString.contains('.')
          ? timeString.split('.')
          : timeString.split(':');
      if (parts.length != 2) return timeString;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final dt = DateTime(2020, 1, 1, hour, minute); // arbitrary date
      final formatted =
          TimeOfDay.fromDateTime(dt).format(context); // uses locale
      return formatted; // e.g., "2:45 PM"
    } catch (_) {
      return timeString; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = Provider.of<MedicationProvider>(context).deviceId;

    if (deviceId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No device selected.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title:
            const Text('Notifications', style: TextStyle(color: Colors.blue)),
        elevation: 0,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _deviceRef!.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No data found for this device."));
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<_MissedMedication> missedMeds = [];

          for (final door in ['Door1', 'Door2']) {
            final doorData = data[door];
            if (doorData is Map) {
              final medName = doorData['med']?.toString() ?? 'Unknown';
              for (int i = 1; i <= 4; i++) {
                final status = doorData['status$i']?.toString();
                final time = doorData['time$i']?.toString();
                if (status == 'missed') {
                  missedMeds.add(
                    _MissedMedication(
                      door: door,
                      medName: medName,
                      time: time ?? '',
                    ),
                  );
                }
              }
            }
          }

          if (missedMeds.isEmpty) {
            return const Center(child: Text("No missed medications."));
          }

          return ListView.builder(
            itemCount: missedMeds.length,
            itemBuilder: (context, index) {
              final missed = missedMeds[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    missed.medName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                      'Missed at ${_formatTo12Hour(missed.time)} on ${missed.door}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _notifyPatient(missed);
                    },
                    child: const Text("Notify"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _notifyPatient(_MissedMedication missed) {
    debugPrint(
        "🔔 Notify: ${missed.medName} from ${missed.door}  at ${missed.time}");
    // Placeholder for actual notification logic
  }
}

class _MissedMedication {
  final String door;
  final String medName;
  final String time;

  _MissedMedication({
    required this.door,
    required this.medName,
    required this.time,
  });
}

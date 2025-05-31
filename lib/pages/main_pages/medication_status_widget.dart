import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'medication_status_manager.dart';

class MedicationStatusWidget extends StatefulWidget {
  final String deviceId;

  const MedicationStatusWidget({
    super.key,
    required this.deviceId,
  });

  @override
  State<MedicationStatusWidget> createState() => _MedicationStatusWidgetState();
}

class _MedicationStatusWidgetState extends State<MedicationStatusWidget> {
  late MedicationStatusManager _statusManager;
  String _statusText = '';
  double? _activeTime;

  @override
  void initState() {
    super.initState();

    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

    _statusManager = MedicationStatusManager(
      deviceId: widget.deviceId,
      database: database,
      onStatusUpdate: (status, time) {
        if (!mounted) return;
        setState(() {
          _statusText = status;
          _activeTime = time;
        });
      },
    );

    _statusManager.startListening();
  }

  @override
  void dispose() {
    _statusManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Medication Status",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _activeTime != null
              ? 'Time $_activeTime → $_statusText'
              : 'No scheduled meds yet',
          style: TextStyle(
            fontSize: 14,
            color: _statusText == 'missed'
                ? Colors.red
                : _statusText == 'pending'
                    ? Colors.orange
                    : _statusText == 'taken'
                        ? Colors.green
                        : Colors.grey,
          ),
        ),
      ],
    );
  }
}

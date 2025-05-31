import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget that monitors both Door1 and Door2 of a device,
/// finds the earliest un-processed time slot, and shows Taken/Pending/Missed.
class MedicationStatusMonitor extends StatefulWidget {
  final String deviceId;
  const MedicationStatusMonitor({super.key, required this.deviceId});

  @override
  State<MedicationStatusMonitor> createState() =>
      _MedicationStatusMonitorState();
}

class _MedicationStatusMonitorState extends State<MedicationStatusMonitor> {
  late final DatabaseReference _deviceRef;
  Timer? _missedTimer;

  @override
  void initState() {
    super.initState();
    _deviceRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref().child(widget.deviceId);
  }

  @override
  void dispose() {
    _missedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _deviceRef.onValue,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        if (!snap.hasData || snap.data!.snapshot.value == null) {
          return const Text("No data");
        }

        final data = snap.data!.snapshot.value as Map<dynamic, dynamic>;
        final clicked = data['clicked'] == true;

        // 1) Gather all (door, index, time, status) entries
        final List<_TimeEntry> entries = [];
        for (var doorKey in ['Door1', 'Door2']) {
          final door = data[doorKey];
          if (door is Map) {
            for (var i = 1; i <= 4; i++) {
              final rawTime = door['time$i'];
              final rawStatus = door['status$i'];
              if (rawTime is num &&
                  (rawStatus is String && rawStatus.isNotEmpty)) {
                final scheduled = _toDateTime(rawTime.toDouble());
                entries.add(_TimeEntry(
                  doorKey: doorKey,
                  index: i,
                  scheduled: scheduled,
                  status: rawStatus,
                ));
              }
            }
          }
        }

        if (entries.isEmpty) {
          return const Text("No scheduled doses");
        }

        // 2) Sort by scheduled time (today)
        entries.sort((a, b) => a.scheduled.compareTo(b.scheduled));

        // 3) Pick the earliest entry that is not already taken or missed
        final now = DateTime.now();
        _TimeEntry? current;
        for (var e in entries) {
          if (e.status != 'taken' && e.status != 'missed') {
            current = e;
            break;
          }
        }

        if (current == null) {
          return const Text("All doses processed");
        }

        // 4) Logic for that entry
        final diff = now.difference(current.scheduled);
        final doorPath = '${widget.deviceId}/${current.doorKey}';

        // If it's not yet time
        if (diff.isNegative) {
          return _styledText(
              'Not up yet', Colors.grey); // show nothing until scheduled time
        }

        // If clicked already, mark/take
        if (clicked && current.status != 'taken') {
          _updateStatus(current, 'taken');
          return _styledText('Taken', Colors.green);
        }

        // If within 10 minutes window
        if (!clicked && diff.inMinutes < 1) {
          if (current.status != 'pending') {
            _updateStatus(current, 'pending');
          }
          // schedule a timer to re-check at exactly 10 minutes if still unclicked
          _missedTimer?.cancel();
          _missedTimer = Timer(
            current.scheduled.add(const Duration(minutes: 1)).difference(now),
            () => _deviceRef
                .child(current!.doorKey)
                .child('status${current.index}')
                .set('missed'),
          );
          return _styledText('Pending', Colors.orange); // pending shows nothing
        }

        // If window passed and still unclicked
        if (!clicked && diff.inMinutes >= 1 && current.status != 'missed') {
          _updateStatus(current, 'missed');
          return _styledText('Missed', Colors.red);
        }

        // Fallback: if already marked
        if (current.status == 'taken') {
          return _styledText('Taken', Colors.green);
        }
        if (current.status == 'missed') {
          return _styledText('Missed', Colors.red);
        }

        return const SizedBox();
      },
    );
  }

  /// Converts a HH.mm double (e.g. 08.30, 14.45) to a DateTime today.
  DateTime _toDateTime(double hhmm) {
    final hours = hhmm.floor();
    final minutes = ((hhmm - hours) * 100).round();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hours, minutes);
  }

  Widget _styledText(String text, Color color) => Text(
        text,
        style:
            TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
      );

  Future<void> _updateStatus(_TimeEntry e, String newStatus) async {
    await _deviceRef.child(e.doorKey).child('status${e.index}').set(newStatus);
  }
}

/// Internal model for a scheduled dose entry
class _TimeEntry {
  final String doorKey;
  final int index;
  final DateTime scheduled;
  final String status;
  _TimeEntry({
    required this.doorKey,
    required this.index,
    required this.scheduled,
    required this.status,
  });
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/providers/notification_badge_provider.dart';
import 'package:provider/provider.dart';

class NotificationsPagePatient extends StatefulWidget {
  const NotificationsPagePatient({super.key});

  @override
  State<NotificationsPagePatient> createState() =>
      _NotificationsPagePatientState();
}

class _NotificationsPagePatientState extends State<NotificationsPagePatient> {
  DatabaseReference? _deviceRef;
  bool _isRead = false;
  List<_MissedMedication> _missedList = [];

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
      final parts = timeString.contains('.')
          ? timeString.split('.')
          : timeString.split(':');
      if (parts.length != 2) return timeString;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2020, 1, 1, hour, minute);
      return TimeOfDay.fromDateTime(dt).format(context);
    } catch (_) {
      return timeString;
    }
  }

  // String _timeAgo(String? timeString) {
  //   if (timeString == null || timeString.isEmpty) return '';
  //   try {
  //     final parts = timeString.contains('.')
  //         ? timeString.split('.')
  //         : timeString.split(':');
  //     if (parts.length != 2) return '';
  //     final hour = int.parse(parts[0]);
  //     final minute = int.parse(parts[1]);

  //     final now = DateTime.now();
  //     final notifTime = DateTime(
  //         now.year, now.month, now.day, hour, minute); // same day reference

  //     final duration = now.difference(notifTime);

  //     if (duration.inHours > 0) return '${duration.inHours}h';
  //     return '${duration.inMinutes}m';
  //   } catch (_) {
  //     return '';
  //   }
  // }

  void _markAsRead() {
    setState(() {
      _isRead = true;
    });
    Provider.of<NotificationBadge>(context, listen: false).update(0);
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = Provider.of<MedicationProvider>(context).deviceId;

    if (deviceId.isEmpty) {
      return const Scaffold(body: Center(child: Text("No device selected.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: _markAsRead,
            child: const Text(
              "Read All",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _deviceRef!.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<NotificationBadge>(context, listen: false).update(0);
            });
            return const Center(child: Text("No missed meds."));
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          _missedList.clear();

          for (final door in ['Door1', 'Door2']) {
            final doorData = data[door];
            if (doorData is Map) {
              final medName = doorData['med']?.toString() ?? 'Unknown';
              for (int i = 1; i <= 4; i++) {
                final status = doorData['status$i']?.toString();
                final time = doorData['time$i']?.toString();
                final isNotified = doorData['isNotified$i'] ?? false;
                if (status == 'missed' && isNotified == true) {
                  _missedList.add(_MissedMedication(
                    door: door,
                    medName: medName,
                    time: time ?? '',
                  ));
                }
              }
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isRead) {
              Provider.of<NotificationBadge>(context, listen: false)
                  .update(_missedList.length);
            }
          });

          if (_missedList.isEmpty) {
            return const Center(child: Text("No missed meds notified."));
          }

          final today = _missedList.where((m) => _isToday(m.time)).toList()
            ..sort((a, b) => b.time.compareTo(a.time));
          final earlier = _missedList.where((m) => !_isToday(m.time)).toList()
            ..sort((a, b) => b.time.compareTo(a.time));

          return ListView(
            children: [
              if (today.isNotEmpty)
                _buildSection("Today", today, read: _isRead),
              if (earlier.isNotEmpty)
                _buildSection("Earlier", earlier, read: _isRead),
            ],
          );
        },
      ),
    );
  }

  bool _isToday(String timeString) {
    try {
      final parts = timeString.contains('.') //
          ? timeString.split('.')
          : timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      final notif = DateTime(now.year, now.month, now.day, hour, minute);
      return notif.day == now.day &&
          notif.month == now.month &&
          notif.year == now.year;
    } catch (_) {
      return true; // default to today
    }
  }

  Widget _buildSection(
    String label,
    List<_MissedMedication> list, {
    required bool read,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...list.map((missed) {
          return Card(
            color: read ? Colors.grey[300] : Colors.green[100],
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListTile(
              leading: Icon(Icons.notifications_active,
                  color: Theme.of(context).primaryColor),
              title: Text("Reminder: ${missed.medName}"),
              subtitle: Text(
                "You missed this at ${_formatTo12Hour(missed.time)} on ${missed.door}",
              ),
            ),
          );
        }),
      ],
    );
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

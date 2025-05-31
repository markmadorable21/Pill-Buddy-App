import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClickedStatusText extends StatefulWidget {
  final String deviceId;
  final String doorKey;

  const ClickedStatusText({
    super.key,
    required this.deviceId,
    required this.doorKey,
  });

  @override
  State<ClickedStatusText> createState() => _ClickedStatusTextState();
}

class _ClickedStatusTextState extends State<ClickedStatusText> {
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref().child(widget.deviceId).child(widget.doorKey);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: dbRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Text("No data");
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final clicked = data['clicked'] == true;

        final now = DateTime.now();
        final currentTime = double.parse(DateFormat('HH.mm').format(now));

        for (int i = 1; i <= 4; i++) {
          final rawTime = data['time$i'];
          final rawStatus = data['status$i'];

          if (rawTime == null || rawStatus == null) continue;

          final scheduledTime = (rawTime is num)
              ? rawTime.toDouble()
              : double.tryParse(rawTime.toString()) ?? 0.0;
          final status = rawStatus.toString();

          final isNow =
              currentTime >= scheduledTime && currentTime < scheduledTime + 0.1;
          final isMissed = currentTime >= scheduledTime + 0.1 &&
              status != 'missed' &&
              status != 'taken';

          // Handle current time slot only
          if (isNow) {
            if (clicked && status != 'taken') {
              _updateStatus(i, 'taken');
              return _styledText('Taken', Colors.green);
            } else if (!clicked && status != 'pending') {
              _updateStatus(i, 'pending');
              return const SizedBox(); // show nothing for pending
            }

            // show already taken
            if (status == 'taken') {
              return _styledText('Taken', Colors.green);
            }
          }

          // Handle past missed case
          if (isMissed) {
            _updateStatus(i, 'missed');
            return _styledText('Missed', Colors.red);
          }

          // show past states
          if (status == 'taken') return _styledText('Taken', Colors.green);
          if (status == 'missed') return _styledText('Missed', Colors.red);
        }

        return const SizedBox(); // fallback
      },
    );
  }

  Widget _styledText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _updateStatus(int index, String newStatus) async {
    final statusRef = dbRef.child('status$index');
    await statusRef.set(newStatus);
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';

// class MedicationStatusChecker extends StatefulWidget {
//   final String deviceId;

//   const MedicationStatusChecker({super.key, required this.deviceId});

//   @override
//   State<MedicationStatusChecker> createState() => _MedicationStatusCheckerState();
// }

// class _MedicationStatusCheckerState extends State<MedicationStatusChecker> {
//   final databaseURL = 'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app';
//   late DatabaseReference deviceRef;
//   String statusText = '';
//   Timer? checkTimer;

//   @override
//   void initState() {
//     super.initState();
//     deviceRef = FirebaseDatabase.instanceFor(
//       app: Firebase.app(),
//       databaseURL: databaseURL,
//     ).ref().child(widget.deviceId);

//     _startListening();
//   }

//   void _startListening() {
//     deviceRef.onValue.listen((event) {
//       final data = event.snapshot.value as Map?;
//       if (data == null) return;

//       final door1 = data['Door1'] as Map?;
//       final door2 = data['Door2'] as Map?;
//       final timeMap = <String, double>{};

//       void collectTimes(Map? door, String doorKey) {
//         if (door == null) return;
//         for (int i = 1; i <= 4; i++) {
//           final t = door['time$i'];
//           if (t is num && t > 0) {
//             timeMap['$doorKey_time$i'] = t.toDouble();
//           }
//         }
//       }

//       collectTimes(door1, 'Door1');
//       collectTimes(door2, 'Door2');

//       if (timeMap.isEmpty) return;

//       final sortedTimes = timeMap.entries.toList()
//         ..sort((a, b) => a.value.compareTo(b.value));

//       _processTimes(sortedTimes, data);
//     });
//   }

//   void _processTimes(List<MapEntry<String, double>> sorted, Map dataSnapshot) {
//     final now = DateTime.now();
//     final currentTimeDecimal = double.parse('${now.hour}.${now.minute.toString().padLeft(2, '0')}');

//     for (final entry in sorted) {
//       final timeKey = entry.key; // e.g. "Door1_time2"
//       final scheduledTime = entry.value;

//       // Only check for current or just-passed times (minute-sensitive)
//       if ((currentTimeDecimal - scheduledTime).abs() < 0.02) {
//         final parts = timeKey.split('_'); // [Door1, time2]
//         final door = parts[0];
//         final timeNum = parts[1]; // e.g. time2
//         final statusKey = 'status${timeNum.substring(4)}'; // status2

//         final doorData = dataSnapshot[door] as Map?;
//         if (doorData == null) return;

//         final clicked = doorData['clicked'];
//         final status = doorData[statusKey];

//         if (clicked == true) {
//           _setStatus('taken');
//         } else {
//           _setStatus('pending');

//           checkTimer?.cancel();
//           checkTimer = Timer(const Duration(minutes: 10), () async {
//             final clickedNowSnapshot = await deviceRef.child('$door/clicked').get();
//             final clickedNow = clickedNowSnapshot.value;
//             if (clickedNow == false) {
//               await deviceRef.child('$door/$statusKey').set('missed');
//               _setStatus('missed');
//             }
//           });
//         }

//         break; // Only the earliest time is checked at a time
//       }
//     }
//   }

//   void _setStatus(String newStatus) {
//     if (mounted) {
//       setState(() {
//         statusText = newStatus;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     checkTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       'Status: $statusText',
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: statusText == 'missed'
//             ? Colors.red
//             : statusText == 'pending'
//                 ? Colors.orange
//                 : Colors.green,
//       ),
//     );
//   }
// }

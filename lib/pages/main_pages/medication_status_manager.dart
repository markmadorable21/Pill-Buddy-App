import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'time_comparator.dart';

class MedicationStatusManager {
  final String deviceId;
  final FirebaseDatabase database;
  final void Function(String status, double time)? onStatusUpdate;

  MedicationStatusManager({
    required this.deviceId,
    required this.database,
    this.onStatusUpdate,
  });

  StreamSubscription<DatabaseEvent>? _subscription;
  final Map<double, Timer> _timers = {};
  bool _processing = false;

  void startListening() {
    final ref = database.ref(deviceId);

    _subscription = ref.onValue.listen((event) {
      if (_processing) return;

      final data = event.snapshot.value;
      if (data is! Map) return;

      _processing = true;

      try {
        final List<Map<String, dynamic>> doors = [];
        for (final key in ['Door1', 'Door2']) {
          final doorData = data[key];
          if (doorData is Map) {
            doors.add(Map<String, dynamic>.from(doorData));
          }
        }

        final allTimeData = <Map<String, dynamic>>[];

        for (final door in doors) {
          for (int i = 1; i <= 4; i++) {
            final timeKey = 'time$i';
            final statusKey = 'status$i';

            final timeVal = door[timeKey];
            final statusVal = door[statusKey];
            final clicked = door['clicked'] ?? false;

            if (timeVal is num && timeVal > 0 && statusVal == '') {
              allTimeData.add({
                'time': timeVal.toDouble(),
                'doorKey': door['med'] ?? 'Unknown',
                'statusKey': statusKey,
                'clicked': clicked,
              });
            }
          }
        }

        // Sort all valid time entries
        final sortedTimes = TimeComparator.sortTimes(
          allTimeData.map((e) => e['time'] as double).toList(),
        );

        if (sortedTimes.isEmpty) {
          _processing = false;
          return;
        }

        final earliest = sortedTimes.first;

        final targetEntry =
            allTimeData.firstWhere((e) => e['time'] == earliest);

        final clicked = targetEntry['clicked'] == true;
        final time = targetEntry['time'] as double;
        final statusKey = targetEntry['statusKey'] as String;

        final doorKey = data['Door1'] != null &&
                (data['Door1']['time1'] == time ||
                    data['Door1']['time2'] == time ||
                    data['Door1']['time3'] == time ||
                    data['Door1']['time4'] == time)
            ? 'Door1'
            : 'Door2';

        final path = database.ref(deviceId).child(doorKey).child(statusKey);

        if (TimeComparator.isNowEqualToTime(time) && !clicked) {
          onStatusUpdate?.call('pending', time);

          _timers[time]?.cancel();
          _timers[time] = Timer(const Duration(minutes: 10), () async {
            // Re-fetch clicked before marking as missed
            final clickedSnapshot = await database
                .ref(deviceId)
                .child(doorKey)
                .child('clicked')
                .get();

            if (clickedSnapshot.value != true) {
              await path.set('missed');
              onStatusUpdate?.call('missed', time);
            }

            _timers.remove(time);
          });
        } else if (TimeComparator.isNowEqualToTime(time) && clicked) {
          onStatusUpdate?.call('taken', time);
          path.set('taken');
        }
      } catch (e) {
        debugPrint('Error in MedicationStatusManager: $e');
      } finally {
        _processing = false;
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

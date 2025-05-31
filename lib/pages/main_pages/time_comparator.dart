import 'package:flutter/material.dart';

class TimeComparator {
  /// Converts a decimal time (e.g. 13.25) to a DateTime object for today.
  static DateTime decimalToDateTime(double decimalTime) {
    final int hour = decimalTime.floor();
    final int minute = ((decimalTime - hour) * 100).round();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Returns true if current time is equal to given Firebase time (within 1 minute buffer).
  static bool isNowEqualToTime(double firebaseTime) {
    final DateTime now = DateTime.now();
    final DateTime targetTime = decimalToDateTime(firebaseTime);
    final difference = now.difference(targetTime).inMinutes;
    return difference >= 0 && difference <= 1;
  }

  /// Returns true if current time is more than 10 minutes past the given time.
  static bool isMissedTime(double firebaseTime) {
    final DateTime now = DateTime.now();
    final DateTime targetTime = decimalToDateTime(firebaseTime);
    return now.isAfter(targetTime.add(const Duration(minutes: 10)));
  }

  /// Returns how many minutes ago the firebase time was from now.
  static int minutesSinceTime(double firebaseTime) {
    final DateTime now = DateTime.now();
    final DateTime targetTime = decimalToDateTime(firebaseTime);
    return now.difference(targetTime).inMinutes;
  }

  /// Sorts a list of time entries (as doubles) in chronological order.
  static List<double> sortTimes(List<double> times) {
    final now = DateTime.now();
    times.sort((a, b) {
      final aTime = decimalToDateTime(a);
      final bTime = decimalToDateTime(b);
      return aTime.compareTo(bTime);
    });
    return times;
  }
}

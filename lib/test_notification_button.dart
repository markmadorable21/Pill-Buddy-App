// lib/widgets/test_notification_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // to import notificationsPlugin

class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Show Test Notification'),
      onPressed: () async {
        const androidDetails = AndroidNotificationDetails(
          'med_channel', // ← same ID from main()
          'Medication Reminders',
          importance: Importance.max,
          priority: Priority.high,
        );
        const platformDetails = NotificationDetails(
          android: androidDetails,
        );

        await notificationsPlugin.show(
          0,
          'Hello from Pill Buddy!',
          'Take your fucking med!',
          platformDetails,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ScheduleTestPage extends StatefulWidget {
  const ScheduleTestPage({super.key});

  @override
  State<ScheduleTestPage> createState() => _ScheduleTestPageState();
}

class _ScheduleTestPageState extends State<ScheduleTestPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _initializeNotification();
  }

  Future<void> _initializeNotification() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(initializationSettings);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'med_channel',
            'Medication Reminders',
            description: 'Daily pill alarms',
            importance: Importance.max,
          ),
        );

    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final iosImplementation = plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  TimeOfDay? _parseTimeFromDoubleString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split('.');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _scheduleManualTimes() async {
    final List<TimeOfDay> validTimes = [];

    for (int i = 0; i < _controllers.length; i++) {
      final text = _controllers[i].text.trim();
      final parsed = _parseTimeFromDoubleString(text);
      debugPrint('Input [$i]: "$text" → Parsed: $parsed');
      if (parsed != null) {
        validTimes.add(parsed);
      }
    }

    if (validTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please enter at least one valid time in HH.mm format.")),
      );
      debugPrint('⚠️ No valid times found, aborting scheduling.');
      return;
    }

    for (int i = 0; i < validTimes.length; i++) {
      final time = validTimes[i];
      final now = DateTime.now();
      final scheduledTime =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);
      final targetTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      try {
        debugPrint('🕒 Scheduling notification [$i] for: $targetTime');

        await notificationsPlugin.zonedSchedule(
          i, // Notification ID
          'Pill Buddy Reminder 💊',
          'Time to take your medication!',
          tz.TZDateTime.from(targetTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'med_channel',
              'Medication Reminders',
              channelDescription: 'Daily pill alarms',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        debugPrint('✅ Notification [$i] scheduled successfully.');
      } catch (e, stackTrace) {
        debugPrint('❌ Failed to schedule notification [$i]: $e');
        debugPrint('StackTrace: $stackTrace');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Notifications scheduling attempted. Check logs.")),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Time Scheduler'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter time in HH.mm format (e.g., 08.30, 21.45):'),
            const SizedBox(height: 8),
            ..._controllers.map((controller) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter time (HH.mm)',
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scheduleManualTimes,
              child: const Text('Schedule Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

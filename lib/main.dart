import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';

import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/firebase_options.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/test2_country_plus_ph.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/test_add_new_caregiver_page.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/test_country_state_picker.dart';
import 'package:pill_buddy/pages/add_medication_pages/door_selection_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/reminders_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_med_form_amt_qty_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/once_a_day_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/schedule_test_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_x_days_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/recurring_cycle_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/reusable_date_inputter_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/reusable_time_inputter_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/specific_day_pages/set_amount_date_time_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/specific_days_of_week_page.dart';
import 'package:pill_buddy/pages/add_patient_pages/add_patient_page.dart';
import 'package:pill_buddy/pages/add_patient_pages/check_patient_email_page.dart';
import 'package:pill_buddy/pages/login_pages/login_page.dart';
import 'package:pill_buddy/pages/login_pages/login_page_user_type.dart';
import 'package:pill_buddy/pages/main_pages/add_medication_page.dart';
import 'package:pill_buddy/pages/main_pages/home_page.dart';
import 'package:pill_buddy/pages/main_pages/main_page.dart';
import 'package:pill_buddy/pages/main_pages/test_home_page.dart';
import 'package:pill_buddy/pages/providers/address_provider.dart';
import 'package:pill_buddy/pages/providers/door_status_provider.dart';
import 'package:pill_buddy/pages/providers/testmedprovider.dart';
import 'package:pill_buddy/pages/register_pages/caregiver_pages/create_my_profile_name_page_caregiver.dart';
import 'package:pill_buddy/pages/register_pages/caregiver_pages/create_my_profile_page_caregiver.dart';
import 'package:pill_buddy/pages/register_pages/caregiver_pages/main_page_caregiver.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_my_profile_name_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_my_profile_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_birthdate_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_confirm_email.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_confirm_email.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_profile_hope_to_achieve_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/set_address_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/user_input_confirmation_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/user_input_confirmation_page.dart';
import 'package:pill_buddy/pages/register_pages/register_page.dart';
import 'package:pill_buddy/test_notification_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_loc;
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/login_register_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
var logger = Logger();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();

  // Notification setup
  tz.initializeTimeZones();
  tz_loc.setLocalLocation(tz_loc.getLocation('Asia/Manila'));

  const androidInit = AndroidInitializationSettings('ic_notification');
  const iosInit = DarwinInitializationSettings();
  const settings = InitializationSettings(android: androidInit, iOS: iosInit);

  await notificationsPlugin.initialize(settings,
      onDidReceiveNotificationResponse: (response) {
    // handle notification tap
  });

  // Request notifications on Android 13+
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  // Create notification channel
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
  Future<bool> isExactAlarmPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('exact_alarm_granted') ?? false;
  }

  final prefs = await SharedPreferences.getInstance();
  bool alreadyPrompted = prefs.getBool('exactAlarmPrompted') ?? false;

  if (Platform.isAndroid && !alreadyPrompted) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    try {
      if (androidInfo.version.sdkInt >= 31) {
        final alarmManagerPermissionGranted =
            await isExactAlarmPermissionGranted();
        if (!alarmManagerPermissionGranted) {
          const intent = AndroidIntent(
            action: 'android.settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM',
          );
          await intent.launch();
          await prefs.setBool('exactAlarmPrompted', true);
        }
      }
    } catch (e) {
      logger.e("Error requesting exact alarm permission: $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => TestMedicationProvider()),
        ChangeNotifierProvider(create: (_) => DoorStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isCaregiver = context.watch<MedicationProvider>().isCaregiver;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pill Buddy',
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: isCaregiver
            ? ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 0, 132, 255),
                primary: const Color.fromARGB(255, 0, 132, 255), // #0084ff
              )
            : ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 24, 172, 24),
                primary: const Color.fromARGB(255, 24, 172, 24), //#18ac18
              ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            prefixIconColor: Color.fromRGBO(119, 119, 119, 1)),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        useMaterial3: true,
      ),
      home: const ScheduleTestPage(),
    );
  }
}

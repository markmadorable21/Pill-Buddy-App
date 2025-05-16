import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pill_buddy/firebase_options.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/test2_country_plus_ph.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/test_add_new_caregiver_page.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/test_country_state_picker.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_med_form_amt_qty_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/once_a_day_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/reusable_date_inputter_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/reusable_time_inputter_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/specific_day_pages/set_amount_date_time_page.dart';
import 'package:pill_buddy/pages/login_pages/login_page.dart';
import 'package:pill_buddy/pages/main_pages/add_medication_page.dart';
import 'package:pill_buddy/pages/main_pages/home_page.dart';
import 'package:pill_buddy/pages/main_pages/main_page.dart';
import 'package:pill_buddy/pages/main_pages/test_home_page.dart';
import 'package:pill_buddy/pages/providers/address_provider.dart';
import 'package:pill_buddy/pages/providers/testmedprovider.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_loc;
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/login_register_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // time zones (only if you plan to schedule)
  tz.initializeTimeZones();
  tz_loc.setLocalLocation(tz_loc.getLocation('Asia/Manila'));

  //  Android init (must match res/drawable/ic_notification.png)
  const androidInit = AndroidInitializationSettings('ic_notification');
  const iosInit = DarwinInitializationSettings();
  const settings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  //  Initialize the plugin
  await notificationsPlugin.initialize(settings,
      onDidReceiveNotificationResponse: (response) {
    // handle taps here
  });

// Only on Android 13+
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  // Create your notification channel (once)
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => TestMedicationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pill Buddy',
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(
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
      home: MainPage(),
    );
  }
}

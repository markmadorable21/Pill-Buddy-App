import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/add_medication_pages/reminders_page.dart';
import 'package:pill_buddy/pages/main_pages/caregiver_notifications_page.dart';
import 'package:pill_buddy/pages/main_pages/edit_profile_page.dart';
import 'package:pill_buddy/pages/main_pages/home_page.dart';
import 'package:pill_buddy/pages/main_pages/test_home_page.dart';
import 'package:pill_buddy/pages/main_pages/trackers_page.dart';
import 'package:pill_buddy/pages/main_pages/medication_page.dart';
import 'package:pill_buddy/pages/main_pages/manage_page.dart';
import 'package:pill_buddy/pages/main_pages/user_avatar_widget.dart';
import 'package:pill_buddy/pages/main_pages/username_widget.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/providers/notification_badge_provider.dart';
import 'package:pill_buddy/pages/register_pages/caregiver_pages/test_home_page_caregiver.dart';
import 'package:provider/provider.dart';

class MainPageCaregiver extends StatefulWidget {
  const MainPageCaregiver({super.key});

  @override
  State<MainPageCaregiver> createState() => _MainPageCaregiverState();
}

class _MainPageCaregiverState extends State<MainPageCaregiver> {
  @override
  void initState() {
    super.initState();
  }

  int currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = const [
    TestHomePageCaregiver(),
    TrackersPage(),
    NotificationsPageCaregiver(),
    // ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            // Leftmost: User Profile and Name
            Expanded(
              child: Row(
                children: [
                  UserAvatarWidget(radius: 22),
                  SizedBox(width: 10),
                  UserNameWidget(
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.update), label: 'Trackers'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: -4,
                  child: Consumer<NotificationBadge>(
                    builder: (_, badge, __) => badge.count > 0
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${badge.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                )
              ],
            ),
            label: 'Notifications', // This is OK here
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

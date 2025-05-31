import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/add_medication_pages/reminders_page.dart';
import 'package:pill_buddy/pages/main_pages/edit_profile_page.dart';
import 'package:pill_buddy/pages/main_pages/home_page.dart';
import 'package:pill_buddy/pages/main_pages/patient_notification_page.dart';
import 'package:pill_buddy/pages/main_pages/test_home_page.dart';
import 'package:pill_buddy/pages/main_pages/trackers_page.dart';
import 'package:pill_buddy/pages/main_pages/medication_page.dart';
import 'package:pill_buddy/pages/main_pages/manage_page.dart';
import 'package:pill_buddy/pages/main_pages/user_avatar_widget.dart';
import 'package:pill_buddy/pages/main_pages/username_widget.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/providers/notification_badge_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  int currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = const [
    TestHomePage(),
    TrackersPage(),
    NotificationsPagePatient(),
    RemindersPage(),
    ManagePage(),
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
              icon: Icon(Icons.medication), label: 'Refill'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Manage'),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Row (Photo, Name, Edit Profile)
                Row(
                  children: [
                    // User Photo with Primary Color Outline
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Primary color border
                          width: 3, // Border thickness
                        ),
                      ),
                      child: const UserAvatarWidget(radius: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const UserNameWidget(
                            textColor: Colors.black,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                // Add edit profile action
                              },
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const EditProfilePage()),
                                  );
                                },
                                child: const Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue, // or your theme color
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // Profile Section
                const Text("Profile",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text("Add Dependent"),
                  onTap: () {
                    // Add dependent action
                  },
                ),

                const SizedBox(height: 10),

                // Invite PillBuddy Section
                const Text("Invite PillBuddy",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: const Text("Invite PillBuddy"),
                  onTap: () {
                    // Invite action
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.verified),
                  title: const Text("Verification Code"),
                  onTap: () {
                    // Verification code action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

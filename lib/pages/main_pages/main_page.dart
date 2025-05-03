import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/main_pages/home_page.dart';
import 'package:pill_buddy/pages/main_pages/trackers_page.dart';
import 'package:pill_buddy/pages/main_pages/medication_page.dart';
import 'package:pill_buddy/pages/main_pages/manage_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
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
    HomePage(),
    TrackersPage(),
    MedicationPage(),
    ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarUrl = context.watch<MedicationProvider>().avatarUrl;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Leftmost: User Profile and Name
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : const AssetImage("assets/images/user_photo1.png")
                            as ImageProvider,
                    radius: 22, // Adjust profile picture size
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Mark Madorable",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Trackers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication), label: 'Medication'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Manage'),
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
                      child: CircleAvatar(
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : const AssetImage("assets/images/user_photo1.png")
                                as ImageProvider,
                        radius: 30, // Profile picture size
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "  Mark Madorable",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                // Add edit profile action
                              },
                              child: const Text(
                                "Edit Profile",
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 14),
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

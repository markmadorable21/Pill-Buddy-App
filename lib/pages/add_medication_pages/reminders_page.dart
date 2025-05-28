import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  DatabaseReference? door1Ref;
  DatabaseReference? door2Ref;
  final _logger = Logger();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in appropriately here
      throw Exception('User not logged in');
    }

    final deviceId =
        Provider.of<MedicationProvider>(context, listen: false).deviceId;

    if (deviceId.isEmpty) {
      _logger.e("Device ID is not set. Cannot load medication.");
      throw Exception('Device ID not set');
    }

    // Initialize refs once
    if (door1Ref == null || door2Ref == null) {
      door1Ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref().child(deviceId).child('Door1');

      door2Ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref().child(deviceId).child('Door2');
    }
  }

  Future<void> _launchInfo(String medName) async {
    final url = Uri.parse(
        'https://www.drugs.com/search.php?searchterm=${Uri.encodeComponent(medName)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _updateClickedAndSubtract(DatabaseReference ref) async {
    final snapshot = await ref.get();
    if (snapshot.value == null) return; // safety check
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final int current = int.tryParse(data['totalQty']?.toString() ?? '0') ?? 0;

    final int userQty = int.tryParse(data['quantity'].toString()) ?? 0;

    final int newTotal = (current - userQty).clamp(0, current);

    await ref.update({
      'clicked': true,
      'totalQty': newTotal,
    });
  }

  Future<void> _refillQty(DatabaseReference ref) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Refill amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter qty to add'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(_, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok == true && int.tryParse(controller.text) != null) {
      final add = int.parse(controller.text);
      final snap = await ref.get();
      final data = Map<String, dynamic>.from(snap.value as Map? ?? {});
      final current = int.tryParse(data['totalQty']?.toString() ?? '0') ?? 0;
      await ref.update({'totalQty': current + add});
    }
  }

  Widget _buildDoorCard(
      String title, int totalQty, String medName, DatabaseReference ref) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medName.isNotEmpty ? medName : title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total on hand: $totalQty'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _launchInfo(medName),
                  child: const Text('Info'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _refillQty(ref),
                  child: const Text('Refill'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateClickedAndSubtract(ref),
                  child: const Text('Take Dose'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If refs are not yet initialized, show loading
    if (door1Ref == null || door2Ref == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          // Door 1 StreamBuilder listens for Door1 changes
          StreamBuilder<DatabaseEvent>(
            stream: door1Ref!.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const ListTile(
                  title: Text('Loading Door 1...'),
                );
              }
              final data = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              final qty =
                  int.tryParse(data['totalQty']?.toString() ?? '0') ?? 0;
              final medName = data['med']?.toString() ?? 'No medication';

              return _buildDoorCard('Door 1', qty, medName, door1Ref!);
            },
          ),

          // Door 2 StreamBuilder listens for Door2 changes
          StreamBuilder<DatabaseEvent>(
            stream: door2Ref!.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const ListTile(
                  title: Text('Loading Door 2...'),
                );
              }
              final data = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              final qty =
                  int.tryParse(data['totalQty']?.toString() ?? '0') ?? 0;
              final medName = data['med']?.toString() ?? 'No medication';

              return _buildDoorCard('Door 2', qty, medName, door2Ref!);
            },
          ),
        ],
      ),
    );
  }
}

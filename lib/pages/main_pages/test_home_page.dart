import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pill_buddy/pages/main_pages/input_device_id_page.dart';
import 'package:provider/provider.dart';

import 'package:pill_buddy/pages/providers/medication_provider.dart';

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  late Future<List<Map<String, dynamic>>>? _timeCardsFuture;
  String? _deviceId;

  DateTime _currentDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  var _logger = Logger();

  @override
  void initState() {
    super.initState();
    // Get deviceId from provider after the first frame (since context not fully ready in initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deviceId =
          Provider.of<MedicationProvider>(context, listen: false).deviceId;
      if (_deviceId != null && _deviceId!.isNotEmpty) {
        setState(() {
          _timeCardsFuture = fetchMedicationsFromRealtimeDB(_deviceId!);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deviceId == null) {
      _deviceId =
          Provider.of<MedicationProvider>(context, listen: false).deviceId;
      if (_deviceId != null && _deviceId!.isNotEmpty) {
        setState(() {
          _timeCardsFuture = fetchMedicationsFromRealtimeDB(_deviceId!);
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchMedicationsFromRealtimeDB(
      String deviceId) async {
    final deviceId =
        Provider.of<MedicationProvider>(context, listen: false).deviceId;

    if (deviceId.isEmpty) {
      _logger.e("Device ID is not set. Cannot fetch medication.");
      return [];
    }

    final dbRoot = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref().child(deviceId);

    List<Map<String, dynamic>> timeCards = [];

    try {
      final snapshot = await dbRoot.get();
      if (!snapshot.exists) {
        _logger.w("No data found for device ID: $deviceId");
        return [];
      }

      for (final doorKey in ['Door1', 'Door2']) {
        final doorData = snapshot.child(doorKey);
        if (doorData.exists) {
          final data = Map<String, dynamic>.from(doorData.value as Map);

          for (int i = 1; i <= 4; i++) {
            final timeKey = 'time$i';
            final timeValue = data[timeKey];
            if (timeValue != null && timeValue.toString().isNotEmpty) {
              // Format time with AM/PM
              final timeStr = formatDecimalTimeWithAmPm(timeValue.toString());

              timeCards.add({
                'door': doorKey,
                'timeKey': timeKey,
                'timeRaw': timeValue.toString(), // for sorting
                'time': timeStr,
                'med': data['med'] ?? 'Unknown',
                'form': data['form'] ?? '',
                'purpose': data['purpose'] ?? '',
                'quantity': data['quantity'] ?? '',
                'amount': data['amount'] ?? '',
              });
            }
          }
        }
      }

      // Sort cards by timeRaw ascending
      timeCards.sort((a, b) {
        final t1 = decimalTimeToMinutes(a['timeRaw']);
        final t2 = decimalTimeToMinutes(b['timeRaw']);
        return t1.compareTo(t2);
      });
    } catch (e, st) {
      _logger.e('⛔ Error reading from Realtime DB', error: e, stackTrace: st);
    }

    return timeCards;
  }

  /// Converts decimal time (e.g., 23.50) to total minutes since midnight.
  /// The input can be String or double.
  /// Example: 23.50 -> 23*60 + 50 = 1430 minutes.
  int decimalTimeToMinutes(dynamic decimalTime) {
    double time;
    if (decimalTime is String) {
      time = double.tryParse(decimalTime) ?? 0.0;
    } else if (decimalTime is double) {
      time = decimalTime;
    } else {
      return 0;
    }

    int hour = time.floor();
    int minutes = ((time - hour) * 100).round();

    // Clamp minutes to max 59 to avoid invalid time
    if (minutes >= 60) minutes = 59;

    return hour * 60 + minutes;
  }

  /// Formats decimal time (e.g., 23.50) into a 12-hour time string with AM/PM.
  /// Example: 23.50 -> "11:50 PM"
  String formatDecimalTimeWithAmPm(dynamic decimalTime) {
    int totalMinutes = decimalTimeToMinutes(decimalTime);
    int hour24 = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    // Create a DateTime today with the parsed hour and minute
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hour24, minutes);

    final format12 = DateFormat('hh:mm a');
    return format12.format(dt);
  }

  Future<void> updateMedicationField(
      String deviceId, String door, String field, dynamic newValue) async {
    final dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref().child(deviceId).child(door).child(field);
    await dbRef.set(newValue);
    _logger.i("✅ Updated $field in $door");
  }

  Future<void> deleteMedication(String deviceId, String door) async {
    final dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref().child(deviceId).child(door);
    await dbRef.remove();
    _logger.w("🗑️ Deleted medication in $door");
  }

  Future<void> _showUpdateDialog(BuildContext context, String deviceId,
      String door, String field, String currentValue) async {
    final controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New Value'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await updateMedicationField(
                  deviceId, door, field, controller.text);
              Navigator.pop(context);
              setState(() {
                _timeCardsFuture = fetchMedicationsFromRealtimeDB(_deviceId!);
              });
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetailDialog(
      BuildContext context, String deviceId, Map<String, dynamic> card) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Medication Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Time:", card['time']),
            _detailRow("Medication:", card['med']),
            _detailRow("Quantity:", card['quantity'].toString()),
            _detailRow("Amount:", card['amount'].toString()),
            _detailRow("Form:", card['form']),
            _detailRow("Purpose:", card['purpose']),
            _detailRow("Door:", card['door']),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
              _showEditMedicationDialog(context, deviceId, card);
            },
            tooltip: "Edit",
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDeleteDialog(context);
              if (confirmed == true) {
                await deleteMedication(deviceId, card['door']);
                setState(() {
                  _timeCardsFuture = fetchMedicationsFromRealtimeDB(_deviceId!);
                });
              }
            },
            tooltip: "Delete",
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this medication?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _showEditMedicationDialog(
      BuildContext context, String deviceId, Map<String, dynamic> card) async {
    final medController = TextEditingController(text: card['med']);
    final quantityController =
        TextEditingController(text: card['quantity'].toString());
    final amountController =
        TextEditingController(text: card['amount'].toString());
    final formController = TextEditingController(text: card['form']);
    final purposeController = TextEditingController(text: card['purpose']);
    final timeController =
        TextEditingController(text: card['timeRaw']); // editable in 24h format

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Medication"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: medController,
                decoration: const InputDecoration(labelText: "Medication"),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              TextField(
                controller: formController,
                decoration: const InputDecoration(labelText: "Form"),
              ),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(labelText: "Purpose"),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                    labelText: "Time (24-hour format HH:mm)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              // Update all fields in Realtime DB under door node
              final door = card['door'];
              await updateMedicationField(
                  deviceId, door, 'med', medController.text);
              await updateMedicationField(
                  deviceId, door, 'quantity', quantityController.text);
              await updateMedicationField(
                  deviceId, door, 'amount', amountController.text);
              await updateMedicationField(
                  deviceId, door, 'form', formController.text);
              await updateMedicationField(
                  deviceId, door, 'purpose', purposeController.text);
              await updateMedicationField(
                  deviceId, door, card['timeKey'], timeController.text);

              Navigator.pop(context);

              setState(() {
                _timeCardsFuture = fetchMedicationsFromRealtimeDB(_deviceId!);
              });
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _goToToday() {
    setState(() => _currentDate = DateTime.now());
    final indexOfToday = DateTime.now().difference(DateTime.now()).inDays + 577;
    _scrollController.animateTo(
      indexOfToday * 50.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Calendar strip (horizontal scroll)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              itemCount: 1000,
              itemBuilder: (ctx, idx) {
                final day = DateTime.now().add(Duration(days: idx - 500));
                final isSelected = day.year == _currentDate.year &&
                    day.month == _currentDate.month &&
                    day.day == _currentDate.day;
                return GestureDetector(
                  onTap: () => setState(() => _currentDate = day),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(DateFormat('E').format(day),
                            style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black)),
                        Text('${day.day}',
                            style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: _goToToday,
                child: const Text("Today >>", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 190),
              Text(
                DateFormat('MMM d, yyyy').format(_currentDate),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _timeCardsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final timeCards = snapshot.data ?? [];

              if (timeCards.isEmpty) {
                return const Center(child: Text("No medications found."));
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height - 370,
                child: ListView.builder(
                  itemCount: timeCards.length,
                  itemBuilder: (context, index) {
                    final card = timeCards[index];

                    return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
//                       child: ListTile(
//   title: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         "${card['time']}",
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//         ),
//       ),
//       const SizedBox(height: 6),
//       Row(
//         children: [
//           Container(
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//               color: Colors.blue, // or any color you want
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: const Icon(
//               Icons.medical_services, // choose an icon you prefer
//               size: 16,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Container(
//               height: 1,
//               color: Colors.grey[400], // horizontal line color
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             card['med'],
//             style: const TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     ],
//   ),
//   subtitle: Text("Take ${card['quantity']} ${card['form']}"),
//   onTap: () {
//     _showDetailDialog(
//       context,
//       Provider.of<MedicationProvider>(context, listen: false).deviceId,
//       card,
//     );
//   },
// ),

                        child: ListTile(
                          title: Text(
                            "${card['time']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(LucideIcons.pill,
                                    size: 30, color: primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        card['med'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                          'Take ${card['quantity']} ${card['form']}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            _showDetailDialog(
                              context,
                              Provider.of<MedicationProvider>(context,
                                      listen: false)
                                  .deviceId,
                              card,
                            );
                          },
                        ));
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputDeviceIdPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Add Medication",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

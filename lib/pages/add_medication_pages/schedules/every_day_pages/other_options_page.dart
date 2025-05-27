import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/add_instructions_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/change_the_med_icon_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/add_refill_reminder_page.dart';
import 'package:pill_buddy/pages/main_pages/main_page.dart';
import 'package:pill_buddy/pages/providers/door_status_provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

/// Page for additional medication options before final save.
class OtherOptionsPage extends StatefulWidget {
  const OtherOptionsPage({super.key});

  @override
  State<OtherOptionsPage> createState() => _OtherOptionsPageState();
}

class _OtherOptionsPageState extends State<OtherOptionsPage> {
  bool isPage1Done = false;
  bool isPage2Done = false;
  bool isPage3Done = false;
  bool isPage4Done = false;

  final _logger = Logger();
  bool _isLoading = false;

  Future<void> uploadMedicationToFirestore(
      BuildContext context, MedicationEntry med, int doorIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    final doorKey = doorIndex == 0 ? 'Door1' : 'Door2';

    // Reference medications collection, doc = user UID
    final docRef =
        FirebaseFirestore.instance.collection('medications').doc(user.uid);

    // Prepare times as 24h decimal strings (e.g. 13.55)
    final timesList = med.selectedTimes ?? [];
    String fmt(int idx) {
      if (idx >= timesList.length) {
        return ''; // Return empty string if timesList is smaller than idx
      }
      final t = timesList[idx];
      final hour = t.hour;
      final minute = t.minute;
      final asDecimal = hour + (minute / 60);
      return asDecimal.toStringAsFixed(2);
    }

    // Creating the data to upload with null checks
    final data = {
      doorKey: {
        'added': true,
        'med': med.med ?? 'Unknown Medication', // Use default if null
        'form': med.form ?? 'Unknown Form', // Use default if null
        'purpose': med.purpose ?? 'No Purpose', // Use default if null
        'frequency': med.frequency ?? 0, // Default to 0 if null

        'time': med.time ?? 'No Time Set', // Default if null
        'amount': med.amount ?? 0, // Default to 0 if null
        'quantity': med.quantity ?? 0, // Default to 0 if null
        'date': (med.date is DateTime)
            ? (med.date as DateTime).toIso8601String()
            : 'No Date', // Check type and then call toIso8601String()
        'expiration': (med.expiration is DateTime)
            ? (med.expiration as DateTime).toIso8601String()
            : 'No Expiration', // Same for expiration

        'timesperday': _convertTimesPerDayToInt(
            Provider.of<MedicationProvider>(context, listen: false)
                .selectedTimesPerDay),
        'intake': _convertTimesPerDayToInt(
            Provider.of<MedicationProvider>(context, listen: false)
                .selectedTimesPerDay),
        'time1': fmt(0),
        'time2': fmt(1),
        'time3': fmt(2),
        'time4': fmt(3),
        'clicked': false,
      }
    };

    try {
      // Merge updates with existing doc so other door’s data is preserved
      await docRef.set(data, SetOptions(merge: true));
      _logger.i('Medication uploaded to Firestore: $data');
    } catch (e, st) {
      _logger.e('Failed to upload medication to Firestore',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  int _convertTimesPerDayToInt(String? label) {
    switch (label?.toLowerCase()) {
      case 'once a day':
        return 1;
      case 'twice a day':
        return 2;
      case '3 times a day':
        return 3;
      case 'more than 3 times a day':
        return 4;
      default:
        return 1; // Default/fallback to 1 if not recognized
    }
  }

  // String? _formatTimeOfDay(TimeOfDay? time) {
  //   if (time == null) return null;
  //   return time.format(context);
  // }

  Future<void> uploadMedicationToDoor(
      BuildContext context, MedicationEntry med, int doorIndex) async {
    // Get device ID from provider
    final deviceId =
        Provider.of<MedicationProvider>(context, listen: false).deviceId;
    if (deviceId.isEmpty) {
      _logger.e("Device ID is not set. Cannot upload medication.");
      throw Exception('Device ID not set');
    }

    final doorKey = doorIndex == 0 ? 'Door1' : 'Door2';

    final dbRoot = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref().child(deviceId);

    try {
      final timesPerDay = _convertTimesPerDayToInt(
          Provider.of<MedicationProvider>(context, listen: false)
              .selectedTimesPerDay);
      final timesList = med.selectedTimes ?? [];

      String? fmt(int idx) {
        if (idx >= timesList.length) return '';
        final t = timesList[idx];
        // Convert to decimal: e.g. 1:33 PM → 13.55
        final hour = t.hour;
        final minute = t.minute;
        final asDecimal = hour + (minute / 60);
        // Round to 2 decimals as a string for DB upload
        return asDecimal.toStringAsFixed(2);
      }

      final doorPayload = {
        'added': true,
        'timesperday': timesPerDay,
        'intake': timesPerDay,
        'totalQty':
            Provider.of<MedicationProvider>(context, listen: false).totalQty,
        'time1': fmt(0),
        'time2': fmt(1),
        'time3': fmt(2),
        'time4': fmt(3),
        'clicked': false,
      };

      // Set medication door data
      await dbRoot.child(doorKey).set(doorPayload);

      // Set temp and hrate with number value (can be dynamic, here static sample values)
      await dbRoot.child('temp').set(36.5); // Example temperature
      await dbRoot.child('hrate').set(77); // Example heart rate

      _logger.i('✅ Uploaded to $deviceId/$doorKey (med), temp, hrate');
    } catch (e, st) {
      _logger.e('⛔ Failed to upload medication or vital signs',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> saveMedicationData() async {
    final provider = context.read<MedicationProvider>();

    if (provider.medList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No medications to save')),
      );
      return;
    }

    final doorIndex = provider.selectedDoorIndex ?? 0;
    final latestMed = provider.medList.last;

    try {
      // Upload to Firebase Realtime Database (existing method)
      await uploadMedicationToDoor(context, latestMed, doorIndex);

      try {
        // Upload to Firestore (new method with instanceFor)
        await uploadMedicationToFirestore(context, latestMed, doorIndex);
      } catch (e) {
        logger.e('Error: $e');
      }

      // Ensure widget is still mounted before calling context-dependent methods
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication saved successfully!')),
      );

      // Ensure widget is still mounted before navigation
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } catch (e) {
      // Ensure widget is still mounted before calling context-dependent methods
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving medication: $e')),
      );
    }
  }

  void _showConfirmationDialog(MedicationProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Medication Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConditionalConfirmationItem('Name', provider.selectedMed),
            _buildConditionalConfirmationItem('Form', provider.selectedForm),
            _buildConditionalConfirmationItem(
                'Purpose', provider.selectedPurpose),
            _buildConditionalConfirmationItem(
                'Frequency', provider.selectedFrequency),
            if (provider.selectedDate != null)
              _buildConditionalConfirmationItem(
                'Start Date',
                DateFormat('MMM d, yyyy').format(provider.selectedDate!),
              ),

            _buildConditionalConfirmationItem('Time', provider.selectedTime),
            _buildConditionalConfirmationItem(
                'Amount', provider.selectedAmount),
            _buildConditionalConfirmationItem(
                'Quantity', provider.selectedQuantity),

            _buildConditionalConfirmationItem(
                'Total Quantity', provider.totalQty),
            _buildConditionalConfirmationItem(
                'Expiration', provider.selectedExpiration),
            _buildConditionalConfirmationItem(
                'Times per day', provider.selectedTimesPerDay),
            // For example, if you have multiple times per day stored as List<TimeOfDay>
            if (provider.selectedTimes.isNotEmpty)
              _buildConditionalConfirmationItem(
                'Times',
                provider.selectedTimes.map((t) => t.format(context)).join(', '),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final entry = MedicationEntry(
                med: provider.selectedMed,
                form: provider.selectedForm,
                purpose: provider.selectedPurpose,
                frequency: provider.selectedFrequency,
                date: provider.selectedFrequency == 'Every day' ||
                        provider.selectedFrequency == 'Once a day' ||
                        provider.selectedFrequency == 'Twice a day' ||
                        provider.selectedFrequency == '3 times a day' ||
                        provider.selectedFrequency == 'More than 3 times a day'
                    ? DateTime.now()
                    : provider.selectedDate,
                time: provider.selectedTime,
                amount: provider.selectedAmount,
                quantity: provider.selectedQuantity,
                expiration: provider.selectedExpiration,
                selectedTimes: provider.selectedTimes,
                doorIndex: provider.selectedDoorIndex!,
              );
              provider.addMedicationEntry(entry);
              final doorIndex = provider.selectedDoorIndex ?? 0;
              final latestMed = provider.medList.last;
              //saveMedicationData();
              // Upload to Firebase Realtime Database (existing method)
              try {
                await uploadMedicationToDoor(context, latestMed, doorIndex);
              } on Exception catch (e) {
                logger.e('Error uploading medication to door: $e');
              }

              try {
                // Upload to Firestore (new method with instanceFor)
                await uploadMedicationToFirestore(
                    context, latestMed, doorIndex);
              } catch (e) {
                logger.e('Error: $e');
              }
              _logger.e('Medications now in list: ${provider.medList.length}');

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medication saved successfully!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionalConfirmationItem(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Empty widget, no space
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _navigateAndMarkDone(int pageNumber) async {
    switch (pageNumber) {
      case 1:
        // await Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => const SetTreatmentDurationPage()),
        // );
        setState(() => isPage1Done = true);
        break;
      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRefillReminderPage()),
        );
        setState(() => isPage2Done = true);
        break;
      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInstructionsPage()),
        );
        setState(() => isPage3Done = true);
        break;
      case 4:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangeTheMedIconPage()),
        );
        setState(() => isPage4Done = true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Other Options', style: TextStyle(color: Colors.white)),
        toolbarHeight: 70,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FadeIn(
              duration: const Duration(milliseconds: 500),
              child:
                  Icon(Icons.medical_services, size: 80, color: primaryColor),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 500),
              child: const Text(
                'Almost done. Would you like to:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionTile(
              label: 'Set treatment duration?',
              isDone: isPage1Done,
              onTap: () => _navigateAndMarkDone(1),
            ),
            const SizedBox(height: 13),
            _buildActionTile(
              label: 'Add refill reminder',
              isDone: isPage2Done,
              onTap: () => _navigateAndMarkDone(2),
            ),
            const SizedBox(height: 13),
            _buildActionTile(
              label: 'Add instructions?',
              isDone: isPage3Done,
              onTap: () => _navigateAndMarkDone(3),
            ),
            const SizedBox(height: 13),
            _buildActionTile(
              label: 'Change the med icon?',
              isDone: isPage4Done,
              onTap: () => _navigateAndMarkDone(4),
            ),
            const Spacer(),
            SlideInUp(
              duration: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _showConfirmationDialog(
                      Provider.of<MedicationProvider>(context, listen: false),
                    );
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String label,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDone ? Colors.grey[300] : primaryColor.withAlpha(25),
          border: Border.all(color: isDone ? Colors.grey : primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 16, color: isDone ? Colors.grey : Colors.black),
            ),
            if (isDone) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/add_medication_pages/door_selection_page.dart';
import 'package:pill_buddy/pages/main_pages/heartrate_monitor_page.dart';
import 'package:pill_buddy/pages/main_pages/temperature_monitor_page.dart';
import 'package:pill_buddy/pages/providers/door_status_provider.dart';
import 'package:pill_buddy/pages/register_pages/caregiver_pages/main_page_caregiver.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/add_medication_pages/reusable_add_med_name_page.dart';

class InputDeviceIdPage extends StatefulWidget {
  const InputDeviceIdPage({super.key});

  @override
  State<InputDeviceIdPage> createState() => _InputDeviceIdPageState();
}

class _InputDeviceIdPageState extends State<InputDeviceIdPage> {
  final _controller = TextEditingController();
  final _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  Timer? _debounceTimer;
  bool _deviceIdValid = false;
  String _lastCheckedId = '';
  String _statusMessage = '';

  void _checkDeviceId(String deviceId) async {
    if (deviceId.isEmpty) {
      setState(() {
        _deviceIdValid = false;
        _statusMessage = '';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Checking device ID: $deviceId ...';
    });

    _lastCheckedId = deviceId;

    try {
      final snapshot = await _dbRef.get();

      if (_lastCheckedId != deviceId) return;

      final keys = snapshot.children.map((e) => e.key).toSet();

      final exists = keys.contains(deviceId);

      setState(() {
        _deviceIdValid = exists;
        _statusMessage =
            exists ? 'Device ID is valid.' : 'Device ID not found.';
      });
    } catch (e) {
      setState(() {
        _deviceIdValid = false;
        _statusMessage = 'Error checking device ID: $e';
      });
    }
  }

  void _onTextChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkDeviceId(val.trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    Color getStatusColor() {
      if (_statusMessage.startsWith('Device ID is valid')) {
        return Colors.green;
      } else if (_statusMessage.startsWith('Checking')) {
        return Colors.orange;
      } else if (_statusMessage.startsWith('Error') ||
          _statusMessage.isNotEmpty) {
        return Colors.red;
      }
      return Colors.transparent;
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Input Device ID',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Please enter your device hardware ID:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter device ID',
              ),
              onChanged: _onTextChanged,
            ),
            const SizedBox(height: 10),
            // Status container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: getStatusColor()),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deviceIdValid
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _deviceIdValid
                    ? () {
                        provider.setDeviceId(_controller.text.trim());
                        logger.e('Device ID set: ${_controller.text.trim()}');
                        bool isCaregiver = Provider.of<MedicationProvider>(
                                context,
                                listen: false)
                            .isCaregiver;

                        bool isTrackingBPM = provider.isTrackingBPM;
                        bool isTrackingTemp = provider.isTrackingTemp;
                        bool isTrackingWeight = provider.isTrackingWeight;
                        bool isTrackingHeight = provider.isTrackingHeight;

                        if (isCaregiver) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MainPageCaregiver()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoorSelectionPage()),
                          );
                        }
                        if (isTrackingBPM && !isCaregiver || isCaregiver) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HeartRateMonitorPage()),
                          );
                        }

                        if (isTrackingTemp && !isCaregiver || isCaregiver) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TemperatureMonitorPage()),
                          );
                        }

                        if (isTrackingWeight && !isCaregiver || isCaregiver) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (_) => const ReusableAddMedNamePage()),
                          // );
                        }

                        if (isTrackingHeight && !isCaregiver || isCaregiver) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (_) => const ReusableAddMedNamePage()),
                          // );
                        }
                      }
                    : null,
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: _deviceIdValid ? Colors.white : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

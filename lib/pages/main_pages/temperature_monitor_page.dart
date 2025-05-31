import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TemperatureMonitorPage extends StatefulWidget {
  const TemperatureMonitorPage({super.key});

  @override
  State<TemperatureMonitorPage> createState() => _TemperatureMonitorPageState();
}

class _TemperatureMonitorPageState extends State<TemperatureMonitorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late DatabaseReference deviceRef;
  late DatabaseReference tempRef;
  late DatabaseReference historyRef;
  double? _lastTemp;
  int _age = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fetch age from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            final data = doc.data();
            _age = (data?['age'] is num) ? data!['age'] as int : 0;
          });
        }
      });
    }

    // Setup RTDB refs
    final deviceId =
        Provider.of<MedicationProvider>(context, listen: false).deviceId;
    const databaseURL =
        'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app';
    deviceRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseURL,
    ).ref().child(deviceId);
    tempRef = deviceRef.child('temp');
    historyRef = deviceRef.child('temp_history');

    // Listen for temperature changes and record history
    tempRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is num) {
        final temp = value.toDouble();
        if (_lastTemp == null || (temp - _lastTemp!).abs() >= 0.1) {
          _lastTemp = temp;
          final timestamp =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
          historyRef.push().set({
            'timestamp': timestamp,
            'temp': temp,
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Determine label based on age-specific normal range
  String _tempLabel(double temp) {
    if (_age <= 2) {
      if (temp < 36.4) return 'Low';
      if (temp > 38.0) return 'High';
      return 'Normal';
    } else if (_age <= 10) {
      if (temp < 36.1) return 'Low';
      if (temp > 37.8) return 'High';
      return 'Normal';
    } else if (_age <= 65) {
      if (temp < 35.9) return 'Low';
      if (temp > 37.6) return 'High';
      return 'Normal';
    } else {
      if (temp < 35.8) return 'Low';
      if (temp > 37.5) return 'High';
      return 'Normal';
    }
  }

  Color _tempColor(double temp, BuildContext context) {
    final label = _tempLabel(temp);
    switch (label) {
      case 'Low':
        return Colors.blue;
      case 'High':
        return Colors.red;
      case 'Normal':
      default:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Temperature Monitor',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Current temperature display
          StreamBuilder<DatabaseEvent>(
            stream: tempRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('Error fetching temperature'),
                );
              }
              final value = snapshot.data?.snapshot.value;
              if (value == null || value is! num) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No temperature data'),
                );
              }
              final temp = value.toDouble();
              final label = _tempLabel(temp);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        LucideIcons.thermometer,
                        color: _tempColor(temp, context),
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${temp.toStringAsFixed(1)} °C',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _tempColor(temp, context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        color: _tempColor(temp, context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // History list
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: historyRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final raw = snapshot.data?.snapshot.value;
                if (raw == null || raw is! Map) {
                  return const Center(child: Text('No history found'));
                }
                final entries = (raw as Map).entries.toList()
                  ..sort((a, b) {
                    final ta = DateTime.tryParse(a.value['timestamp'] ?? '');
                    final tb = DateTime.tryParse(b.value['timestamp'] ?? '');
                    if (ta == null || tb == null) return 0;
                    return tb.compareTo(ta);
                  });
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries[index].value as Map;
                    final ts = item['timestamp'] as String? ?? '';
                    final temp = (item['temp'] as num).toDouble();
                    final label = _tempLabel(temp);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          LucideIcons.clock,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          DateFormat('MMM d, yyyy HH:mm:ss')
                              .format(DateTime.parse(ts)),
                        ),
                        subtitle: Text(
                          label,
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: Text(
                          '${temp.toStringAsFixed(1)} °C',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: label == 'High'
                                ? Colors.red
                                : label == 'Low'
                                    ? Colors.blue
                                    : Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

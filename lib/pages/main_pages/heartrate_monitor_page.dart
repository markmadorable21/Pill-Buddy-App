import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HeartRateMonitorPage extends StatefulWidget {
  const HeartRateMonitorPage({super.key});

  @override
  State<HeartRateMonitorPage> createState() => _HeartRateMonitorPageState();
}

class _HeartRateMonitorPageState extends State<HeartRateMonitorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late DatabaseReference deviceRef;
  late DatabaseReference hrateRef;
  late DatabaseReference historyRef;
  int? _lastBpm;

  int _age = 0;
  String _sex = 'male';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fetch age and sex from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _age = (data?['age'] is num) ? data!['age'] as int : 0;
            _sex = (data?['sex'] is String) ? data!['sex'] as String : 'male';
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
    hrateRef = deviceRef.child('hrate');
    historyRef = deviceRef.child('history');

    // Listen for heart rate changes and record history
    hrateRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is num) {
        final bpm = value.toInt();
        if (_lastBpm == null || bpm != _lastBpm) {
          _lastBpm = bpm;
          final timestamp =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
          historyRef.push().set({
            'timestamp': timestamp,
            'hrate': bpm,
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

  // Determine resting heart rate level by age/sex
  String _rhrLevel(int bpm) {
    final table = _sex.toLowerCase() == 'female' ? _womenTable : _menTable;
    for (var row in table) {
      if (_age >= row['minAge'] && _age <= row['maxAge']) {
        if (bpm >= row['min'] && bpm <= row['max']) return row['label'];
      }
    }
    return 'Unknown';
  }

  Color bpmColor(int bpm, BuildContext context) {
    final level = _rhrLevel(bpm);
    switch (level) {
      case 'Excellent':
        return Colors.blue;
      case 'Good':
      case 'Above Average':
        return Colors.green;
      case 'Average':
      case 'Below Average':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  // Partial tables; expand age brackets as needed
  static final List<Map<String, dynamic>> _menTable = [
    {'label': 'Excellent', 'minAge': 18, 'maxAge': 25, 'min': 56, 'max': 61},
    {'label': 'Good', 'minAge': 18, 'maxAge': 25, 'min': 62, 'max': 65},
    {
      'label': 'Above Average',
      'minAge': 18,
      'maxAge': 25,
      'min': 66,
      'max': 69
    },
    {'label': 'Average', 'minAge': 18, 'maxAge': 25, 'min': 70, 'max': 73},
    {
      'label': 'Below Average',
      'minAge': 18,
      'maxAge': 25,
      'min': 74,
      'max': 81
    },
    {'label': 'Bad', 'minAge': 18, 'maxAge': 25, 'min': 82, 'max': 200},
    // TODO: add other age ranges
  ];

  static final List<Map<String, dynamic>> _womenTable = [
    {'label': 'Excellent', 'minAge': 18, 'maxAge': 25, 'min': 61, 'max': 65},
    {'label': 'Good', 'minAge': 18, 'maxAge': 25, 'min': 66, 'max': 69},
    {
      'label': 'Above Average',
      'minAge': 18,
      'maxAge': 25,
      'min': 70,
      'max': 73
    },
    {'label': 'Average', 'minAge': 18, 'maxAge': 25, 'min': 74, 'max': 78},
    {
      'label': 'Below Average',
      'minAge': 18,
      'maxAge': 25,
      'min': 79,
      'max': 84
    },
    {'label': 'Bad', 'minAge': 18, 'maxAge': 25, 'min': 85, 'max': 200},
    // TODO: add other age ranges
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Heart Rate Monitor',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Current RHR display
          StreamBuilder<DatabaseEvent>(
            stream: hrateRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator());
              }
              final val = snapshot.data?.snapshot.value;
              if (val is! num) return const SizedBox();
              final bpm = val.toInt();
              final level = _rhrLevel(bpm);
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(LucideIcons.heart,
                          color: bpmColor(bpm, context), size: 100),
                    ),
                    const SizedBox(height: 16),
                    Text('$bpm BPM',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: bpmColor(bpm, context))),
                    const SizedBox(height: 8),
                    Text(level,
                        style: TextStyle(
                            fontSize: 20, color: bpmColor(bpm, context))),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // History
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
                stream: historyRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final raw = snapshot.data?.snapshot.value;
                  if (raw is! Map)
                    return const Center(child: Text('No history found'));
                  final entries = raw.entries.toList()
                    ..sort((a, b) {
                      final ta = DateTime.tryParse(a.value['timestamp'] ?? '');
                      final tb = DateTime.tryParse(b.value['timestamp'] ?? '');
                      return tb?.compareTo(ta ?? DateTime(0)) ?? 0;
                    });
                  return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final item = entries[index].value as Map;
                        final ts = item['timestamp'] as String? ?? '';
                        final hr = (item['hrate'] as num).toInt();
                        final level = _rhrLevel(hr);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(LucideIcons.clock,
                                color: Theme.of(context).primaryColor),
                            title: Text(DateFormat('MMM d, yyyy HH:mm:ss')
                                .format(DateTime.parse(ts))),
                            subtitle: Text(level),
                            trailing: Text('$hr BPM',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: bpmColor(hr, context))),
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}

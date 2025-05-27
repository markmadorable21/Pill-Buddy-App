import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DoorStatusProvider with ChangeNotifier {
  final Logger logger = Logger();

  final String databaseURL =
      'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app';

  // Device IDs to monitor
  static const deviceIds = ['PillBuddy1', 'PillBuddy2'];

  // Realtime DB refs
  late final DatabaseReference _pb1Door1Ref;
  late final DatabaseReference _pb1Door2Ref;
  late final DatabaseReference _pb2Door1Ref;
  late final DatabaseReference _pb2Door2Ref;

  // Subscriptions
  late final StreamSubscription<DatabaseEvent> _pb1Door1Sub;
  late final StreamSubscription<DatabaseEvent> _pb1Door2Sub;
  late final StreamSubscription<DatabaseEvent> _pb2Door1Sub;
  late final StreamSubscription<DatabaseEvent> _pb2Door2Sub;

  // States
  bool _pb1Door1Added = false;
  bool get pb1Door1Added => _pb1Door1Added;

  bool _pb1Door2Added = false;
  bool get pb1Door2Added => _pb1Door2Added;

  bool _pb2Door1Added = false;
  bool get pb2Door1Added => _pb2Door1Added;

  bool _pb2Door2Added = false;
  bool get pb2Door2Added => _pb2Door2Added;

  DoorStatusProvider() {
    _pb1Door1Ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseURL,
    ).ref('${deviceIds[0]}/Door1/added');

    _pb1Door2Ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseURL,
    ).ref('${deviceIds[0]}/Door2/added');

    _pb2Door1Ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseURL,
    ).ref('${deviceIds[1]}/Door1/added');

    _pb2Door2Ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseURL,
    ).ref('${deviceIds[1]}/Door2/added');

    _pb1Door1Sub = _pb1Door1Ref.onValue.listen((event) {
      final val = event.snapshot.value;
      _pb1Door1Added = val == true;
      logger.i('PillBuddy1 door1 added status updated: $_pb1Door1Added');
      notifyListeners();
    });

    _pb1Door2Sub = _pb1Door2Ref.onValue.listen((event) {
      final val = event.snapshot.value;
      _pb1Door2Added = val == true;
      logger.i('PillBuddy1 door2 added status updated: $_pb1Door2Added');
      notifyListeners();
    });

    _pb2Door1Sub = _pb2Door1Ref.onValue.listen((event) {
      final val = event.snapshot.value;
      _pb2Door1Added = val == true;
      logger.i('PillBuddy2 door1 added status updated: $_pb2Door1Added');
      notifyListeners();
    });

    _pb2Door2Sub = _pb2Door2Ref.onValue.listen((event) {
      final val = event.snapshot.value;
      _pb2Door2Added = val == true;
      logger.i('PillBuddy2 door2 added status updated: $_pb2Door2Added');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _pb1Door1Sub.cancel();
    _pb1Door2Sub.cancel();
    _pb2Door1Sub.cancel();
    _pb2Door2Sub.cancel();
    super.dispose();
  }
}

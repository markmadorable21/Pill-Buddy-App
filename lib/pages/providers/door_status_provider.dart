import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DoorStatusProvider with ChangeNotifier {
  var logger = Logger();

  // Use instanceFor to target specific app and database URL
  final DatabaseReference _door1AddedRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref('medications/door1/added');

  final DatabaseReference _door2AddedRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://pill-buddy-cpe-nnovators-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref('medications/door2/added');

  late final StreamSubscription<DatabaseEvent> _door1Sub;
  late final StreamSubscription<DatabaseEvent> _door2Sub;

  bool _door1Added = false;
  bool get door1Added => _door1Added;

  bool _door2Added = false;
  bool get door2Added => _door2Added;

  DoorStatusProvider() {
    _door1Sub = _door1AddedRef.onValue.listen((event) {
      final val = event.snapshot.value;
      _door1Added = val == true;
      logger.e('Door1 added status updated: $_door1Added');
      notifyListeners();
    });
    _door2Sub = _door2AddedRef.onValue.listen((event) {
      final val = event.snapshot.value;
      _door2Added = val == true;
      logger.e('Door2 added status updated: $_door2Added');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _door1Sub.cancel();
    _door2Sub.cancel();
    super.dispose();
  }
}

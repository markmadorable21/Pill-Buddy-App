import 'package:flutter/material.dart';

class NotificationBadge extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void update(int newCount) {
    _count = newCount;
    notifyListeners();
  }
}

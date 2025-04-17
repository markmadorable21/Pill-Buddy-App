import 'package:flutter/material.dart';

class PurposeProvider extends ChangeNotifier {
  String? _selectedPurpose;

  String? get selectedPurpose => _selectedPurpose;

  void setPurpose(String purpose) {
    _selectedPurpose = purpose;
    notifyListeners();
  }

  void clearPurpose() {
    _selectedPurpose = null;
    notifyListeners();
  }
}

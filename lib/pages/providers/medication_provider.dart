import 'package:flutter/material.dart';

class MedicationProvider with ChangeNotifier {
  String _selectedMed = '';

  String get selectedMed => _selectedMed;

  void selectMedication(String med) {
    _selectedMed = med;
    notifyListeners();
  }
}

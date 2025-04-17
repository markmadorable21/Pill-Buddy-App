import 'package:flutter/material.dart';

class MedicationProvider with ChangeNotifier {
  String _selectedMed = '';
  String _selectedForm = '';

  String get selectedMed => _selectedMed;
  String get selectedForm => _selectedForm;

  void selectMedication(String med) {
    _selectedMed = med;
    notifyListeners();
  }

  void selectForm(String form) {
    _selectedForm = form;
    notifyListeners();
  }

  String get unitForForm {
    switch (_selectedForm) {
      case 'Pill':
        return 'pill(s)';
      case 'Injection':
        return 'mL';
      case 'Solution (Liquid)':
        return 'mL';
      case 'Drops':
        return 'drop(s)';
      case 'Inhaler':
        return 'puff(s)';
      case 'Powder':
        return 'g';
      default:
        return '';
    }
  }
}

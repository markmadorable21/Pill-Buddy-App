import 'package:flutter/material.dart';

class MedicationProvider with ChangeNotifier {
  String _selectedMed = '';
  String _selectedForm = '';
  String _selectedPurpose = '';
  String _selectedFrequency = '';
  String _selectedTime = '';
  String _selectedAmount = '';
  String _selectedExpiration = '';

  // Getters
  String get selectedMed => _selectedMed;
  String get selectedForm => _selectedForm;
  String get selectedPurpose => _selectedPurpose;
  String get selectedFrequency => _selectedFrequency;
  String get selectedTime => _selectedTime;
  String get selectedAmount => _selectedAmount;
  String get selectedExpiration => _selectedExpiration;

  // Setters
  void selectMedication(String med) {
    _selectedMed = med;
    notifyListeners();
  }

  void selectForm(String form) {
    _selectedForm = form;
    notifyListeners();
  }

  void selectPurpose(String purpose) {
    _selectedPurpose = purpose;
    notifyListeners();
  }

  void selectFrequency(String frequency) {
    _selectedFrequency = frequency;
    notifyListeners();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void selectAmount(String amount) {
    _selectedAmount = amount;
    notifyListeners();
  }

  void selectExpiration(String expirationDate) {
    _selectedExpiration = expirationDate;
    notifyListeners();
  }

  String get unitForForm {
    switch (_selectedForm) {
      case 'Pill':
        return 'pill(s)';
      case 'Injection':
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

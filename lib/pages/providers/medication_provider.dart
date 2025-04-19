import 'package:flutter/material.dart';

class MedicationEntry {
  final String med;
  final String form;
  final String purpose;
  final String frequency;
  final String time;
  final String amount;
  final String expiration;

  MedicationEntry({
    required this.med,
    required this.form,
    required this.purpose,
    required this.frequency,
    required this.time,
    required this.amount,
    required this.expiration,
  });
}

class MedicationProvider with ChangeNotifier {
  // Temporary selected values
  String _selectedMed = '';
  String _selectedForm = '';
  String _selectedPurpose = '';
  String _selectedFrequency = '';
  String _selectedTime = '';
  String _selectedAmount = '';
  String _selectedExpiration = '';

  bool _addedMed = true;
  bool get addedMed => _addedMed;

  // Medication list
  List<MedicationEntry> _medList = [];

  // Getters
  String get selectedMed => _selectedMed;
  String get selectedForm => _selectedForm;
  String get selectedPurpose => _selectedPurpose;
  String get selectedFrequency => _selectedFrequency;
  String get selectedTime => _selectedTime;
  String get selectedAmount => _selectedAmount;
  String get selectedExpiration => _selectedExpiration;
  List<MedicationEntry> get medList => _medList;

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

  void addMedMarkSave(bool value) {
    _addedMed = value;
    notifyListeners();
  }

  void addMedicationEntry(MedicationEntry entry) {
    _medList.add(entry);
    _addedMed = true;
    notifyListeners();
  }

  void clearSelectedValues() {
    _selectedMed = '';
    _selectedForm = '';
    _selectedPurpose = '';
    _selectedFrequency = '';
    _selectedTime = '';
    _selectedAmount = '';
    _selectedExpiration = '';
    notifyListeners();
  }

  void removeMedicationEntry(MedicationEntry entry) {
    _medList.remove(entry);
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

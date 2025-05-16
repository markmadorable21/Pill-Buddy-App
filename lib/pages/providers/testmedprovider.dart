import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicationEntry {
  final String med;
  final String form;
  final String purpose;
  final String frequency;
  final DateTime date;
  final String time;
  final String amount;
  final String quantity;
  final String expiration;

  MedicationEntry({
    required this.med,
    required this.form,
    required this.purpose,
    required this.frequency,
    required this.date,
    required this.time,
    required this.amount,
    required this.quantity,
    required this.expiration,
  });
}

class TestMedicationProvider with ChangeNotifier {
  // List of medications for management
  List<MedicationEntry> _medList = [];
  DateTime? _selectedDate;

  // Getters
  List<MedicationEntry> get medList => _medList;
  DateTime? get selectedDate => _selectedDate;

  // Setter to update the selected date
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Add a new medication entry
  void addMedication(MedicationEntry entry) {
    _medList.add(entry);
    notifyListeners();
  }

  // Remove a medication entry by index
  void removeMedication(int index) {
    _medList.removeAt(index);
    notifyListeners();
  }

  // Format the date
  String get formattedSelectedDate {
    if (_selectedDate == null) return '';
    return DateFormat('MMM d, yyyy').format(_selectedDate!);
  }
}

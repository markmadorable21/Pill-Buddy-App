import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool _addedMed = false;
  bool get addedMed => _addedMed;

  //login
  String _inputtedEmail = '';
  String _inputtedPassword = '';

  //signup or regidter
  String _inputtedFirstName = '';
  String _inputtedLastName = '';
  String _completeName = "";
  String _selectedGender = '';
  DateTime? _birthDate;
  int _calculatedAge = 0;

  // Define a Set to hold selected options
  Set<String> _selectedOptions = {};

  // Medication list
  List<MedicationEntry> _medList = [];

  // Getters for user details
  String get inputtedEmail => _inputtedEmail;
  String get inputtedPassword => _inputtedPassword;
  String get inputtedFirstName => _inputtedFirstName;
  String get inputtedLastName => _inputtedLastName;
  String get completeName => _completeName;
  String get selectedGender => _selectedGender;
  DateTime? get birthDate => _birthDate;
  int get calculatedAge => _calculatedAge;

  // Getter for selectedOptions
  Set<String> get selectedOptions => _selectedOptions;

  // Getters for med details
  String get selectedMed => _selectedMed;
  String get selectedForm => _selectedForm;
  String get selectedPurpose => _selectedPurpose;
  String get selectedFrequency => _selectedFrequency;
  String get selectedTime => _selectedTime;
  String get selectedAmount => _selectedAmount;
  String get selectedExpiration => _selectedExpiration;
  List<MedicationEntry> get medList => _medList;

  // Setters
  void setBirthDate(DateTime date) {
    _birthDate = date;
    notifyListeners();
  }

  String get birthDateFormatted {
    if (_birthDate == null) return '';
    return DateFormat('MMM d, yyyy').format(_birthDate!);
  }

  // Setter to update selectedOptions
  void toggleOption(String option) {
    if (_selectedOptions.contains(option)) {
      _selectedOptions.remove(option);
    } else {
      _selectedOptions.add(option);
    }
    // Notify listeners to rebuild the widget when the data changes
    notifyListeners();
  }

  // Clear all selected options
  void clearOptions() {
    _selectedOptions.clear();
    notifyListeners();
  }

  // Setter to update selected gender
  void setSelectedGender(String gender) {
    _selectedGender = gender;
    notifyListeners(); // Notify listeners when the gender is updated
  }

  void setAge(int age) {
    _calculatedAge = age;
    notifyListeners();
  }

  void inputEmail(String email) {
    _inputtedEmail = email;
    notifyListeners();
  }

  void inputFirstName(String firstName) {
    _inputtedFirstName = firstName;
    notifyListeners();
  }

  void inputLastName(String lastName) {
    _inputtedLastName = lastName;
    notifyListeners();
  }

  void setCompleteName(String name) {
    _completeName = name;
    notifyListeners();
  }

  void inputPassword(String password) {
    _inputtedPassword = password;
    notifyListeners();
  }

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

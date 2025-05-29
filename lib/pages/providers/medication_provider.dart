import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';

var logger = Logger();

class MedicationEntry {
  final String? med;
  final String? form;
  final String? purpose;
  final String?
      frequency; // e.g. "Every day", "Specific days of the week", etc.
  final DateTime? date; // start or one-off date
  final String? time;
  final String? amount;
  final String? quantity;
  final String? expiration;

  // Optional extras for complex schedules
  final DateTime? specificDate;
  final List<int>? weekDays;
  final int? intervalDays;
  final int? cycleLength;
  final List<TimeOfDay>? selectedTimes;
  final int doorIndex;

  MedicationEntry({
    required this.med,
    required this.form,
    required this.purpose,
    required this.frequency,
    this.date,
    required this.time,
    required this.amount,
    required this.quantity,
    required this.expiration,
    this.specificDate,
    this.weekDays,
    this.intervalDays,
    this.cycleLength,
    this.selectedTimes,
    required this.doorIndex,
  });

  /// Returns true if this entry should appear on [target].
  bool isScheduledOn(DateTime target) {
    if (date == null) {
      // No date means always scheduled (e.g., Every day)
      if (frequency == 'Every day') return true;
      // else fallback or decide what fits your app logic
      return false;
    }
    final daysSinceStart = target.difference(date!).inDays;
    switch (frequency) {
      case 'Every day':
      case 'Once a day':
      case 'Twice a day':
      case '3 times a day':
      case 'More than 3 times a day':
        //"Twice a day",
        // "3 times a day",
        // "More than 3 times a day",
        return true;
      case 'Every other day':
        return daysSinceStart >= 0 && daysSinceStart % 2 == 0;
      case 'Specific day':
        return specificDate != null &&
            DateFormat('yyyy-MM-dd').format(specificDate!) ==
                DateFormat('yyyy-MM-dd').format(target);
      case 'Specific days of the week':
        return weekDays != null && weekDays!.contains(target.weekday);
      case 'Every X days':
        return intervalDays != null &&
            daysSinceStart >= 0 &&
            daysSinceStart % intervalDays! == 0;
      case 'On a recurring cycle':
        return cycleLength != null &&
            daysSinceStart >= 0 &&
            daysSinceStart % cycleLength! == 0;
      default:
        // fallback to one-off on [date]
        return DateFormat('yyyy-MM-dd').format(date!) ==
            DateFormat('yyyy-MM-dd').format(target);
    }
  }
}

class MedicationProvider with ChangeNotifier {
  MedicationEntry buildMedicationEntry() {
    return MedicationEntry(
      med: selectedMed,
      form: selectedForm,
      purpose: selectedPurpose,
      frequency: selectedFrequency,
      date: selectedDate,
      time: selectedTime,
      amount: selectedAmount,
      quantity: selectedQuantity,
      expiration: selectedExpiration,
      selectedTimes: selectedTimes, // if you added this for multiple times
      // include other optional fields as needed
      doorIndex: selectedDoorIndex!,
    );
  }

  // Temporary selected values
  List<TimeOfDay> _selectedTimes = [];
  List<TimeOfDay> get selectedTimes => _selectedTimes;
  String _selectedMed = '';
  String _selectedForm = '';
  String _selectedPurpose = '';
  String _selectedFrequency = '';
  DateTime? _selectedDate;
  String _selectedTime = '';
  String _selectedAmount = '';
  String _selectedQuantity = '';
  String _selectedExpiration = '';
  bool _addedMed = false;
  bool get addedMed => _addedMed;
  bool _addedPatient = false;
  bool get addedPatient => _addedPatient;

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
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;
  bool _isCaregiver = false;
  bool get isCaregiver => _isCaregiver;

  // Define a Set to hold selected options
  Set<String> _selectedOptions = {};

  // Medication list for everyday, once a day
  final List<MedicationEntry> _medList = [];

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

  DateTime? get selectedDate => _selectedDate;
  String get selectedTime => _selectedTime;
  String get selectedAmount => _selectedAmount;
  String get selectedQuantity => _selectedQuantity;
  String get selectedExpiration => _selectedExpiration;
  List<MedicationEntry> get medList => List.unmodifiable(_medList);
  // List of schedule options
  final List<String> _medFormOptions = [
    "Every day",
    "Every other day",
    "Specific day",
    "Specific days of the week",
    "On a recurring cycle",
    "Every X days",
  ];

  // Store the selected schedule (Default to the first option)
  String _selectedSchedule = "Every day";

  // Getter for medFormOptions
  List<String> get medFormOptions => _medFormOptions;

  // Getter for selected schedule
  String get selectedSchedule => _selectedSchedule;
  // Setter for selected schedule
  void selectSchedule(String schedule) {
    if (_medFormOptions.contains(schedule)) {
      _selectedSchedule = schedule;
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  String _deviceId = 'PillBuddy2';
  String get deviceId => _deviceId;

  void setDeviceId(String id) {
    _deviceId = id;
    notifyListeners();
  }

  // Setters
  void setBirthDate(DateTime date) {
    _birthDate = date;
    notifyListeners();
  }

  String get birthDateFormatted {
    if (_birthDate == null) return '';
    return DateFormat('MMM d, yyyy').format(_birthDate!);
  }

  String get formattedSelectedDate {
    if (_selectedDate == null) return '';
    return DateFormat('MMM d, yyyy').format(_birthDate!);
  }

  // Setter to update selected date
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
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

  void setAvatarUrl(String url) {
    _avatarUrl = url;
    notifyListeners();
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

  void selectQuantity(String qty) {
    _selectedQuantity = qty;
    notifyListeners();
  }

  void selectExpiration(String expirationDate) {
    _selectedExpiration = expirationDate;
    notifyListeners();
  }

  void setCaregiver(bool value) {
    _isCaregiver = value;
    notifyListeners();
  }

  void addMedMarkSave(bool value) {
    _addedMed = value;
    notifyListeners();
  }

  void addPatient(bool value) {
    _addedPatient = value;
    notifyListeners();
  }

  void addMedicationEntry(MedicationEntry entry) {
    _medList.add(entry);
    notifyListeners();
  }

  void clearAll() {
    _medList.clear();
    notifyListeners();
  }

  void removeMedicationEntry(MedicationEntry entry) {
    _medList.remove(entry);
    notifyListeners();
  }

  String get amountForForm {
    switch (_selectedForm) {
      case 'Pill':
        return 'g';
      case 'Injection':
      case 'Solution (Liquid)':
        return 'mL';
      case 'Drops':
        return 'mL';
      case 'Inhaler':
        return 'canister(s)';
      case 'Powder':
        return 'g';
      default:
        return '';
    }
  }

  String get quantityForForm {
    switch (_selectedForm) {
      case 'Pill':
        return 'pill(s)';
      case 'Injection':
      case 'Solution (Liquid)':
        return 'shot(s)';
      case 'Drops':
        return 'drop(s)';
      case 'Inhaler':
        return 'puff(s)';
      case 'Powder':
        return 'scoop(s)';
      default:
        return '';
    }
  }

  String? _totalQty;
  String? get totalQty => _totalQty;
  void selectTotalQty(String qty) {
    _totalQty = qty;
    notifyListeners();
  }

  // ★ New fields for advanced schedules:
  List<int> _selectedWeekDays = []; // 1=Mon…7=Sun
  int? _selectedIntervalDays; // for “Every X days”
  int? _selectedCycleLength; // for “On a recurring cycle”

  // ★ Getters:
  List<int> get selectedWeekDays => _selectedWeekDays;
  int? get selectedIntervalDays => _selectedIntervalDays;
  int? get selectedCycleLength => _selectedCycleLength;

  // ★ Setters:
  void selectWeekDays(List<int> days) {
    _selectedWeekDays = days;
    notifyListeners();
  }

  void selectIntervalDays(int days) {
    _selectedIntervalDays = days;
    notifyListeners();
  }

  void selectCycleLength(int length) {
    _selectedCycleLength = length;
    notifyListeners();
  }

  String? _selectedTimesPerDay;
  String? get selectedTimesPerDay => _selectedTimesPerDay;
  void setSelectedTimesPerDay(String? times) {
    _selectedTimesPerDay = times;
    notifyListeners();
  }

  void setSelectedTimes(List<TimeOfDay> times) {
    _selectedTimes = times;
    notifyListeners();
  }

  int? _selectedDoorIndex;
  int? get selectedDoorIndex => _selectedDoorIndex;

  void setSelectedDoorIndex(int index) {
    _selectedDoorIndex = index;
    notifyListeners();
  }
}

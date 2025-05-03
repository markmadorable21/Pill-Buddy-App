// at the top of your file
import 'package:flutter/services.dart';

// This formatter capitalizes the first letter of each word as you type
class NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.split(' ');
    final capitalized = words.map((word) {
      if (word.isEmpty) return '';
      final first = word[0].toUpperCase();
      final rest = word.length > 1 ? word.substring(1) : '';
      return '$first$rest';
    }).join(' ');
    // Keep the cursor at the end
    return TextEditingValue(
      text: capitalized,
      selection: TextSelection.collapsed(offset: capitalized.length),
    );
  }
}

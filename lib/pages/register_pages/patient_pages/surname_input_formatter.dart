import 'package:flutter/services.dart';

/// Title‐cases each word, but keeps "de", "dela", "delos", "de la", "de los"
/// lowercase when they appear at the start of the surname. Preserves any spaces.
class SurnameInputFormatter extends TextInputFormatter {
  static const _prefixes = [
    'van der',
    'van de',
    'de los',
    'de la',
    'delos',
    'dela',
    'della',
    'del',
    'di',
    'da',
    'du',
    'des',
    'von',
    'van',
    'le',
    'la',
    'de',
  ];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final lower = raw.toLowerCase();

    // First, build the "normal" title‐case of every word:
    final normal = lower.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');

    // Start with that as our default result:
    String result = normal;

    // Now check each special prefix (longest first):
    for (final prefix in _prefixes) {
      if (lower.startsWith('$prefix ')) {
        // Extract exactly what came after the prefix
        final afterPrefix = raw.substring(prefix.length + 1);
        // Title‐case each word in the suffix:
        final capSuffix = afterPrefix.split(' ').map((word) {
          if (word.isEmpty) return '';
          final w = word.toLowerCase();
          return w[0].toUpperCase() + w.substring(1);
        }).join(' ');
        // Rebuild with lowercase prefix + a space + capitalized suffix
        result = '$prefix $capSuffix';
        break;
      }
    }

    // Compute how the cursor should shift
    final diff = result.length - raw.length;
    final newOffset = (newValue.selection.end + diff).clamp(0, result.length);

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

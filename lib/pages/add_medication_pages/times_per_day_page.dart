// times_per_day_page.dart
import 'package:flutter/material.dart';

class TimesPerDayPage extends StatefulWidget {
  final String frequencyType; // pass the frequency selected in step 1

  const TimesPerDayPage({super.key, required this.frequencyType});

  @override
  _TimesPerDayPageState createState() => _TimesPerDayPageState();
}

class _TimesPerDayPageState extends State<TimesPerDayPage> {
  String? selectedOption;

  final List<String> timesOptions = [
    "Once a day",
    "Twice a day",
    "3 times a day",
    "More than 3 times a day",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select times per day')),
      body: ListView.builder(
        itemCount: timesOptions.length,
        itemBuilder: (context, index) {
          final option = timesOptions[index];
          return ListTile(
            title: Text(option),
            trailing: selectedOption == option
                ? Icon(Icons.check,
                    color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              setState(() {
                selectedOption = option;
              });
              // You can store the choice in provider or pass back
              Navigator.pop(context, option);
            },
          );
        },
      ),
    );
  }
}

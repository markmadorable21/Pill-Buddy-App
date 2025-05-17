// lib/pages/add_medication_pages/schedules/specific_days_page.dart
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/expiration_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/reusable_time_inputter_page.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';

class SpecificDaysPage extends StatefulWidget {
  const SpecificDaysPage({super.key});
  @override
  _SpecificDaysPageState createState() => _SpecificDaysPageState();
}

class _SpecificDaysPageState extends State<SpecificDaysPage> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Select Weekdays'), backgroundColor: primary),
      body: ListView(
        children: List.generate(7, (i) {
          final weekday = i + 1;
          final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
          final isOn = _selected.contains(weekday);
          return CheckboxListTile(
            title: Text(label),
            value: isOn,
            onChanged: (v) {
              setState(() {
                if (v == true)
                  _selected.add(weekday);
                else
                  _selected.remove(weekday);
              });
            },
          );
        }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _selected.isNotEmpty
              ? () {
                  context
                      .read<MedicationProvider>()
                      .selectWeekDays(_selected.toList());
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpirationPage(),
                    ),
                  );
                }
              : null,
          child: const Text('Done'),
        ),
      ),
    );
  }
}

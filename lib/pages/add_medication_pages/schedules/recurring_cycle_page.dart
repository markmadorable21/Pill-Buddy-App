// lib/pages/add_medication_pages/schedules/recurring_cycle_page.dart
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/every_day_pages/expiration_page.dart';
import 'package:pill_buddy/pages/add_medication_pages/schedules/reusable_time_inputter_page.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';

class RecurringCyclePage extends StatefulWidget {
  const RecurringCyclePage({super.key});
  @override
  _RecurringCyclePageState createState() => _RecurringCyclePageState();
}

class _RecurringCyclePageState extends State<RecurringCyclePage> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext c) {
    final primary = Theme.of(c).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Recurring Cycle'), backgroundColor: primary),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cycle length (days)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final v = int.tryParse(_controller.text);
                if (v != null && v > 0) {
                  context.read<MedicationProvider>().selectCycleLength(v);
                  Navigator.pop(context);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpirationPage(),
                  ),
                );
              },
              child: const Text('Done'),
            )
          ],
        ),
      ),
    );
  }
}

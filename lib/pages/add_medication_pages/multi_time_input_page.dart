import 'package:flutter/material.dart';

class MultiTimeInputPage extends StatefulWidget {
  final int numberOfTimes;

  const MultiTimeInputPage({super.key, required this.numberOfTimes});

  @override
  State<MultiTimeInputPage> createState() => _MultiTimeInputPageState();
}

class _MultiTimeInputPageState extends State<MultiTimeInputPage> {
  late List<TimeOfDay?> selectedTimes;

  @override
  void initState() {
    super.initState();
    // Initialize with null times
    selectedTimes = List<TimeOfDay?>.filled(widget.numberOfTimes, null);
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTimes[index] ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTimes[index] = picked;
      });
    }
  }

  bool get _allTimesSelected => selectedTimes.every((time) => time != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Select ${widget.numberOfTimes} Time${widget.numberOfTimes > 1 ? 's' : ''}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(widget.numberOfTimes, (index) {
              final time = selectedTimes[index];
              return ListTile(
                leading: Icon(Icons.access_time),
                title: Text(time?.format(context) ?? 'Select time'),
                onTap: () => _pickTime(index),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: _allTimesSelected
                  ? () {
                      // Return the list of selected times back
                      Navigator.pop(context, selectedTimes);
                    }
                  : null,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

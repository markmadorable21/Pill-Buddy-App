import 'package:flutter/material.dart';

class AddRefillReminderPage extends StatelessWidget {
  const AddRefillReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page 2")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Finish and Go Back"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

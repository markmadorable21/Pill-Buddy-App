import 'package:flutter/material.dart';

class SetTreatmentDurationPage extends StatelessWidget {
  const SetTreatmentDurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page 1")),
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

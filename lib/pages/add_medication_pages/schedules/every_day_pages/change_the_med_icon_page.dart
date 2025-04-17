import 'package:flutter/material.dart';

class ChangeTheMedIconPage extends StatelessWidget {
  const ChangeTheMedIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page 3")),
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

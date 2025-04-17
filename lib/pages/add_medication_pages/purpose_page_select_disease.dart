import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pill_buddy/database/diseases_data.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/providers/purpose_provider.dart';
import 'package:provider/provider.dart';

class PurposePageSelectDisease extends StatefulWidget {
  const PurposePageSelectDisease({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddMedPageState createState() => _AddMedPageState();
}

class _AddMedPageState extends State<PurposePageSelectDisease> {
  final TextEditingController _diseaseController = TextEditingController();
  bool _isPurposeSelected = false;

  @override
  Widget build(BuildContext context) {
    final selectedMed = Provider.of<MedicationProvider>(context).selectedMed;

    final selectedPurpose =
        Provider.of<PurposeProvider>(context).selectedPurpose;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          selectedMed,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What are you taking it for?",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 15),
            TextField(
              controller: _diseaseController,
              decoration: const InputDecoration(
                hintText: "Search for diseases",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (text) {
                setState(() {
                  _isPurposeSelected = text.isNotEmpty;
                });
              },
            ),
            const SizedBox(height: 15),
            // Medication suggestions below
            if (_diseaseController.text.isNotEmpty)
              SizedBox(
                height: 500,
                child: ListView(
                  children: diseaseSuggestions
                      .where((disease) => disease
                          .toLowerCase()
                          .contains(_diseaseController.text.toLowerCase()))
                      .map((disease) => ListTile(
                            title: Text(disease),
                            onTap: () {
                              Provider.of<PurposeProvider>(context,
                                      listen: false)
                                  .setPurpose(disease);
                              setState(() {
                                _diseaseController.text = disease;
                                _isPurposeSelected = true;
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 15),

            const Spacer(),
            // "Next" button which is disabled unless a med is selected
            SizedBox(
              width: double.infinity,
              height: 47,
              child: ElevatedButton(
                onPressed: _isPurposeSelected
                    ? () {
                        print(selectedPurpose);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const MedFormPage()),
                        // );
                        // Proceed to next page or action
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: _isPurposeSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

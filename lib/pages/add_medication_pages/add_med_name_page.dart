import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pill_buddy/pages/add_medication_pages/med_form_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import '../../database/medications_data.dart';

class AddMedNamePage extends StatefulWidget {
  const AddMedNamePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddMedPageState createState() => _AddMedPageState();
}

class _AddMedPageState extends State<AddMedNamePage> {
  final TextEditingController _medController = TextEditingController();

  bool _isMedSelected = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Add Medication',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What med would you like to add?",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 15),
            TextField(
              controller: _medController,
              decoration: const InputDecoration(
                hintText: "Search for medication",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (medName) {
                provider.selectPurpose(medName);
                setState(() {
                  _isMedSelected = medName.isNotEmpty;
                });
              },
            ),
            const SizedBox(height: 15),
            // Medication suggestions below
            if (_medController.text.isNotEmpty)
              SizedBox(
                height: 500,
                child: ListView(
                  children: medicationSuggestions
                      .where((med) => med
                          .toLowerCase()
                          .contains(_medController.text.toLowerCase()))
                      .map((med) => ListTile(
                            title: Text(med),
                            onTap: () {
                              Provider.of<MedicationProvider>(context,
                                      listen: false)
                                  .selectMedication(med);
                              setState(() {
                                _medController.text = med;
                                _isMedSelected = true;
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
                onPressed: _isMedSelected
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MedFormPage()),
                        );
                        // Proceed to next page or action
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: _isMedSelected
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

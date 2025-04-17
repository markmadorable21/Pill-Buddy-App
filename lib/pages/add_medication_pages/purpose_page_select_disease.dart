import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/database/diseases_data.dart';
import 'package:pill_buddy/pages/providers/disease_provider.dart';
import 'package:provider/provider.dart';

class PurposePageSelectDisease extends StatefulWidget {
  const PurposePageSelectDisease({super.key});

  @override
  State<PurposePageSelectDisease> createState() =>
      _PurposePageSelectDiseaseState();
}

class _PurposePageSelectDiseaseState extends State<PurposePageSelectDisease> {
  String? selectedPurpose;
  @override
  Widget build(BuildContext context) {
    var selectedPurpose = Provider.of<PurposeProvider>(context).selectedPurpose;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text(selectedPurpose!, style: const TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // You can handle skip logic here
            },
            child: const Text("Skip", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: const Text(
                "What are you taking it for?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.builder(
                itemCount: diseaseSuggestions.length,
                itemBuilder: (context, index) {
                  final purpose = diseaseSuggestions[index];
                  final isSelected = selectedPurpose == purpose;

                  return SlideInUp(
                    delay: Duration(milliseconds: 100 + index * 50),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPurpose = purpose;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey),
                          color: isSelected
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              purpose,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? primaryColor : Colors.black,
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: primaryColor),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideInUp(
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor:
                        selectedPurpose != null ? primaryColor : Colors.grey,
                  ),
                  onPressed: selectedPurpose != null
                      ? () {
                          print("Selected Purpose: $selectedPurpose");
                        }
                      : null,
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
